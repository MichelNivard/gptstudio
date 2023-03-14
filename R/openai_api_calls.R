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

  query_openai_api(body, openai_api_key, task = "edits")
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

    query_openai_api(body, openai_api_key, task = task)
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

    query_openai_api(body, openai_api_key, task = task)
  }

query_openai_api <- function(body, openai_api_key, task) {
  arg_match(task, c("completions", "chat/completions", "edits", "embeddings"))

  base_url <- glue("https://api.openai.com/v1/{task}")

  headers <- c(
    "Authorization" = glue("Bearer {openai_api_key}"),
    "Content-Type" = "application/json"
  )

  response <-
    httr::RETRY("POST",
      url = base_url,
      httr::add_headers(headers), body = body,
      encode = "json",
      quiet = TRUE
    )

  parsed <- response %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE)

  if (httr::http_error(response)) {
    cli_alert_warning(c(
      "x" = glue("OpenAI API request failed [{httr::status_code(response)}]."),
      "i" = glue("Error message: {parsed$error$message}")
    ))
  }
  parsed
}

value_between <- function(x, lower, upper) {
  x >= lower && x <= upper
}
