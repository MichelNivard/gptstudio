#' Stream handler for chat completions
#'
#' R6 class that allows to handle chat completions chunk by chunk.
#' It also adds methods to retrieve relevant data. This class DOES NOT make the request.
#'
#' Because `curl::curl_fetch_stream` blocks the R console until the stream finishes,
#' this class can take a shiny session object to handle communication with JS
#' without recurring to a `shiny::observe` inside a module server.
#'
#' @param session The shiny session it will send the message to (optional).
#' @param user_prompt The prompt for the chat completion. Only to be displayed in an HTML tag containing the prompt. (Optional).
#' @importFrom rlang %||%
#' @importFrom magrittr %>%
#' @importFrom R6 R6Class
#' @importFrom stringr str_remove str_split_1
#' @importFrom purrr map_chr map
#' @importFrom jsonlite fromJSON
StreamHandler <- R6::R6Class(
  classname = "StreamHandler",
  public = list(

    #' @field current_value The content of the stream. It updates constantly until the stream ends.
    current_value = NULL,

    #' @field chunks  The list of chunks streamed. It updates constantly until the stream ends.
    chunks = list(),

    #' @field shinySession  Holds the `session` provided at initialization
    shinySession = NULL,

    #' @field user_message  The `user_prompt` provided at initialization after being formatted with markdown.
    user_message = NULL,

    #' @description Start a StreamHandler. Recommended to be assigned to the `stream_handler` name.
    initialize = function(session = NULL, user_prompt = NULL) {
      self$current_value <- ""
      self$shinySession <- session
      self$user_message <- shiny::markdown(user_prompt)
    },

    #' @description The main reason this class exists. It reduces to stream to chunks and its current value. If the object finds a shiny session will send a `render-stream` message to JS.
    #' @param x The streamed element. Preferably after conversion from raw.
    handle_streamed_element = function(x) {
      translated <- private$translate_element(x)
      self$chunks <- c(self$chunks, translated)
      self$current_value <- private$convert_chunks_into_response_str()

      if (!is.null(self$shinySession)) {
        # any communication with JS should be handled here!!
        self$shinySession$sendCustomMessage(
          type = "render-stream",
          message = list(
            user = self$user_message,
            assistant = shiny::markdown(self$current_value)
          )
        )
      }
    },

    #' @description Extract the message content as a message ready to be styled or appended to the chat history. Useful after the stream ends.
    extract_message = function() {
      list(
        role = "assistant",
        content = self$current_value
      )
    }
  ),
  private = list(
    # Translates a streamed element and converts it to chunk.
    # Also handles the case of multiple elements in a single stream.
    translate_element = function(x) {
      x %>%
        stringr::str_remove("^data: ") %>% # handle first element
        stringr::str_remove("(\n\ndata: \\[DONE\\])?\n\n$") %>% # handle last element
        stringr::str_split_1("\n\ndata: ") %>%
        purrr::map(function(x) jsonlite::fromJSON(x, simplifyVector = FALSE))
    },
    # Reduces the chuks into just the message content.
    convert_chunks_into_response_str = function() {
      self$chunks %>%
        purrr::map_chr(~ .x$choices[[1]]$delta$content %||% "") %>%
        paste0(collapse = "")
    }
  )
)
