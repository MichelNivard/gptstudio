#' Perform API Request
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, PALM (MakerSuite)). It dispatches the actual API
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
gptstudio_request_perform.gptstudio_request_openai <- function(skeleton, shinySession = NULL, ...) {

  # Translate request

  # messages <- skeleton$history

  skeleton$history <- chat_history_append(
    history = skeleton$history,
    role = "user",
    name = "user_message",
    content = skeleton$prompt
  )

  docs <- read_docs(skeleton$prompt)

  if (!is.null(docs)) {
    purrr::walk(docs, ~{
      if (is.null(.x$inner_text)) return(NULL)
      skeleton$history <<- chat_history_append(
        history = skeleton$history,
        role = "user",
        content = docs_to_message(.x),
        name = "docs"
      )
    })
  }

  cli::cli_h3("Messages")
  str(skeleton$history)

  body <- list(
    "model"      = skeleton$model,
    "stream"     = skeleton$stream,
    "messages"   = skeleton$history,
    "max_tokens" = skeleton$extras$max_tokens,
    "n"          = skeleton$extra$n
  )

  # Create request
  request <- httr2::request(skeleton$url) %>%
    httr2::req_auth_bearer_token(skeleton$api_key) %>%
    httr2::req_body_json(body)

  # Perform request
  response <- NULL

  if (isTRUE(skeleton$stream)) {
    if (is.null(shinySession)) stop("Stream requires a shiny session object")

    stream_handler <- StreamHandler$new(
      session = shinySession,
      user_prompt = skeleton$prompt
    )

    # This should work exactly the same as stream_chat_completion
    # but it uses curl::curl_connection(partial=FALSE), which makes it
    # somehow different. `partial` has no documentation and can't be be changed

    # request %>%
    #  httr2::req_perform_stream(
    #    buffer_kb = 32,
    #    callback = function(x) {
    #      rawToChar(x) %>% stream_handler$handle_streamed_element()
    #      TRUE
    #    }
    #  )

    stream_chat_completion(
      messages = skeleton$history,
      element_callback = stream_handler$handle_streamed_element,
      model = skeleton$model,
      openai_api_key = skeleton$api_key
    )

    response <- stream_handler$current_value
  } else {
    response <- request %>%
      httr2::req_perform() %>%
      httr2::resp_body_json() %>%
      {.$choices[[1]]$message$content}
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
    model   <- skeleton$model
    prompt  <- skeleton$prompt
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
gptstudio_request_perform.gptstudio_request_palm <-
  function(skeleton, ...) {
    response <- create_completion_palm(prompt = skeleton$prompt)
    structure(
      list(
        skeleton = skeleton,
        response = response
      ),
      class = "gptstudio_response_palm"
    )
  }

#' @export
gptstudio_request_perform.gptstudio_request_anthropic <-
  function(skeleton, ...) {
    model   <- skeleton$model
    prompt  <- skeleton$prompt
    history <- skeleton$history
    cli_inform(c("i" = "Using Anthropic API with {model} model"))
    response <- create_completion_anthropic(prompt  = prompt,
                                            history = history,
                                            model   = model)
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

  body <- list("messages"   = messages)

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
gptstudio_request_perform.default <- function(skeleton, ...) {
  cli_abort(
    c("x" = "This API service is not implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}")
  )
}
