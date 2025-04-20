#' Perform API Request
#'
#' This function provides a wrapper for calling different APIs
#' (e.g., OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
#' calls to the relevant {ellmer} method.
#'
#' @param skeleton A `gptstudio_request_skeleton` object
#' @param shiny_session Shiny session to send messages to. Only relevant when skeleton$stream is TRUE.
#'
#' @return A list with a skeleton and and the last response
#'
gptstudio_request_perform <- function(skeleton, shiny_session = NULL) {

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(
      skeleton_history = skeleton$history,
      last_user_message = skeleton$prompt
    )
  }

  # Translate request
  current_chat <- ellmer_chat(
    skeleton = skeleton,
    all_turns = history_to_turns_list(skeleton$history)
  )

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  # Perform request
  response <- NULL

  if (isTRUE(skeleton$stream)) {
    if (is.null(shiny_session)) stop("Stream requires a shiny session object")

    message_buffer <- Buffer$new()
    stream <- current_chat$stream(skeleton$prompt)

    coro::loop(for (chunk in stream) {
      message_buffer$add_chunk(chunk)

      shiny_session$sendCustomMessage(
        type = "render-stream",
        message = list(
          user = skeleton$prompt,
          assistant = shiny::markdown(message_buffer$value)
        )
      )
    })

    response <- message_buffer$value

  } else {
    response <- current_chat$chat(skeleton$prompt)
  }
  # return value
  list(
    skeleton = skeleton,
    response = response
  )
}

Buffer <- R6::R6Class( # nolint: object_name_linter
  classname = "Buffer",
  public = list(
    value = "",
    add_chunk = function(chunk) {
      self$value <- paste0(self$value, chunk)
    }
  )
)

history_to_turns_list <- function(skeleton_history) {
  skeleton_history |>
    purrr::map(~ellmer::Turn(role = .x$role, contents = list(ellmer::ContentText(.x$content))))
}

#' Create Chat Client for Different API Providers
#'
#' This function provides a generic interface for creating chat clients
#' for different API providers (e.g., OpenAI, HuggingFace, Google AI Studio).
#' It dispatches the actual client creation to the relevant method based on
#' the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_request_skeleton` object containing API configuration
#' @param all_turns A list of conversation turns formatted for the ellmer package
#'
#' @return An ellmer chat client object for the specific API provider
#'
#' @export
ellmer_chat <- function(skeleton, all_turns) {
  if (!inherits(skeleton, "gptstudio_request_skeleton")) {
    cli::cli_abort("Skeleton must be a 'gptstudio_request_skeleton' or a child class")
  }
  UseMethod("ellmer_chat")
}


#' @export
ellmer_chat.default <- function(skeleton, ...) {
  cli_abort(
    c(
      "x" = "This API service is not implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}"
    )
  )
}

#' @export
ellmer_chat.gptstudio_request_openai <- function(skeleton, all_turns) {
  chat <- ellmer::chat_openai(
    base_url = getOption("gptstudio.openai_url"),
    api_key = skeleton$api_key,
    model = skeleton$model
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_google <- function(skeleton, all_turns) {
  chat <- ellmer::chat_gemini(
    api_key = skeleton$api_key,
    model = skeleton$model
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_ollama <- function(skeleton, all_turns) {
  chat <- ellmer::chat_ollama(
    base_url = Sys.getenv("OLLAMA_HOST", unset = "http://localhost:11434"),
    model = skeleton$model
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_anthropic <- function(skeleton, all_turns) {
  chat <- ellmer::chat_claude(
    model = skeleton$model
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_perplexity <- function(skeleton, all_turns) {
  chat <- ellmer::chat_perplexity(
    model = skeleton$model
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_huggingface <- function(skeleton, all_turns) {
  # huggingface API is not compatible with system prompts
  skeleton$history <- skeleton$history |>
    purrr::discard(~.x$role == "system")

  cli::cli_alert_warning(
    "Discarding system propmt because of incompatibility with Huggingface API"
  )

  chat <- ellmer::chat_huggingface(
    api_key = skeleton$api_key,
    model = skeleton$model
  )

  chat$set_turns(history_to_turns_list(skeleton$history))
}

#' @export
ellmer_chat.gptstudio_request_cohere <- function(skeleton, all_turns) {
  chat <- ellmer::chat_openai(
    base_url = "https://api.cohere.ai/compatibility/v1",
    api_key = skeleton$api_key,
    model = skeleton$model,
    api_args = list(
      stream_options = NULL # the Cohere API doesn't support this options
    )
  )

  chat$set_turns(all_turns)
}

#' @export
ellmer_chat.gptstudio_request_azure_openai <- function(skeleton, all_turns) {
  # Extract Azure-specific configuration from skeleton
  endpoint <- skeleton$endpoint
  deployment_id <- skeleton$deployment_id
  api_version <- skeleton$api_version %||% "2024-10-21"

  chat <- ellmer::chat_azure(
    endpoint = endpoint,
    deployment_id = deployment_id,
    api_version = api_version,
    api_key = skeleton$api_key,
    credentials = skeleton$credentials
  )

  chat$set_turns(all_turns)
}
