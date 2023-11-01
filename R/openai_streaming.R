#' Stream Chat Completion
#'
#' `stream_chat_completion` sends the prepared chat completion request to the
#' OpenAI API and retrieves the streamed response. The results are then stored
#' in a temporary file.
#'
#' @param prompt A list of messages. Each message is a list that includes a
#' "role" and "content". The "role" can be "system", "user", or "assistant".
#' The "content" is the text of the message from the role.
#' @param model A character string specifying the model to use for chat completion.
#' The default model is "gpt-3.5-turbo".
#' @param openai_api_key A character string of the OpenAI API key.
#' By default, it is fetched from the "OPENAI_API_KEY" environment variable.
#' Please note that the OpenAI API key is sensitive information and should be
#' treated accordingly.
#' @return A character string specifying the path to the tempfile that contains the
#' full response from the OpenAI API.
#' @examples
#' \dontrun{
#' # Get API key from your environment variables
#' openai_api_key <- Sys.getenv("OPENAI_API_KEY")
#'
#' # Define the prompt
#' prompt <- list(
#'   list(role = "system", content = "You are a helpful assistant."),
#'   list(role = "user", content = "Who won the world series in 2020?")
#' )
#'
#' # Call the function
#' result <- stream_chat_completion(prompt = prompt, openai_api_key = openai_api_key)
#'
#' # Print the result
#' print(result)
#' }
#' @export
stream_chat_completion <-
  function(prompt,
           history = NULL,
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

    # Set the new chat history so the system prompt depends
    # on the current parameters and not in previous ones
    # instructions <- list(
    #   list(
    #     role = "system",
    #     content = chat_create_system_prompt(style, skill, task, in_source = FALSE)
    #   ),
    #   list(
    #     role = "user",
    #     content = prompt
    #   )
    # )

    # history <- purrr::discard(history, ~ .x$role == "system")

    # messages <- c(history, instructions)

    messages <- chat_history_append(
      history = history,
      role = "user",
      content = prompt
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
      fun = \(x) {
        element <- rawToChar(x)
        element_callback(element) # Do whatever element_callback does
      },
      handle = handle
    )
  }
