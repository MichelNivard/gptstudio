#' Call API
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, PALM (MakerSuite)). It dispatches the actual API
#' calls to the relevant method based on the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_request_skeleton` object
#'
#' @return A `gptstudio_response_skeleton` object
#'
#' @examples
#' \dontrun{
#' gptstudio_request_perform(gptstudio_skeleton)
#' }
#' @export
gptstudio_request_perform <- function(skeleton, ...) {
  UseMethod("gptstudio_request_perform")
}


#' @export
gptstudio_request_perform.gptstudio_request_openai <- function(x, ...) {

  # Translate request
  messages <- c(
    x$history,
    list(
      list(role = "user", content = x$prompt)
    )
  )

  body <- list(
    "model" = x$model,
    "stream" = TRUE,
    "messages" = messages,
    "max_tokens" = x$extra$max_tokens,
    "n" = x$extra$n
  )

  # Perform request
  response <- NULL

  if (x$stream) {
    assertthat::assert_that(!is.null(stream_handler),
                            msg = "This request needs a stream handler")

    headers <- list(
      "Content-Type" = "application/json",
      "Authorization" = paste0("Bearer ", x$api_key)
    )

    handle <- curl::new_handle() |>
      curl::handle_setheaders(.list = headers) |>
      curl::handle_setopt(
        postfields = jsonlite::toJSON(body, auto_unbox = TRUE)
      )

    curl::curl_fetch_stream(
      url = x$url,
      fun = \(i) {
        element <- rawToChar(i)
        # this method could communicate with a shiny session
        stream_handler$handle_streamed_element(element)
      },
      handle = handle
    )

    # this doesn't exist yet, but you get the idea
    response <- stream_handler$response_value()

  } else {

    response <- httr2::request(x$url) |>
      httr2::req_auth_bearer_token(x$api_key) |>
      httr2::req_body_json(body) |>
      httr2::req_perform()
  }

  # return value
  structure(
    list(
      skeleton = x,
      response = response
    ),
    class = "llm_response_openai"
  )
}

#' @export
gptstudio_request_perform.gptstudio_request_huggingface <- function(skeleton) {
  cli_inform(c("i" = "Using HuggingFace API"))
  model <- if (is.null(model)) getOption("gptstudio.hf_model") else model
  answer <- create_completion_hf(prompt = prompt, model = model)
  cat_print(answer[[1]]$generated_text)
  answer[[1]]$generated_text
}

#' @export
gptstudio_request_perform.gptstudio_request_palm <- function(skeleton, ...) {
  create_completion_palm(prompt = prompt)
}

#' @export
gptstudio_request_perform.gptstudio_request_anthropic <- function(skeleton, ...) {
  create_completion_anthropic(prompt = prompt)
}

#' @export
gptstudio_request_perform.default <- function(skeleton, ...) {
  cli_abort(
    c("x" = "This API service is not implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}")
  )
}
