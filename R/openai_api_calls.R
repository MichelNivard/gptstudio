#' Create edit
#'
#' #' This code is altered from [openai](https://github.com/irudnyts/openai).
#' Credit goes to irudnyts for contributions to this function.
#'
#' Creates an edit based on the provided input, instruction, and parameters. See
#' [this page](https://beta.openai.com/docs/api-reference/edits/create) for
#' details.
#'
#' For arguments description please refer to the official
#' [docs](https://beta.openai.com/docs/api-reference/edits/create).
#'
#' @param model required; a length one character vector.
#' @param input required; defaults to `'"'`; a length one character vector.
#' @param instruction required; a length one character vector.
#' @param temperature required; defaults to `1`; a length one numeric vector
#'   with the value between `0` and `2`.
#' @param top_p required; defaults to `1`; a length one numeric vector with the
#'   value between `0` and `1`.
#' @param openai_api_key required; defaults to `Sys.getenv("OPENAI_API_KEY")`
#'   (i.e., the value is retrieved from the `.Renviron` file); a length one
#'   character vector. Specifies OpenAI API key.
#' @param openai_organization optional; defaults to `NULL`; a length one
#'   character vector. Specifies OpenAI organization.
#' @return Returns a list, elements of which contain edited version of prompt
#'   and supplementary information.
#' @examples \dontrun{
#' create_edit(
#'   model = "text-davinci-edit-001",
#'   input = "What day of the wek is it?",
#'   instruction = "Fix the spelling mistakes"
#' )
#' }
#' @export
openai_create_edit <- function(model,
                               input = '"',
                               instruction,
                               temperature = 1,
                               top_p = 1,
                               openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                               openai_organization = NULL) {
  assert_that(
    is.string(model),
    is.string(input),
    is.string(instruction),
    is.number(temperature) && value_between(temperature, 0, 2),
    is.number(top_p),
    is.string(openai_api_key),
    is.null(openai_organization) || is.string(openai_organization),
    value_between(top_p, 0, 1)
  )

  if (both_specified(temperature, top_p)) {
    warn("It is recommended NOT to specify temperature and top_p at a time.")
  }

  body <- list(
    model = model,
    input = input,
    instruction = instruction,
    temperature = temperature,
    top_p = top_p
  )

  query_openai_api(body, openai_api_key, openai_organization, task = "edits")
}


