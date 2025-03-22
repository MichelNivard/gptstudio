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
gptstudio_request_perform.default <- function(skeleton, ...,
                                                               shiny_session = NULL) {

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(
      skeleton_history = skeleton$history,
      last_user_message = skeleton$prompt
    )
  }

  # Translate request
  all_turns <- skeleton$history |>
    purrr::map(~ellmer::Turn(role = .x$role, contents = list(ellmer::ContentText(.x$content))))

  current_chat <- ellmer_chat(
    skeleton = skeleton,
    all_turns = all_turns
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
gptstudio_request_perform.gptstudio_request_huggingface <-
  function(skeleton, ...) {
    model <- skeleton$model
    prompt <- skeleton$prompt
    history <- skeleton$history
    cli_inform(c("i" = "Using HuggingFace API with {model} model"))
    response <- create_completion_huggingface(prompt, history, model)
    structure(
      list(
        skeleton = skeleton,
        response = response
      ),
      class = "gptstudio_response_huggingface"
    )
  }

#' @export
gptstudio_request_perform.gptstudio_request_anthropic <-
  function(skeleton, ...) {
    model <- skeleton$model

    skeleton$history <- chat_history_append(
      history = skeleton$history,
      role = "user",
      content = skeleton$prompt
    )

    # Anthropic does not have a system message, so convert it to user
    system <-
      purrr::keep(skeleton$history, function(x) x$role == "system") |>
      purrr::pluck("content")
    history <-
      purrr::keep(skeleton$history, function(x) x$role %in% c("user", "assistant"))

    cli_inform(c("i" = "Using Anthropic API with {model} model"))
    response <- create_completion_anthropic(
      prompt = history,
      system = system,
      model = model
    )
    structure(
      list(
        skeleton = skeleton,
        response = response
      ),
      class = "gptstudio_response_anthropic"
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

#' @export
gptstudio_request_perform.gptstudio_request_perplexity <-
  function(skeleton, ...) {
    model <- skeleton$model
    prompt <- skeleton$prompt
    cli_inform(c("i" = "Using Perplexity API with {model} model"))
    response <- create_completion_perplexity(
      prompt = prompt,
      model = model
    )
    structure(
      list(
        skeleton = skeleton,
        response = response$choices[[1]]$message$content
      ),
      class = "gptstudio_response_perplexity"
    )
  }

#' @export
gptstudio_request_perform.gptstudio_request_cohere <- function(skeleton, ...) {
  prompt <- skeleton$prompt
  model <- skeleton$model

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  cli_inform(c("i" = "Using Cohere API with {model} model"))
  response <- create_chat_cohere(
    prompt = prompt,
    model = model,
    api_key = skeleton$api_key
  )

  cli_alert_info("Response: {response}")

  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_cohere"
  )
}

Buffer <- R6::R6Class(
  classname = "Buffer",
  public = list(
    value = "",
    add_chunk = function(chunk) {
      self$value <- paste0(self$value, chunk)
    }
  )
)

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
