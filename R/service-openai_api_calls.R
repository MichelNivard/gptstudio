#' Base for a request to the OPENAI API
#'
#' This function sends a request to a specific OpenAI API \code{task} endpoint at
#' the base URL \code{https://api.openai.com/v1}, and authenticates with
#' an API key using a Bearer token.
#'
#' @param task character string specifying an OpenAI API endpoint task
#' @param token String containing an OpenAI API key. Defaults to the OPENAI_API_KEY
#' environmental variable if not specified.
#' @return An httr2 request object
request_base <- function(task, token = Sys.getenv("OPENAI_API_KEY")) {
  if (!task %in% get_available_endpoints()) {
    cli::cli_abort(message = c(
      "{.var task} must be a supported endpoint",
      "i" = "Run {.run gptstudio::get_available_endpoints()} to get a list of supported endpoints"
    ))
  }
  request(getOption("gptstudio.openai_url")) %>%
    req_url_path_append(task) %>%
    req_auth_bearer_token(token = token)
}

#' Generate text completions using OpenAI's API for Chat
#'
#' @param model The model to use for generating text
#' @param prompt The prompt for generating completions
#' @param openai_api_key The API key for accessing OpenAI's API. By default, the
#'   function will try to use the `OPENAI_API_KEY` environment variable.
#' @param task The task that specifies the API url to use, defaults to
#' "completions" and "chat/completions" is required for ChatGPT model.
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' openai_create_completion(
#'   model = "text-davinci-002",
#'   prompt = "Hello world!"
#' )
#' }
#' @export
openai_create_chat_completion <-
  function(prompt = "<|endoftext|>",
           model = getOption("gptstudio.model"),
           openai_api_key = Sys.getenv("OPENAI_API_KEY"),
           task = "chat/completions") {
    assert_that(
      is.string(model),
      is.string(openai_api_key)
    )

    if (is.string(prompt)) {
      prompt <- list(
        list(
          role    = "user",
          content = prompt
        )
      )
    }

    body <- list(
      model = model,
      messages = prompt
    )

    query_openai_api(task = task, request_body = body, openai_api_key = openai_api_key)
  }


#' A function that sends a request to the OpenAI API and returns the response.
#'
#' @param task A character string that specifies the task to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param openai_api_key String containing an OpenAI API key. Defaults to the OPENAI_API_KEY
#' environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_openai_api <- function(task, request_body, openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  response <- request_base(task, token = openai_api_key) %>%
    req_body_json(data = request_body) %>%
    req_retry(max_tries = 3) %>%
    req_error(is_error = function(resp) FALSE) %>%
    req_perform()

  # error handling
  if (resp_is_error(response)) {
    status <- resp_status(response) # nolint
    description <- resp_status_desc(response) # nolint

    # nolint start
    cli::cli_abort(message = c(
      "x" = "OpenAI API request failed. Error {status} - {description}",
      "i" = "Visit the {.href [OpenAi Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details",
      "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
    ))
    # nolint end
  }

  response %>%
    resp_body_json()
}

#' List supported endpoints
#'
#' Get a list of the endpoints supported by gptstudio.
#'
#' @return A character vector
#' @export
#'
#' @examples
#' get_available_endpoints()
get_available_endpoints <- function() {
  c("completions", "chat/completions", "edits", "embeddings", "models")
}