#' Create completion
#'
#' This code is altered from [openai](https://github.com/irudnyts/openai).
#' Credit goes to irudnyts for contributions to this function.
#'
#' Creates a completion based on the provided prompt and parameters. See [this
#' page](https://beta.openai.com/docs/api-reference/completions/create) for
#' details.
#'
#' For arguments description please refer to the official
#' [docs](https://beta.openai.com/docs/api-reference/completions/create).
#'
#' @param model required; a length one character vector.
#' @param prompt required; defaults to `"<|endoftext|>"`; an arbitrary length
#'   character vector.
#' @param suffix optional; defaults to `NULL`; a length one character vector.
#' @param max_tokens required; defaults to `16`; a length one numeric vector
#'   with the integer value greater than `0`.
#' @param temperature required; defaults to `1`; a length one numeric vector
#'   with the value between `0` and `2`.
#' @param top_p required; defaults to `1`; a length one numeric vector with the
#'   value between `0` and `1`.
#' @param n required; defaults to `1`; a length one numeric vector with the
#'   integer value greater than `0`.
#' @param logprobs optional; defaults to `NULL`; a length one numeric vector
#'   with the integer value between `0` and `5`.
#' @param echo required; defaults to `FALSE`; a length one logical vector.
#' @param stop optional; defaults to `NULL`; a character vector of length
#'   between one and four.
#' @param presence_penalty required; defaults to `0`; a length one numeric
#'   vector with a value between `-2` and `2`.
#' @param frequency_penalty required; defaults to `0`; a length one numeric
#'   vector with a value between `-2` and `2`.
#' @param best_of required; defaults to `1`; a length one numeric vector with
#'   the integer value greater than `0`.
#' @param logit_bias optional; defaults to `NULL`; a named list.
#' @param user optional; defaults to `NULL`; a length one character vector.
#' @param openai_api_key required; defaults to `Sys.getenv("OPENAI_API_KEY")`
#'   (i.e., the value is retrieved from the `.Renviron` file); a length one
#'   character vector. Specifies OpenAI API key.
#' @param openai_organization optional; defaults to `NULL`; a length one
#'   character vector. Specifies OpenAI organization.
#' @return Returns a list, elements of which contain completion(s) and
#'   supplementary information.
#' @examples \dontrun{
#' create_completion(
#'   model = "text-davinci-002",
#'   prompt = "Say this is a test",
#'   max_tokens = 5
#' )
#'
#' logit_bias <- list(
#'   "11" = -100,
#'   "13" = -100
#' )
#' create_completion(
#'   model = "ada",
#'   prompt = "Generate a question and an answer",
#'   n = 4,
#'   best_of = 4,
#'   logit_bias = logit_bias
#' )
#' }
#' @export
openai_create_completion <- function(model,
                                     prompt = "<|endoftext|>",
                                     suffix = NULL,
                                     max_tokens = 16,
                                     temperature = 1,
                                     top_p = 1,
                                     n = 1,
                                     logprobs = NULL,
                                     echo = FALSE,
                                     stop = NULL,
                                     presence_penalty = 0,
                                     frequency_penalty = 0,
                                     best_of = 1,
                                     logit_bias = NULL,
                                     user = NULL,
                                     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                                     openai_organization = NULL) {
  assert_that(
    is.string(model),
    is.string(prompt),
    is.string(suffix) || is.null(suffix),
    is.count(max_tokens),
    is.number(temperature) && value_between(temperature, 0, 2),
    is.number(top_p) && value_between(top_p, 0, 1),
    assert_that(is.count(n)),
    is.flag(echo),
    is.number(frequency_penalty) && value_between(frequency_penalty, -2, 2),
    is.character(stop) && length_between(stop, 1, 4) || is.null(stop),
    is.number(presence_penalty) && value_between(presence_penalty, -2, 2),
    is.count(best_of) && best_of >= n,
    is.null(logit_bias) || is.list(logit_bias),
    is.string(user) || is.null(user),
    is.string(openai_api_key),
    is.null(openai_organization) || is.string(openai_organization),
    is.count(logprobs + 1) && value_between(logprobs, 0, 5) || is.null(logprobs)
  )

  if (both_specified(temperature, top_p)) {
    warn("It is recommended NOT to specify temperature and top_p at a time.")
  }

  body <- list(
    model = model,
    prompt = prompt,
    suffix = suffix,
    max_tokens = max_tokens,
    temperature = temperature,
    top_p = top_p,
    n = n,
    logprobs = logprobs,
    echo = echo,
    stop = stop,
    presence_penalty = presence_penalty,
    frequency_penalty = frequency_penalty,
    best_of = best_of,
    logit_bias = logit_bias,
    user = user
  )

  query_openai_api(
    body, openai_api_key, openai_organization,
    task = "completions"
  )
}

query_openai_api <- function(body,
                             openai_api_key,
                             openai_organization = NULL,
                             task) {
  arg_match(task, c("completions", "edits"))

  base_url <- glue("https://api.openai.com/v1/{task}")

  headers <- c(
    "Authorization" = glue("Bearer {openai_api_key}"),
    "Content-Type" = "application/json"
  )

  if (!is.null(openai_organization)) {
    headers["OpenAI-Organization"] <- openai_organization
  }

  response <- httr::POST(
    url = base_url,
    httr::add_headers(headers),
    body = body,
    encode = "json"
  )

  parsed <- response %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE)

  if (httr::http_error(response)) {
    abort(c(
      "x" = glue("OpenAI API request failed [{httr::status_code(response)}]."),
      "i" = glue("Error message: {parsed$error$message}")
    ))
  }

  cli_text("Status code: {httr::status_code(response)}")

  parsed
}

value_between <- function(x, lower, upper) {
  x >= lower && x <= upper
}

both_specified <- function(x, y) {
  x != 1 && y != 1
}

length_between <- function(x, lower, upper) {
  length(x) >= lower && length(x) <= upper
}
