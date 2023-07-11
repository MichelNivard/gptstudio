#' Base for a request to the PALM (MakerSuite) API
#'
#' This function sends a request to a specific PALM (MakerSuite) API endpoint and
#' authenticates with an API key.
#'
#' @param model character string specifying a PALM (MakerSuite) API model
#' @param key String containing a PALM (MakerSuite) API key. Defaults to the
#'   PALM_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base_palm <- function(model, key = Sys.getenv("PALM_API_KEY")) {
  # Append the model and API key to the base URL
  url <- paste0("https://generativelanguage.googleapis.com/v1beta2/models/", model, ":generateText?key=", key)

  httr2::request(url) %>%
    httr2::req_method("POST")
}

#' A function that sends a request to the PALM (MakerSuite) API and returns the
#' response.
#'
#' @param model A character string that specifies the model to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param key String containing a PALM (MakerSuite) API key. Defaults
#'   to the PALM_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_api_palm <- function(model,
                         request_body,
                         key = Sys.getenv("PALM_API_KEY")) {
  response <- request_base_palm(model, key) %>%
    httr2::req_body_json(data = request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = function(resp) FALSE) %>%
    httr2::req_perform()

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)

    cli::cli_abort(message = c(
      "x" = "PALM (MakerSuite) API request failed. Error {status} - {description}",
      "i" = "Visit the PALM (MakerSuite) API documentation for more details"
    ))
  }

  response %>%
    httr2::resp_body_json()
}

#' Generate text completions using PALM (MakerSuite)'s API
#'
#' @param prompt The prompt for generating completions
#' @param model The model to use for generating text. By default, the
#'   function will try to use "text-bison-001"
#' @param key The API key for accessing PALM (MakerSuite)'s API. By default, the
#'   function will try to use the `PALM_API_KEY` environment variable.
#' @param temperature The temperature to control the randomness of the model's output
#' @param candidate_count The number of completion candidates to generate
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_palm(
#'   prompt = list(text = "Write a story about a magic backpack"),
#'   temperature = 1.0,
#'   candidate_count = 3
#' )
#' }
#' @export
create_completion_palm <- function(prompt,
                                 model = "text-bison-001",
                                 key = Sys.getenv("PALM_API_KEY"),
                                 temperature = 0.5,
                                 candidate_count = 1) {
  # The request body for the PALM (MakerSuite) API should be a list with the 'prompt',
  # 'temperature', and 'candidate_count' fields set
  prompt <- list(text = prompt)
  request_body <- list(prompt = prompt,
                       temperature = temperature,
                       candidate_count = candidate_count)
  response <- query_api_palm(model = model,
                           request_body = request_body,
                           key = key)
  response$candidates[[1]]$output
}
