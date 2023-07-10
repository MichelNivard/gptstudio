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
gptstudio_request_perform.gptstudio_request_openai <- function(skeleton, ...) {

  url        <- skeleton$url
  api_key    <- skeleton$api_key
  prompt     <- skeleton$prompt
  history    <- skeleton$history
  stream     <- skeleton$stream
  model      <- skeleton$model
  max_tokens <- skeleton$extras$max_tokens
  n          <- skeleton$extra$n

  # Translate request
  messages <- c(
    skeleton$history,
    list(
      list(role = "user", content = skeleton$prompt)
    )
  )

  body <- list(
    "model"      = model,
    "stream"     = stream,
    "messages"   = messages,
    "max_tokens" = max_tokens,
    "n"          = n
  )

  # Perform request
  response <- NULL

  if (!is.null(skeleton$stream)) {
    response <- stream_chat_completion(prompt = messages,
                                       model = model)
  } else {
    response <- httr2::request(url) %>%
      httr2::req_auth_bearer_token(api_key) %>%
      httr2::req_body_json(body) %>%
      httr2::req_perform() %>%
      httr2::resp_body_json()
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
