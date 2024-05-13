#' Base for a request to the Google AI Studio API
#'
#' This function sends a request to a specific Google AI Studio API endpoint and
#' authenticates with an API key.
#'
#' @param model character string specifying a Google AI Studio API model
#' @param key String containing a Google AI Studio API key. Defaults to the
#'   GOOGLE_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base_google <- function(model, key = Sys.getenv("GOOGLE_API_KEY")) {
  url <- glue::glue(
    "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
  )

  request(url) %>%
    req_url_query(key = key)
}


#' A function that sends a request to the Google AI Studio API and returns the
#' response.
#'
#' @param model A character string that specifies the model to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param key String containing a Google AI Studio API key. Defaults
#'   to the GOOGLE_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_api_google <- function(model,
                             request_body,
                             key = Sys.getenv("GOOGLE_API_KEY")) {
  response <- request_base_google(model, key) %>%
    req_body_json(data = request_body) %>%
    req_retry(max_tries = 3) %>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()

  # error handling
  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    cli::cli_abort(message = c(
      "x" = "Google AI Studio API request failed. Error {status} - {description}",
      "i" = "Visit the Google AI Studio API documentation for more details"
    ))
  }

  response %>%
    resp_body_json()
}

#' Generate text completions using Google AI Studio's API
#'
#' @param prompt The prompt for generating completions
#' @param model The model to use for generating text. By default, the
#'   function will try to use "text-bison-001"
#' @param key The API key for accessing Google AI Studio's API. By default, the
#'   function will try to use the `GOOGLE_API_KEY` environment variable.
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_google(
#'   prompt = "Write a story about a magic backpack",
#'   temperature = 1.0,
#'   candidate_count = 3
#' )
#' }
#' @export
create_completion_google <- function(prompt,
                                     model = "gemini-pro",
                                     key = Sys.getenv("GOOGLE_API_KEY")) {
  # Constructing the request body as per the API documentation
  request_body <- list(
    contents = list(
      list(
        parts = list(
          list(
            text = prompt
          )
        )
      )
    )
  )

  response <- query_api_google(model = model, request_body = request_body, key = key)

  # Assuming the response structure follows the API documentation example, parsing it accordingly.
  # Please adjust if the actual API response has a different structure.
  purrr::map_chr(response$candidates, ~ .x$content$parts[[1]]$text)
}

get_available_models_google <- function(key = Sys.getenv("GOOGLE_API_KEY")) {
  response <-
    request("https://generativelanguage.googleapis.com/v1beta") %>%
    req_url_path_append("models") %>%
    req_url_query(key = key) %>%
    req_perform()

  # error handling
  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    cli::cli_abort(message = c(
      "x" = "Google AI Studio API request failed. Error {status} - {description}",
      "i" = "Visit the Google AI Studio API documentation for more details"
    ))
  }

  models <- response %>%
    resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("models")

  models$name %>%
    stringr::str_remove("models/")
}
