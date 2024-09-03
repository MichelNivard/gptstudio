#' Generate text using Ollama's API
#'
#' @description Use this function to generate text completions using Ollama's API.
#'
#' @param prompt A list of messages to use as the prompt for generating completions.
#'   Each message should be a list with 'role' and 'content' elements.
#' @param model A character string for the model to use.
#' @param api_url A character string for the API url. It defaults to the Ollama
#'   host from environment variables or "http://localhost:11434" if not specified.
#' @param stream Whether to stream the response, defaults to FALSE.
#' @param shiny_session A Shiny session object to send messages to the client
#' @param user_prompt A user prompt to send to the client
#'
#' @return The generated completion as a character string, or the full response if streaming.
#'
#' @export
create_chat_ollama <- function(prompt = list(list(role = "user", content = "Hello")),
                               model = "llama3.1:latest",
                               api_url = Sys.getenv("OLLAMA_HOST", "http://localhost:11434"),
                               stream = FALSE,
                               shiny_session = NULL,
                               user_prompt = NULL) {
  request_body <- list(
    model = model,
    messages = prompt,
    stream = stream
  ) |> purrr::compact()

  query_api_ollama(
    request_body = request_body,
    api_url = api_url,
    stream = stream,
    shiny_session = shiny_session,
    user_prompt = user_prompt
  )
}

request_base_ollama <- function(api_url = Sys.getenv("OLLAMA_HOST", "http://localhost:11434")) {
  request(api_url) |>
    req_url_path_append("api") |>
    req_url_path_append("chat")
}

query_api_ollama <- function(request_body,
                             api_url = Sys.getenv("OLLAMA_HOST", "http://localhost:11434"),
                             stream = FALSE,
                             shiny_session = NULL,
                             user_prompt = NULL) {
  req <- request_base_ollama(api_url) |>
    req_body_json(data = request_body) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE)

  if (is_true(stream)) {
    resp <- req |> req_perform_connection(mode = "text")
    on.exit(close(resp))
    results <- list()
    repeat({
      event <- resp_stream_lines(resp)
      json <- jsonlite::parse_json(event)
      if (is_true(json$done)) {
        break
      }
      results <- merge_dicts(results, json)
      if (!is.null(shiny_session)) {
        # any communication with JS should be handled here!!
        shiny_session$sendCustomMessage(
          type = "render-stream",
          message = list(
            user = user_prompt,
            assistant = shiny::markdown(results$message$content)
          )
        )
      } else {
        cat(json$message$content)
      }
    })
    invisible(results$message$content)
  } else {
    resp <- req |> req_perform()
    if (resp_is_error(resp)) {
      status <- resp_status(resp)
      description <- resp_status_desc(resp)
      cli::cli_abort(c(
        "x" = "Ollama API request failed. Error {status} - {description}",
        "i" = "Check your Ollama setup and try again."
      ))
    }
    results <- resp |> resp_body_json()
    results$message$content
  }
}

# Helper functions
ollama_list <- function(api_url = Sys.getenv("OLLAMA_HOST", "http://localhost:11434")) {
  request(api_url) |>
    req_url_path_append("api") |>
    req_url_path_append("tags") |>
    req_perform() |>
    resp_body_json()
}

ollama_is_available <- function(api_url = Sys.getenv("OLLAMA_HOST", "http://localhost:11434"), verbose = FALSE) {
  check_value <- logical(1)
  rlang::try_fetch(
    {
      response <- request(api_url) |>
        req_perform() |>
        resp_body_string()
      if (verbose) cli::cli_alert_success(response)
      check_value <- TRUE
    },
    error = function(cnd) {
      if (inherits(cnd, "httr2_failure")) {
        if (verbose) cli::cli_alert_danger("Couldn't connect to Ollama in {.url {api_url}}. Is it running there?")
      } else {
        if (verbose) cli::cli_alert_danger(cnd)
      }
      check_value <- FALSE
    }
  )
  invisible(check_value)
}
