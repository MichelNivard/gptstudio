#' @importFrom rlang %||%
#' @importFrom magrittr %>%
StreamHandler <- R6::R6Class(
  classname = "StreamHandler",
  public = list(
    current_value = NULL,
    chunks = list(),
    initialize = function() {
      self$current_value <- ""
    },
    handle_streamed_element = function(x) {
      translated <- self$translate_element(x)
      self$chunks <- c(self$chunks, translated)
      self$current_value <- self$convert_chunks_into_response_str()
    },
    translate_element = function(x) {
      x %>%
        stringr::str_remove("^data: ") %>% # handle first element
        stringr::str_remove("(\n\ndata: \\[DONE\\])?\n\n$") %>% # handle last element
        stringr::str_split_1("\n\ndata: ") %>%
        purrr::map(\(x) jsonlite::fromJSON(x, simplifyVector = FALSE))
    },
    convert_chunks_into_response_str = function() {
      self$chunks %>%
        purrr::map_chr(~ .x$choices[[1]]$delta$content %||% "") %>%
        paste0(collapse = "")
    }
  )
)

stream_chat_completion <-
  function(messages,
           element_callback = cat,
           model = "gpt-3.5-turbo",
           openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
    # Set the API endpoint URL
    url <- "https://api.openai.com/v1/chat/completions"

    # Set the request headers
    headers <- list(
      "Content-Type" = "application/json",
      "Authorization" = paste0("Bearer ", openai_api_key)
    )

    if (!is.list(messages)) {
      messages <- list(list(role = "user", content = messages))
    }

    # Set the request body
    body <- list(
      "model" = model,
      "stream" = TRUE,
      "messages" = messages
    )

    # Create a new curl handle object
    handle <- curl::new_handle() %>%
      curl::handle_setheaders(.list = headers) %>%
      curl::handle_setopt(postfields = jsonlite::toJSON(body, auto_unbox = TRUE))


    # Make the streaming request using curl_fetch_stream()
    curl::curl_fetch_stream(
      url = url,
      fun = \(x) {
        element <- rawToChar(x)
        element_callback(element)
      },
      handle = handle
    )
  }

# stream_handler <- StreamHandler$new()

# stream_chat_completion(messages = "Count from 1 to 10")
# stream_chat_completion(messages = "Count from 1 to 10", element_callback = stream_handler$handle_streamed_element)

