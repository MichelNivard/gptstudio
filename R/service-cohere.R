#' Base for a request to the Cohere Chat API
#'
#' This function sets up a POST request to the Cohere Chat API's chat endpoint
#' and includes necessary headers such as 'accept', 'content-type', and 'Authorization'
#' with a bearer token.
#'
#' @param api_key String containing a Cohere API key. Defaults to the
#'   COHERE_API_KEY environment variable if not specified.
#'
#' @return An `httr2` request object pre-configured with the API endpoint and required headers.
request_base_cohere <- function(api_key = Sys.getenv("COHERE_API_KEY")) {
  url <- "https://api.cohere.ai/v1/chat"
  request(url) %>%
    req_method("POST") %>%
    req_headers(
      "accept" = "application/json",
      "content-type" = "application/json",
      "Authorization" = paste("Bearer", api_key)
    )
}

#' Send a request to the Cohere Chat API and return the response
#'
#' This function sends a JSON post request to the Cohere Chat API,
#' retries on failure up to three times, and returns the response.
#' The function handles errors by providing a descriptive message and failing gracefully.
#'
#' @param request_body A list containing the body of the POST request.
#' @param api_key String containing a Cohere API key. Defaults to the
#'   COHERE_API_KEY environmental variable if not specified.
#'
#' @return A parsed JSON object as the API response.
query_api_cohere <- function(request_body, api_key = Sys.getenv("COHERE_API_KEY")) {
  response <- request_base_cohere(api_key) %>%
    req_body_json(data = request_body) %>%
    req_retry(max_tries = 3) %>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()

  # Error handling
  if (resp_is_error(response)) {
    status <- resp_status(response)
    description <- resp_status_desc(response)

    cli::cli_abort(message = c(
      "x" = paste("Cohere Chat API request failed. Error", status, "-", description),
      "i" = "Visit the Cohere API documentation for more details"
    ))
  }

  response %>%
    resp_body_json() %>%
    purrr::pluck("text")
}

#' Create a chat with the Cohere Chat API
#'
#' This function submits a user message to the Cohere Chat API,
#' potentially along with other parameters such as chat history or connectors,
#' and returns the API's response.
#'
#' @param prompt A string containing the user message.
#' @param chat_history A list of previous messages for context, if any.
#' @param connectors A list of connector objects, if any.
#' @param model A string representing the Cohere model to be used, defaulting to "command".
#' Other options include "command-light", "command-nightly", and "command-light-nightly".
#' @param api_key The API key for accessing the Cohere API, defaults to the
#'   COHERE_API_KEY environment variable.
#'
#' @return The response from the Cohere Chat API containing the model's reply.
create_chat_cohere <- function(prompt,
                               chat_history = NULL,
                               connectors = NULL,
                               model = "command",
                               api_key = Sys.getenv("COHERE_API_KEY")) {
  request_body <- list(
    message = prompt,
    chat_history = chat_history,
    connectors = connectors,
    model = model
  )

  # Removing NULL elements from request_body
  request_body <- request_body[!sapply(request_body, is.null)]

  query_api_cohere(request_body, api_key)
}


get_available_models_cohere <- function(api_key = Sys.getenv("COHERE_API_KEY")) {
  request("https://api.cohere.ai/v1/models") %>%
    req_url_path_append("?endpoint=chat") %>%
    req_method("GET") %>%
    req_headers(
      "accept" = "application/json",
      "Authorization" = paste("Bearer", api_key)
    ) %>%
    req_perform() %>%
    resp_body_json() |>
    purrr::pluck("models") |>
    purrr::map_chr(function(x) x$name)
}
