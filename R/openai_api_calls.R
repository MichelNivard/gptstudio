#' Create and edit text using OpenAI's API
#'
#' @param model The model to use for generating text
#' @param input The input text to edit
#' @param instruction The instruction for editing the text
#' @param temperature The temperature to use for generating text (between 0 and
#'   1). If `NULL`, the default temperature will be used. It is recommended NOT
#'   to specify temperature and top_p at a time.
#' @param top_p The top-p value to use for generating text (between 0 and 1). If
#'   `NULL`, the default top-p value will be used. It is recommended NOT to
#'   specify temperature and top_p at a time.
#' @param openai_api_key The API key for accessing OpenAI's API. By default, the
#'   function will try to use the `OPENAI_API_KEY` environment variable.
#' @return A list with the edited text and other information returned by the
#'   API.
#' @export
#' @examples
#' \dontrun{
#' openai_create_edit(
#'   model = "text-davinci-002",
#'   input = "Hello world!",
#'   instruction = "Capitalize the first letter of each sentence."
#' )
#' }
openai_create_edit <- function(model,
                               input = '"',
                               instruction,
                               temperature = NULL,
                               top_p = NULL,
                               openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  assert_that(
    is.string(model),
    is.string(input),
    is.string(instruction),
    is.number(temperature) && value_between(temperature, 0, 1),
    is.string(openai_api_key),
    value_between(top_p, 0, 1) || is.null(top_p)
  )

  if (is.number(temperature) && is.number(top_p)) {
    cli_warn("Specify either temperature or top_p, not both.")
  }

  body <- list(
    model = model,
    input = input,
    instruction = instruction,
    temperature = temperature,
    top_p = top_p
  )

  query_openai_api(task = "edits", request_body = body, openai_api_key = openai_api_key)
}


#' Generate text completions using OpenAI's API
#'
#' @param model The model to use for generating text
#' @param prompt The prompt for generating completions
#' @param suffix The suffix for generating completions. If `NULL`, no suffix
#'   will be used.
#' @param max_tokens The maximum number of tokens to generate.
#' @param temperature The temperature to use for generating text (between 0 and
#'   1). If `NULL`, the default temperature will be used. It is recommended NOT
#'   to specify temperature and top_p at a time.
#' @param top_p The top-p value to use for generating text (between 0 and 1). If
#'   `NULL`, the default top-p value will be used. It is recommended NOT to
#'   specify temperature and top_p at a time.
#' @param openai_api_key The API key for accessing OpenAI's API. By default, the
#'   function will try to use the `OPENAI_API_KEY` environment variable.
#' @param task The task that specifies the API url to use, defaults to
#' "completions" and "chat/completions" is required for ChatGPT model.
#'
#' @importFrom assertthat assert_that
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
openai_create_completion <-
  function(model = "text_davinci-003",
           prompt = "<|endoftext|>",
           suffix = NULL,
           max_tokens = 16,
           temperature = NULL,
           top_p = NULL,
           openai_api_key = Sys.getenv("OPENAI_API_KEY"),
           task = "completions") {
    assert_that(
      is.string(model),
      is.string(prompt),
      is.count(max_tokens),
      is.string(suffix) || is.null(suffix),
      value_between(temperature, 0, 1) || is.null(temperature),
      is.string(openai_api_key),
      value_between(top_p, 0, 1) || is.null(top_p)
    )

    if (is.number(temperature) && is.number(top_p)) {
      cli_warn("Specify either temperature or top_p, not both.")
    }

    body <- list(
      model = model,
      prompt = prompt,
      suffix = suffix,
      max_tokens = max_tokens,
      temperature = temperature
    )

    query_openai_api(task = task, request_body = body, openai_api_key = openai_api_key)
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
           model = "gpt-3.5-turbo",
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


# Make a request to the OpenAI API

#' A function that sends a request to the OpenAI API and returns the response.
#'
#' @param task A character string that specifies the task to send to the API.
#' @param request_body A list that contains the parameters for the task.
#' @param openai_api_key String containing an OpenAI API key. Defaults to the OPENAI_API_KEY environmental variable if not specified.
#'
#' @return The response from the API.
#'
query_openai_api <- function(task, request_body, openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  response <- request_base(task, token = openai_api_key) %>%
    httr2::req_body_json(data = request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = \(resp) FALSE) %>%
    httr2::req_perform()

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)

    cli::cli_abort(message = c(
      "x" = "OpenAI API request failed. Error {status} - {description}",
      "i" = "Visit the {.href [OpenAi Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details",
      "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
    ))
  }

  response %>%
    httr2::resp_body_json()
}



value_between <- function(x, lower, upper) {
  x >= lower && x <= upper
}


#' List supported models
#'
#' Get a list of the models supported by the OpenAI API.
#'
#' @return A character vector
#' @export
#'
#' @examples
#' get_available_endpoints()
get_available_models <- function() {
  check_api()

  request_base("models") %>%
    httr2::req_perform() %>%
    httr2::resp_body_json() %>%
    purrr::pluck("data") %>%
    purrr::map_chr("root")
}


#' Base for a request to the OPENAI API
#'
#' This function sends a request to a specific OpenAI API \code{task} endpoint at the base URL \code{https://api.openai.com/v1}, and authenticates with an API key using a Bearer token.
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

  httr2::request("https://api.openai.com/v1") %>%
    httr2::req_url_path_append(task) %>%
    httr2::req_auth_bearer_token(token = token)
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
