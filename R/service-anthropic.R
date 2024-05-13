#' Base for a request to the Anthropic API
#'
#' This function sends a request to the Anthropic API endpoint and
#' authenticates with an API key.
#'
#' @param key String containing an Anthropic API key. Defaults to the
#'   ANTHROPIC_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base_anthropic <- function(key = Sys.getenv("ANTHROPIC_API_KEY")) {
  request("https://api.anthropic.com/v1/messages") %>%
    req_headers(
      "anthropic-version" = "2023-06-01",
      "content-type" = "application/json",
      "x-api-key" = key
    )
}

#' A function that sends a request to the Anthropic API and returns the
#' response.
#'
#' @param request_body A list that contains the parameters for the task.
#' @param key String containing an Anthropic API key. Defaults
#'   to the ANTHROPIC_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_api_anthropic <- function(request_body,
                                key = Sys.getenv("ANTHROPIC_API_KEY")) {
  response <- request_base_anthropic(key) %>%
    req_body_json(data = request_body) %>%
    req_retry(max_tries = 3) %>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()

  # error handling
  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    cli::cli_abort(message = c(
      "x" = "Anthropic API request failed. Error {status} - {description}",
      "i" = "Visit the Anthropic API documentation for more details"
    ))
  }

  response %>%
    resp_body_json(simplifyVector = TRUE)
}

#' Generate text completions using Anthropic's API
#'
#' @param prompt The prompt for generating completions
#' @param system A system messages to instruct the model. Defaults to NULL.
#' @param model The model to use for generating text. By default, the
#'   function will try to use "claude-2.1".
#' @param max_tokens The maximum number of tokens to generate. Defaults to 256.
#' @param key The API key for accessing Anthropic's API. By default, the
#'   function will try to use the `ANTHROPIC_API_KEY` environment variable.
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_anthropic(
#'   prompt = "\n\nHuman: Hello, world!\n\nAssistant:",
#'   model = "claude-3-haiku-20240307",
#'   max_tokens = 1028
#' )
#' }
#' @export
create_completion_anthropic <- function(prompt = list(list(role = "user", content = "Hello")),
                                        system = NULL,
                                        model = "claude-3-haiku-20240307",
                                        max_tokens = 1028,
                                        key = Sys.getenv("ANTHROPIC_API_KEY")) {
  request_body <- list(
    messages = prompt,
    model = model,
    max_tokens = max_tokens,
    system = system
  ) %>% purrr::compact()
  answer <- query_api_anthropic(request_body = request_body, key = key)
  answer %>% purrr::pluck("content", "text")
}
