#' Perform API Request
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
#' calls to the relevant method based on the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_request_skeleton` object
#' @param ... Extra arguments (e.g., `stream_handler`)
#'
#' @return A `gptstudio_response_skeleton` object
#'
#' @examples
#' \dontrun{
#' gptstudio_request_perform(gptstudio_skeleton)
#' }
#' @export
gptstudio_request_perform <- function(skeleton, ...) {
  if (!inherits(skeleton, "gptstudio_request_skeleton")) {
    cli::cli_abort("Skeleton must be a 'gptstudio_request_skeleton' or a child class")
  }
  UseMethod("gptstudio_request_perform")
}

#' @export
gptstudio_request_perform.default <- function(skeleton, ..., shiny_session = NULL) {

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
  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_openai"
  )
}

#' @export
gptstudio_request_perform.gptstudio_request_azure_openai <- function(skeleton,
                                                                     shiny_session = NULL,
                                                                     ...) {

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  if (isTRUE(skeleton$stream)) {
    if (is.null(shiny_session)) stop("Stream requires a shiny session object")

    stream_handler <- OpenaiStreamParser$new(
      session = shiny_session,
      user_prompt = skeleton$prompt
    )

    stream_azure_openai(
      messages = skeleton$history,
      element_callback = stream_handler$parse_sse
    )

    response <- stream_handler$value
  } else {
    response <- query_api_azure_openai(request_body = skeleton$history)
    response <- response$choices[[1]]$message$content
  }

  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_azure_openai"
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
  ellmer::chat_openai(
    turns = all_turns,
    base_url = getOption("gptstudio.openai_url"),
    api_key = skeleton$api_key,
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_google <- function(skeleton, all_turns) {
  ellmer::chat_gemini(
    turns = all_turns,
    api_key = skeleton$api_key,
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_ollama <- function(skeleton, all_turns) {
  ellmer::chat_ollama(
    turns = all_turns,
    base_url = Sys.getenv("OLLAMA_HOST", unset = "http://localhost:11434"),
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_anthropic <- function(skeleton, all_turns) {
  ellmer::chat_claude(
    turns = all_turns,
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_perplexity <- function(skeleton, all_turns) {
  ellmer::chat_perplexity(
    turns = all_turns,
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_huggingface <- function(skeleton, all_turns) {
  # huggingface API is not compatible with system prompts
  skeleton$history <- skeleton$history |>
    purrr::discard(~.x$role == "system")

  cli::cli_alert_warning(
    "Discarding system propmt because of incompatibility with Huggingface API"
  )

  ellmer::chat_openai(
    turns = history_to_turns_list(skeleton$history),
    base_url = "https://router.huggingface.co/hf-inference/v1",
    api_key = skeleton$api_key,
    model = skeleton$model
  )
}

#' @export
ellmer_chat.gptstudio_request_cohere <- function(skeleton, all_turns) {
  ellmer::chat_openai(
    turns = all_turns,
    base_url = "https://api.cohere.ai/compatibility/v1",
    api_key = skeleton$api_key,
    model = skeleton$model,
    api_args = list(
      stream_options = NULL # the Cohere API doesn't support this options
    )
  )
}
