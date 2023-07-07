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
stream_chat_completion <- function(prompt,
                                   model = "gpt-3.5-turbo",
                                   openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  if (file.exists(streaming_file())) file.remove(streaming_file())

  base_url <- getOption("gptstudio.openai_url")
  body <- list(
    "model" = model,
    "messages" = prompt,
    "stream" = TRUE
  )
  gptstudio_env$stream <- list()
  gptstudio_env$stream$raw <- NULL
  gptstudio_env$current_stream <- TRUE

  httr2::request(base_url) %>%
    httr2::req_url_path_append("chat/completions") %>%
    httr2::req_body_json(body) %>%
    httr2::req_auth_bearer_token(openai_api_key) %>%
    httr2::req_headers("Content-Type" = "application/json") %>%
    httr2::req_method("POST") %>%
    httr2::req_stream(callback = function(x) {openai_stream_parse(x); TRUE},
                      buffer_kb = 0.05)
  chat_response <- readRDS(streaming_file())
  file.remove(streaming_file())
  cli_inform("File exists: {file.exists(streaming_file())}")
  chat_response
}


#' OpenAI Stream Parse
#'
#' This function handles the streaming data from the OpenAI API.
#' It concatenates the raw data chunks, attempts to parse JSON and
#' handles any error messages.
#'
#' This function was inspired by the `{chattr}` R package
#' (https://github.com/mlverse/chattr).
#'
#' @param x A raw vector representing a chunk of data from the API stream.
#' @return If parsing is successful, a character string of the API response is
#' returned. In case of an error, an error message is returned instead.
openai_stream_parse <- function(x) {
  gptstudio_env$stream$raw <- paste0(
    gptstudio_env$stream$raw,
    rawToChar(x),
    collapse = ""
  )
  res <- gptstudio_env$stream$raw %>%
    paste0(collapse = "") %>%
    strsplit("data: ") %>%
    unlist() %>%
    purrr::discard(~ .x == "")
  if (length(res) > 1) {
    gptstudio_env$stream$raw <- res[2]
    set_to_null <- FALSE
  } else {
    set_to_null <- TRUE
  }
  res <- res %>%
    purrr::keep(~ substr(.x, (nchar(.x) - 2), nchar(.x)) == "}\n\n")

  if (length(res) > 0) {
    new_response <- jsonlite::fromJSON(res)
    new_response <- new_response$choices$delta$content
    gptstudio_env$stream$parsed <- paste0(
      gptstudio_env$stream$parsed,
      new_response,
      collapse = ""
    )
    if (set_to_null) gptstudio_env$stream$raw <- NULL
    saveRDS(gptstudio_env$stream$parsed, file = streaming_file())
  } else {
    json_res <- try(jsonlite::fromJSON(x), silent = TRUE)
    if (!inherits(json_res, "try-error")) {
      if ("error" %in% names(json_res)) {
        json_error <- json_res$error
        return(
          paste0(
            "{{error}}Type:",
            json_error$type,
            "\nMessage: ",
            json_error$message
          )
        )
      }
    }
  }
}

streaming_file <- function() {
  dir <- tools::R_user_dir(package = "gptstudio", which = "data")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  file.path(dir, "chat_stream.RDS")
}
