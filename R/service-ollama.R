ollama_api_url <- function() {
  Sys.getenv("OLLAMA_HOST", "http://localhost:11434")
}

ollama_set_task <- function(task) {
  ollama_api_url() %>%
    request() %>%
    req_url_path_append("api") %>%
    req_url_path_append(task)
}

ollama_list <- function() {
  ollama_set_task("tags") %>%
    req_perform() %>%
    resp_body_json()
}

ollama_is_available <- function(verbose = FALSE) {
  request <- ollama_api_url() %>%
    request()

  check_value <- logical(1)

  rlang::try_fetch(
    {
      response <- req_perform(request) %>%
        resp_body_string()

      if (verbose) cli::cli_alert_success(response)
      check_value <- TRUE
    },
    error = function(cnd) {
      if (inherits(cnd, "httr2_failure")) {
        if (verbose) cli::cli_alert_danger("Couldn't connect to Ollama in {.url {ollama_api_url()}}. Is it running there?") # nolint
      } else {
        if (verbose) cli::cli_alert_danger(cnd)
      }
      check_value <- FALSE # nolint
    }
  )

  invisible(check_value)
}

body_to_json_str <- function(x) {
  to_json_params <- rlang::list2(x = x$data, !!!x$params)
  do.call(jsonlite::toJSON, to_json_params)
}


ollama_perform_stream <- function(request, parser) {
  request_body <- request %>%
    purrr::pluck("body")

  request_url <- request %>%
    purrr::pluck("url")

  request_handle <- curl::new_handle() %>%
    curl::handle_setopt(postfields = body_to_json_str(request_body))

  curl_response <- curl::curl_fetch_stream(
    url = request_url,
    handle = request_handle,
    fun = function(x) parser$parse_ndjson(rawToChar(x))
  )

  response_json(
    url = curl_response$url,
    method = "POST",
    body = list(response = parser$lines)
  )
}

ollama_chat <- function(model, messages, stream = TRUE, shiny_session = NULL, user_prompt = NULL) {
  body <- list(
    model = model,
    messages = messages,
    stream = stream
  )

  request <- ollama_set_task("chat") %>%
    req_body_json(data = body)


  if (stream) {
    parser <- OllamaStreamParser$new(
      session = shiny_session,
      user_prompt = user_prompt
    )

    ollama_perform_stream(
      request = request,
      parser = parser
    )

    last_line <- parser$lines[[length(parser$lines)]]

    last_line$message <- list(
      role = "assistant",
      content = parser$value
    )

    last_line
  } else {
    request %>%
      req_perform() %>%
      resp_body_json()
  }
}

OllamaStreamParser <- R6::R6Class( # nolint
  classname = "OllamaStreamParser",
  portable = TRUE,
  public = list(
    lines = NULL,
    value = NULL,
    shinySession = NULL,
    user_message = NULL,
    append_parsed_line = function(line) {
      self$value <- paste0(self$value, line$message$content)
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
    parse_ndjson = function(ndjson, pagesize = 500, verbose = FALSE, simplifyDataFrame = FALSE) { # nolint
      jsonlite::stream_in(
        con = textConnection(ndjson),
        pagesize = pagesize,
        verbose = verbose,
        simplifyDataFrame = simplifyDataFrame,
        handler = function(x) lapply(x, self$append_parsed_line)
      )

      invisible(self)
    },
    initialize = function(session = NULL, user_prompt = NULL) {
      self$lines <- list()
      self$shinySession <- session
      self$user_message <- shiny::markdown(user_prompt)
    }
  )
)
