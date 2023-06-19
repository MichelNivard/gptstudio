#' Base for a request to the HuggingFace API
#'
#' This function sends a request to a specific HuggingFace API endpoint and
#' authenticates with an API key using a Bearer token.
#'
#' @param task character string specifying a HuggingFace API endpoint task
#' @param token String containing a HuggingFace API key. Defaults to the
#'   HF_API_KEY environmental variable if not specified.
#' @keywords huggingface, api, authentication
#' @return An httr2 request object
request_base_huggingface <- function(task, token = Sys.getenv("HF_API_KEY")) {
  httr2::request("https://api-inference.huggingface.co/models") %>%
    httr2::req_url_path_append(task) %>%
    httr2::req_auth_bearer_token(token = token)
}

#' A function that sends a request to the HuggingFace API and returns the
#' response.
#'
#' @param task A character string that specifies the task to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param token String containing a HuggingFace API key. Defaults
#'   to the HF_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_api_huggingface <- function(task,
                         request_body,
                         token = Sys.getenv("HF_API_KEY")) {
  response <- request_base_huggingface(task, token) %>%
    httr2::req_body_json(data = request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = \(resp) FALSE) %>%
    httr2::req_perform()

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)

    cli::cli_abort(message = c(
      "x" = "HuggingFace API request failed. Error {status} - {description}",
      "i" = "Visit the HuggingFace API documentation for more details"
    ))
  }

  response %>%
    httr2::resp_body_json()
}

#' Generate text completions using HuggingFace's API
#'
#' @param model The model to use for generating text
#' @param prompt The prompt for generating completions
#' @param token The API key for accessing HuggingFace's API. By default, the
#'   function will try to use the `HF_API_KEY` environment variable.
#' @param max_new_tokens Maximum number of tokens to generate, defaults to 250
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_huggingface(
#'   model = "gpt2",
#'   prompt = "Hello world!"
#' )
#' }
#' @export
create_completion_huggingface <- function(prompt,
                                 model = "tiiuae/falcon-7b-instruct",
                                 token = Sys.getenv("HF_API_KEY"),
                                 max_new_tokens = 250) {
  # The request body for the HuggingFace API should be a list with the 'inputs'
  # field set to the prompt
  request_body <- list(inputs = prompt,
                       parameters = list(max_new_tokens	= max_new_tokens,
                                         return_full_text = FALSE))
  query_api_huggingface(task = model,
               request_body = request_body,
               token = token)
}
