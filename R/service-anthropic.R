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
    shiny_session = shiny_session,
    user_prompt = user_prompt
  )
}

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
                                 shiny_session = NULL,
                                 user_prompt = NULL) {
  req <- request_base_anthropic(key) |>
    req_body_json(data = request_body) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE)

  if (is_true(stream)) {
    resp <- req_perform_connection(req, mode = "text")
    on.exit(close(resp))
    results <- list()
    repeat({
      event <- resp_stream_sse(resp)
      if (is.null(event) || event$data == "[DONE]") {
        break
      }
      json <- jsonlite::parse_json(event$data)
      results <- merge_dicts(results, json)
      if (!is.null(shiny_session)) {
        # any communication with JS should be handled here!!
        shiny_session$sendCustomMessage(
          type = "render-stream",
          message = list(
            user = user_prompt,
            assistant = shiny::markdown(results$delta$text)
          )
        )
      } else {
        cat(json$delta$text)
      }
    })
    invisible(results$delta$text)
  } else {
    response <- req |> req_perform()
    if (resp_is_error(response)) {
      status <- resp_status(response)
      description <- resp_status_desc(response)
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
