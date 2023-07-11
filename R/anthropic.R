#' Base for a request to the Anthropic API
#'
#' This function sends a request to the Anthropic API endpoint and
#' authenticates with an API key.
#'
#' @param key String containing an Anthropic API key. Defaults to the
#'   ANTHROPIC_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base_anthropic <- function(key = Sys.getenv("ANTHROPIC_API_KEY")) {
  httr2::request("https://api.anthropic.com/v1/complete") %>%
    httr2::req_headers(`accept` = "application/json",
                       `anthropic-version` = "2023-06-01",
                       `content-type` = "application/json",
                       `x-api-key` = key) %>%
    httr2::req_method("POST")
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
    httr2::req_body_json(data = request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = function(resp) FALSE) %>%
    httr2::req_perform()

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)

    cli::cli_abort(message = c(
      "x" = "Anthropic API request failed. Error {status} - {description}",
      "i" = "Visit the Anthropic API documentation for more details"
    ))
  }

  response %>%
    httr2::resp_body_json()
}

#' Generate text completions using Anthropic's API
#'
#' @param prompt The prompt for generating completions
#' @param history A list of the previous chat responses
#' @param model The model to use for generating text. By default, the
#'   function will try to use "claude-1".
#' @param max_tokens_to_sample The maximum number of tokens to generate. Defaults to 256.
#' @param key The API key for accessing Anthropic's API. By default, the
#'   function will try to use the `ANTHROPIC_API_KEY` environment variable.
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_anthropic(
#'   prompt = "\n\nHuman: Hello, world!\n\nAssistant:",
#'   model = "claude-1",
#'   max_tokens_to_sample = 256
#' )
#' }
#' @export
create_completion_anthropic <- function(prompt,
                                        history = NULL,
                                        model = "claude-1",
                                        max_tokens_to_sample = 256,
                                        key = Sys.getenv("ANTHROPIC_API_KEY")) {
  # The request body for the Anthropic API should be a list with the 'prompt', 'model', and 'max_tokens_to_sample' fields set
  prepped_history <- ""
  for (i in seq_along(history)) {
    if (history[[i]]$role == 'system') {
      prepped_history <- paste0(prepped_history, "\n\nHuman:\n", history[[i]]$content)
    } else if (history[[i]]$role == 'user') {
      prepped_history <- paste0(prepped_history, "\n\nHuman:\n", history[[i]]$content)
    } else if (history[[i]]$role == 'assistant') {
      prepped_history <- paste0(prepped_history, "\n\nAssistant:\n", history[[i]]$content)
    }
  }
  prompt <- glue::glue("{prepped_history}\n\nHuman: {prompt}\n\nAssistant:")
  request_body <- list(prompt = prompt,
                       model = model,
                       max_tokens_to_sample = max_tokens_to_sample)
  answer <- query_api_anthropic(request_body = request_body, key = key)
  answer$completion
}
