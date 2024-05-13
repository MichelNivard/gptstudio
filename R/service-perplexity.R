#' Base for a request to the Perplexity API
#'
#' This function sets up a POST request to the Perplexity API's chat/completions endpoint
#' and includes necessary headers such as 'accept', 'content-type', and 'Authorization'
#' with a bearer token.
#'
#' @param api_key String containing a Perplexity API key. Defaults to the
#'   PERPLEXITY_API_KEY environment variable if not specified.
#'
#' @return An `httr2` request object pre-configured with the API endpoint and required headers.
request_base_perplexity <- function(api_key = Sys.getenv("PERPLEXITY_API_KEY")) {
  url <- "https://api.perplexity.ai/chat/completions"
  request(url) %>%
    req_method("POST") %>%
    req_headers(
      "accept" = "application/json",
      "content-type" = "application/json",
      "Authorization" = paste("Bearer", api_key)
    )
}

#' Send a request to the Perplexity API and return the response
#'
#' This function sends a JSON post request to the Perplexity API,
#' retries on failure up to three times, and returns the response.
#' The function handles errors by providing a descriptive message and failing gracefully.
#'
#' @param request_body A list containing the body of the POST request.
#' @param api_key String containing a Perplexity API key. Defaults to the
#'   PERPLEXITY_API_KEY environmental variable if not specified.
#'
#' @return A parsed JSON object as the API response.
query_api_perplexity <- function(request_body, api_key = Sys.getenv("PERPLEXITY_API_KEY")) {
  response <- request_base_perplexity(api_key) %>%
    req_body_json(data = request_body) %>%
    req_retry(max_tries = 3) %>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()

  # Error handling
  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    cli::cli_abort(message = c(
      "x" = "Perplexity API request failed. Error {status} - {description}",
      "i" = "Visit the Perplexity API documentation for more details"
    ))
  }

  response %>%
    resp_body_json()
}

#' Create a chat completion request to the Perplexity API
#'
#' This function sends a series of messages alongside a chosen model to the Perplexity API
#' to generate a chat completion. It returns the API's generated responses.
#'
#' @param prompt A list containing prompts to be sent in the chat.
#' @param model A character string representing the Perplexity model to be used.
#'   Defaults to "mistral-7b-instruct".
#' @param api_key The API key for accessing the Perplexity API. Defaults to the
#'   PERPLEXITY_API_KEY environment variable.
#'
#' @return The response from the Perplexity API containing the completion for the chat.
create_completion_perplexity <- function(prompt,
                                         model = "mistral-7b-instruct",
                                         api_key = Sys.getenv("PERPLEXITY_API_KEY")) {
  request_body <- list(
    model = model,
    messages = list(list(role = "user", content = prompt))
  )
  query_api_perplexity(request_body, api_key)
}
