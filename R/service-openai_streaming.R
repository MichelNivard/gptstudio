#' Stream Chat Completion
#'
#' `stream_chat_completion` sends the prepared chat completion request to the
#' OpenAI API and retrieves the streamed response.
#'
#' @param messages A list of messages in the conversation,
#' including the current user prompt (optional).
#' @param element_callback A callback function to handle each element
#' of the streamed response (optional).
#' @param model A character string specifying the model to use for chat completion.
#' The default model is "gpt-4o-mini".
#' @param openai_api_key A character string of the OpenAI API key.
#' By default, it is fetched from the "OPENAI_API_KEY" environment variable.
#' Please note that the OpenAI API key is sensitive information and should be
#' treated accordingly.
#' @return The same as `httr2::req_perform_stream`
stream_chat_completion <-
  function(messages = list(list(role = "user", content = "Hi there!")),
           element_callback = openai_handler,
           model = "gpt-4o-mini",
           openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
    url <- paste0(getOption("gptstudio.openai_url"), "/chat/completions")

    body <- list(
      "model" = model,
      "stream" = TRUE,
      "messages" = messages
    )

    request(url) |>
      req_headers(
        "Content-Type" = "application/json",
        "Authorization" = paste0("Bearer ", openai_api_key)
      ) |>
      req_body_json(body) |>
      req_perform_stream(
        callback = function(x) {
          element <- rawToChar(x)
          element_callback(element)
          TRUE
        },
        round = "line",
        buffer_kb = 0.01
      )
  }

openai_handler <- function(x) {
  lines <- stringr::str_split(x, "\n")[[1]]
  lines <- lines[lines != ""]
  lines <- stringr::str_replace_all(lines, "^data: ", "")
  lines <- lines[lines != "[DONE]"]
  if (length(lines) == 0) {
    return()
  }
  json <- jsonlite::parse_json(lines)
  if (!is.null(json$choices[[1]]$finish_reason)) {
    return()
  } else {
    cat(json$choices[[1]]$delta$content)
  }
}

#' Stream handler for chat completions
#'
#' R6 class that allows to handle chat completions chunk by chunk. It also adds
#' methods to retrieve relevant data. This class DOES NOT make the request.
#'
#' Because `httr2::req_perform_stream` blocks the R console until the stream
#' finishes, this class can take a shiny session object to handle communication
#' with JS without recurring to a `shiny::observe` inside a module server.
#'
#' @param session The shiny session it will send the message to (optional).
#' @param user_prompt The prompt for the chat completion. Only to be displayed
#'   in an HTML tag containing the prompt. (Optional).
#' @param parsed_event An already parsed server-sent event to append to the
#'   events field.
#' @importFrom R6 R6Class
#' @importFrom jsonlite fromJSON
OpenaiStreamParser <- R6::R6Class( # nolint
  classname = "OpenaiStreamParser",
  inherit = SSEparser::SSEparser,
  public = list(
    #' @field shinySession  Holds the `session` provided at initialization
    shinySession = NULL,
    #' @field user_prompt  The `user_prompt` provided at initialization,
    #'  after being formatted with markdown.
    user_prompt = NULL,
    #' @field value The content of the stream. It updates constantly until the stream ends.
    value = NULL, # this will be our buffer
    #' @description Start a StreamHandler. Recommended to be assigned to the `stream_handler` name.
    initialize = function(session = NULL, user_prompt = NULL) {
      self$shinySession <- session
      self$user_prompt <- user_prompt
      self$value <- ""
      super$initialize()
    },

    #' @description Overwrites `SSEparser$append_parsed_sse()` to be able to
    #' send a custom message to a shiny session, escaping shiny's reactivity.
    append_parsed_sse = function(parsed_event) {
      # ----- here you can do whatever you want with the event data -----
      if (is.null(parsed_event$data) || parsed_event$data == "[DONE]") {
        return()
      }

      parsed_event$data <- jsonlite::fromJSON(parsed_event$data,
                                              simplifyDataFrame = FALSE)

      if (length(parsed_event$data$choices) == 0) return()

      content <- parsed_event$data$choices[[1]]$delta$content
      self$value <- paste0(self$value, content)

      if (!is.null(self$shinySession)) {
        # any communication with JS should be handled here!!
        self$shinySession$sendCustomMessage(
          type = "render-stream",
          message = list(
            user = self$user_prompt,
            assistant = shiny::markdown(self$value)
          )
        )
      }

      # ----- END ----

      self$events <- c(self$events, list(parsed_event))
      invisible(self)
    }
  )
)
