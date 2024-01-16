#' Stream Chat Completion
#'
#' `stream_chat_completion` sends the prepared chat completion request to the
#' OpenAI API and retrieves the streamed response.
#'
#' @param messages A list of messages in the conversation, including the current user prompt (optional).
#' @param element_callback A callback function to handle each element of the streamed response (optional).
#' @param model A character string specifying the model to use for chat completion.
#' The default model is "gpt-3.5-turbo".
#' @param openai_api_key A character string of the OpenAI API key.
#' By default, it is fetched from the "OPENAI_API_KEY" environment variable.
#' Please note that the OpenAI API key is sensitive information and should be
#' treated accordingly.
#' @return The same as `curl::curl_fetch_stream`
stream_chat_completion <-
  function(messages = NULL,
           element_callback = cat,
           model = "gpt-3.5-turbo",
           openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
    # Set the API endpoint URL
    url <- paste0(getOption("gptstudio.openai_url"), "/chat/completions")

    # Set the request headers
    headers <- list(
      "Content-Type" = "application/json",
      "Authorization" = paste0("Bearer ", openai_api_key)
    )

    # Set the request body
    body <- list(
      "model" = model,
      "stream" = TRUE,
      "messages" = messages
    )

    # Create a new curl handle object
    handle <- curl::new_handle() %>%
      curl::handle_setheaders(.list = headers) %>%
      curl::handle_setopt(postfields = jsonlite::toJSON(body, auto_unbox = TRUE)) # request body

    # Make the streaming request using curl_fetch_stream()
    curl::curl_fetch_stream(
      url = url,
      fun = function(x) {
        element <- rawToChar(x)
        element_callback(element) # Do whatever element_callback does
      },
      handle = handle
    )
  }