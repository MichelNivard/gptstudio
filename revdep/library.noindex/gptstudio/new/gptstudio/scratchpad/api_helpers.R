#' Base for a request to an API service
#'
#' This function sends a request to a specific API \code{task} endpoint at the base URL and authenticates with an API key using a Bearer token. The default is OpenAI's API using a base URL of \code{https://api.openai.com/v1}.
#'
#' @param task character string specifying an OpenAI API endpoint task
#' @param token String containing an OpenAI API key. Defaults to the OPENAI_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base <- function(task, token = Sys.getenv("OPENAI_API_KEY")) {
  if (!task %in% get_available_endpoints()) {
    cli::cli_abort(message = c(
      "{.var task} must be a supported endpoint",
      "i" = "Run {.run gptstudio::get_available_endpoints()} to get a list of supported endpoints"
    ))
  }
  httr2::request(getOption("gptstudio.openai_url")) %>%
    httr2::req_url_path_append(task) %>%
    httr2::req_auth_bearer_token(token = token)
}

#' A function that sends an API request and returns the response.
#'
#' @param task A character string that specifies the task to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param token String containing an API key. Defaults to the OPENAI_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_api <- function(task, request_body, token = Sys.getenv("OPENAI_API_KEY")) {
  response <- request_base(task, token = token) %>%
    httr2::req_body_json(data = request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = \(resp) FALSE)

  response %>% httr2::req_dry_run()

  response <- httr2::req_perform(response)

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)
    send_abort_message(service, status, description)
  }

  response %>%
    httr2::resp_body_json()
}

send_abort_message <- function(service = "openai",
                               status = NULL,
                               description = NULL) {
  switch(service,
         "openai" = cli::cli_abort(
           message = c(
             "x" = "OpenAI API request failed. Error {status} - {description}",
             "i" = "Visit the {.href [OpenAI Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details.",
             "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
           )),
         "huggingface" = cli::cli_abort(
           message = c(
           "x" = "HuggingFace API request failed. Error {status} - {description}",
           "i" = "Visit the {.href [HuggingFace Inference API documentation](https://huggingface.co/inference-api)} for more details."
         ))
  )
}
