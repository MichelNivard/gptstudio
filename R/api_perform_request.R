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
gptstudio_request_perform.gptstudio_request_openai <- function(skeleton, ...,
                                                               shiny_session = NULL) {

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(skeleton$history)
  }

  response <- create_chat_openai(prompt = skeleton$history,
                                 model = skeleton$model,
                                 stream = skeleton$stream,
                                 shiny_session = shiny_session,
                                 user_prompt = skeleton$prompt)

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
gptstudio_request_perform.gptstudio_request_google <- function(skeleton, ...) {
  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(skeleton$history)
  }

  response <- create_chat_google(prompt = skeleton$history,
                                 model = skeleton$model)

  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_google"
  )
}

#' @export
gptstudio_request_perform.gptstudio_request_anthropic <- function(skeleton,
                                                                  shiny_session = NULL,
                                                                  ...) {
  model  <- skeleton$model
  stream <- skeleton$stream
  prompt <- skeleton$prompt

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
    model = model,
    stream = stream,
    shiny_session = shiny_session,
    user_prompt = prompt
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

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(skeleton$history)
  }

  response <- create_chat_azure_openai(prompt = skeleton$history,
                                       model = skeleton$model,
                                       stream = skeleton$stream,
                                       shiny_session = shiny_session,
                                       user_prompt = skeleton$prompt)

  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_azure_openai"
  )
}

#' @export
gptstudio_request_perform.gptstudio_request_ollama <- function(skeleton, ...,
                                                               shiny_session = NULL) {
  # Translate request

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  if (getOption("gptstudio.read_docs")) {
    skeleton$history <- add_docs_messages_to_history(skeleton$history)
  }

  response <- create_chat_ollama(
    model = skeleton$model,
    prompt = skeleton$history,
    stream = skeleton$stream,
    shiny_session = shiny_session,
    user_prompt = skeleton$prompt
  )

  # return value
  structure(
    list(
      skeleton = skeleton,
      response = response
    ),
    class = "gptstudio_response_ollama"
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

#' @export
gptstudio_request_perform.default <- function(skeleton, ...) {
  cli_abort(
    c(
      "x" = "This API service is not implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}"
    )
  )
}
