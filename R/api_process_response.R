#' Call API
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
#' calls to the relevant method based on the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_response_skeleton` object
#' @param ... Extra arguments, not currently used
#'
#' @return A `gptstudio_request_skeleton` with updated history and prompt removed
#'
#' @examples
#' \dontrun{
#' gptstudio_response_process(gptstudio_skeleton)
#' }
#' @export
gptstudio_response_process <- function(skeleton, ...) {
  UseMethod("gptstudio_response_process")
}

#' @export
gptstudio_response_process.gptstudio_response_openai <- function(skeleton, ...) {
    last_response <- skeleton$response
    skeleton <- skeleton$skeleton

    new_history <- chat_history_append(
      history = skeleton$history,
      role = "assistant",
      name = "assistant",
      content = last_response
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt
    class(skeleton) <- c(
      "gptstudio_request_skeleton",
      "gptstudio_request_openai"
    )
    skeleton
  }

#' @export
gptstudio_response_process.gptstudio_response_huggingface <- function(skeleton, ...) {
    response <- skeleton$response
    skeleton <- skeleton$skeleton
    last_response <- response[[1]]$generated_text

    new_history <- c(
      skeleton$history,
      list(
        list(role = "user", content = skeleton$prompt),
        list(role = "assistant", content = last_response)
      )
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt
    class(skeleton) <- c(
      "gptstudio_request_skeleton",
      "gptstudio_request_huggingface"
    )
    skeleton
  }

#' @export
gptstudio_response_process.gptstudio_response_anthropic <- function(skeleton, ...) {
    last_response <- skeleton$response
    skeleton <- skeleton$skeleton

    new_history <- chat_history_append(
      history = skeleton$history,
      role = "assistant",
      content = last_response
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt
    class(skeleton) <- c(
      "gptstudio_request_skeleton",
      "gptstudio_request_anthropic"
    )

    skeleton
  }

#' @export
gptstudio_response_process.gptstudio_response_google <- function(skeleton, ...) {
  last_response <- skeleton$response
  skeleton <- skeleton$skeleton

  new_history <- chat_history_append(
    history = skeleton$history,
    role = "assistant",
    content = last_response
  )

  skeleton$history <- new_history
  skeleton$prompt <- NULL # remove the last prompt
  class(skeleton) <- c(
    "gptstudio_request_skeleton",
    "gptstudio_request_google"
  )
  skeleton
}

#' @export
gptstudio_response_process.gptstudio_response_azure_openai <- function(skeleton, ...) {
    last_response <- skeleton$response
    skeleton <- skeleton$skeleton

    new_history <- chat_history_append(
      history = skeleton$history,
      role = "assistant",
      name = "assistant",
      content = last_response
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt
    class(skeleton) <- c(
      "gptstudio_request_skeleton",
      "gptstudio_request_azure_openai"
    )
    skeleton
  }

#' @export
gptstudio_response_process.gptstudio_response_ollama <- function(skeleton, ...) {
  last_response <- skeleton$response
  skeleton <- skeleton$skeleton

  new_history <- chat_history_append(
    history = skeleton$history,
    role = "assistant",
    name = "assistant",
    content = last_response
  )

  skeleton$history <- new_history
  skeleton$prompt <- NULL # remove the last prompt
  class(skeleton) <- c(
    "gptstudio_request_skeleton",
    "gptstudio_request_ollama"
  )
  skeleton
}

#' @export
gptstudio_response_process.gptstudio_response_perplexity <- function(skeleton, ...) {
    response <- skeleton$response
    skeleton <- skeleton$skeleton

    new_history <- c(
      skeleton$history,
      list(
        list(role = "user", content = skeleton$prompt),
        list(role = "assistant", content = response)
      )
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt
    class(skeleton) <- c(
      "gptstudio_request_skeleton",
      "gptstudio_request_perplexity"
    )
    skeleton
  }

#' @export
gptstudio_response_process.gptstudio_response_cohere <- function(skeleton, ...) {
  last_response <- skeleton$response
  skeleton <- skeleton$skeleton

  new_history <- chat_history_append(
    history = skeleton$history,
    role = "assistant",
    name = "assistant",
    content = last_response
  )

  skeleton$history <- new_history
  skeleton$prompt <- NULL # remove the last prompt
  class(skeleton) <- c(
    "gptstudio_request_skeleton",
    "gptstudio_request_cohere"
  )

  skeleton
}
