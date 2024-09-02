#' Base for a request to the Anthropic API
#'
#' This function sends a request to the Anthropic API endpoint and
#' authenticates with an API key.
#'
#' @param key String containing an Anthropic API key. Defaults to the
#'   ANTHROPIC_API_KEY environmental variable if not specified.
#' @return An httr2 request object
request_base_anthropic <- function(key = Sys.getenv("ANTHROPIC_API_KEY")) {
  request("https://api.anthropic.com/v1/messages") |>
    req_headers(
      "anthropic-version" = "2023-06-01",
      "content-type" = "application/json",
      "x-api-key" = key
    )
}

query_api_anthropic <- function(request_body,
                                key = Sys.getenv("ANTHROPIC_API_KEY"),
                                stream = FALSE,
                                element_callback = anthropic_handler,
                                shiny_session = NULL,
                                user_prompt = NULL) {
  req <- request_base_anthropic(key) |>
    req_body_json(data = request_body) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE)

  if (is_true(stream)) {
    parser <- AnthropicStreamParser$new(
      session = shiny_session,
      user_prompt = user_prompt
    )

    response <-
      req |>
      req_perform_stream(
        callback = function(x) {
          element <- rawToChar(x)
          parser$parse_json(element)
          TRUE
        },
        round = "line",
        buffer_kb = 0.01
      )
    parser$value
  } else {
    response <-
      req |>
      req_perform()
    # error handling
    if (resp_is_error(response)) {
      status <- resp_status(response) # nolint
      description <- resp_status_desc(response) # nolint

      cli::cli_abort(c(
        "x" = "Anthropic API request failed. Error {status} - {description}",
        "i" = "Visit the Anthropic API documentation for more details"
      ))
    }
    response |>
      resp_body_json(simplifyVector = TRUE) |>
      purrr::pluck("content", "text")
  }
}

#' Generate text completions using Anthropic's API
#'
#' @param prompt The prompt for generating completions
#' @param system A system messages to instruct the model. Defaults to NULL.
#' @param model The model to use for generating text. By default, the
#'   function will try to use "claude-2.1".
#' @param max_tokens The maximum number of tokens to generate. Defaults to 256.
#' @param key The API key for accessing Anthropic's API. By default, the
#'   function will try to use the `ANTHROPIC_API_KEY` environment variable.
#' @param stream Whether to stream the response, defaults to FALSE.
#' @param element_callback A callback function to handle each element
#' of the streamed response (optional).
#' @param shiny_session A Shiny session object to send messages to the client
#' @param user_prompt A user prompt to send to the client
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' create_completion_anthropic(
#'   prompt = list(list(role = "user", content = "Hello")),
#'   model = "claude-3-haiku-20240307",
#'   max_tokens = 1028
#' )
#' }
#' @export
create_completion_anthropic <- function(prompt = list(list(role = "user", content = "Hello")),
                                        model = "claude-3-5-sonnet-20240620",
                                        max_tokens = 1028,
                                        key = Sys.getenv("ANTHROPIC_API_KEY"),
                                        stream = FALSE,
                                        system = NULL,
                                        element_callback = anthropic_handler,
                                        shiny_session = NULL,
                                        user_prompt = NULL) {
  request_body <- list(
    messages = prompt,
    model = model,
    max_tokens = max_tokens,
    system = system,
    stream = stream
  ) |> purrr::compact()

  query_api_anthropic(
    request_body = request_body,
    key = key,
    stream = stream,
    element_callback = element_callback,
    shiny_session = shiny_session,
    user_prompt = user_prompt
  )
}

anthropic_handler <- function(x) {
  pattern = "\\{\"type\":\"content_block_delta\",.*\\}.*\\}"
  json <- stringr::str_extract(x, pattern)
  if (is.na(json)) return()
  a <- json |> jsonlite::parse_json()
  cat(a$delta$text)
}

AnthropicStreamParser <- R6::R6Class( # nolint
  classname = "AnthropicStreamParser",
  portable = TRUE,
  public = list(
    lines = NULL,
    value = NULL,
    shinySession = NULL,
    user_message = NULL,
    append_parsed_line = function(line) {
      self$value <- paste0(self$value, line$delta$text)
      self$lines <- c(self$lines, list(line))
      if (!is.null(self$shinySession)) {
        # any communication with JS should be handled here!!
        self$shinySession$sendCustomMessage(
          type = "render-stream",
          message = list(
            user = self$user_message,
            assistant = shiny::markdown(self$value)
          )
        )
      }
      invisible(self)
    },
    parse_json = function(x) { # nolint
      pattern = "\\{\"type\":\"content_block_delta\",.*\\}.*\\}"
      json <- stringr::str_extract(x, pattern)
      if (is.na(json)) return()
      self$append_parsed_line(json |> jsonlite::parse_json())
      invisible(self)
    },
    initialize = function(session = NULL, user_prompt = NULL) {
      self$lines <- list()
      self$shinySession <- session
      self$user_message <- shiny::markdown(user_prompt)
    }
  )
)
