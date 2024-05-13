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

  body <- list(
    "model"      = skeleton$model,
    "stream"     = skeleton$stream,
    "messages"   = skeleton$history,
    "max_tokens" = skeleton$extras$max_tokens,
    "n"          = skeleton$extra$n
  )

  # Create request
  request <- request(skeleton$url) %>%
    req_auth_bearer_token(skeleton$api_key) %>%
    req_body_json(body)

  # Perform request
  response <- NULL

  if (isTRUE(skeleton$stream)) {
    if (is.null(shiny_session)) stop("Stream requires a shiny session object")

    stream_handler <- OpenaiStreamParser$new(
      session = shiny_session,
      user_prompt = skeleton$prompt
    )

    stream_chat_completion(
      messages = skeleton$history,
      element_callback = stream_handler$parse_sse,
      model = skeleton$model,
      openai_api_key = skeleton$api_key
    )

    response <- stream_handler$value
  } else {
    response_json <- request %>%
      req_perform() %>%
      resp_body_json()

    response <- response_json$choices[[1]]$message$content
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
gptstudio_request_perform.gptstudio_request_google <-
  function(skeleton, ...) {
    response <- create_completion_google(prompt = skeleton$prompt)
    structure(
      list(
        skeleton = skeleton,
        response = response
      ),
      class = "gptstudio_response_google"
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
      purrr::keep(skeleton$history, function(x) x$role == "system") %>%
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
gptstudio_request_perform.gptstudio_request_azure_openai <- function(skeleton, ...) {
  messages <- c(
    skeleton$history,
    list(
      list(role = "user", content = skeleton$prompt)
    )
  )

  body <- list("messages" = messages)

  cat_print(body)

  response <- create_completion_azure_openai(prompt = body)
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

  response <- ollama_chat(
    model = skeleton$model,
    messages = skeleton$history,
    stream = skeleton$stream,
    shiny_session = shiny_session,
    user_prompt = skeleton$prompt
  )

  # return value
  structure(
    list(
      skeleton = skeleton,
      response = response$message$content
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
