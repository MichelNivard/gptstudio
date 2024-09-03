#' Generate text completions using Google AI Studio's API
#'
#' @param prompt The prompt for generating completions
#' @param model The model to use for generating text. By default, the function
#'   will try to use "text-bison-001"
#' @param api_key The API key for accessing Google AI Studio's API. By default,
#'   the function will try to use the `GOOGLE_API_KEY` environment variable.
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_chat_google(
#'   prompt = "Write a story about a magic backpack",
#'   temperature = 1.0,
#'   candidate_count = 3
#' )
#' }
#' @export
create_chat_google <- function(prompt = list(list(role = "user", content = "tell me a joke")),
                               model = "gemini-pro",
                               api_key = Sys.getenv("GOOGLE_API_KEY")) {

  messages <- openai_to_google_format(prompt)

  request_body <- list(
    # system_instruction = messages$system_instruction,
    contents = messages$contents
  )

  query_api_google(model = model,
                   request_body = request_body,
                   api_key = api_key)
}

request_base_google <- function(model,
                                api_key = Sys.getenv("GOOGLE_API_KEY")) {
  request("https://generativelanguage.googleapis.com/v1beta/models") |>
    req_url_path_append(glue("{model}:generateContent")) |>
    req_url_query(key = api_key)
}

query_api_google <- function(request_body,
                             api_key = Sys.getenv("GOOGLE_API_KEY"),
                             model) {
  resp <-
    request_base_google(model = model, api_key = api_key) |>
    req_body_json(data = request_body, auto_unbox = TRUE) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  if (resp_is_error(resp)) {
    status <- resp_status(resp) # nolint
    description <- resp_status_desc(resp) # nolint

    cli::cli_abort(c(
      "x" = "Google AI Studio API request failed. Error {status} - {description}",
      "i" = "Visit the Google AI Studio API documentation for more details"
    ))
  }
  results <- resp |> resp_body_json()
  results$candidates[[1]]$content$parts[[1]]$text
}

get_available_models_google <- function(api_key = Sys.getenv("GOOGLE_API_KEY")) {
  response <-
    request("https://generativelanguage.googleapis.com/v1beta") |>
    req_url_path_append("models") |>
    req_url_query(key = api_key) |>
    req_perform()

  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    cli::cli_abort(message = c(
      "x" = "Google AI Studio API request failed. Error {status} - {description}",
      "i" = "Visit the Google AI Studio API documentation for more details"
    ))
  }

  models <- response |>
    resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("models")

  models$name |>
    stringr::str_remove("models/")
}

openai_to_google_format <- function(openai_messages) {
  google_format <- list(contents = list())

  for (message in openai_messages) {
    role <- message$role
    content <- message$content

    if (role == "system") {
      google_format$system_instruction <- list(parts = list(text = content))
    } else if (role %in% c("user", "assistant")) {
      google_role <- ifelse(role == "user", "user", "model")
      google_format$contents <- c(google_format$contents,
                                  list(list(
                                    role = google_role,
                                    parts = list(list(text = content))
                                  )))
    }
  }
  invisible(google_format)
}
