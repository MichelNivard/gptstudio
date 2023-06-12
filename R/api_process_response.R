#' Call API
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, PALM (MakerSuite)). It dispatches the actual API
#' calls to the relevant method based on the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_response_skeleton` object
#'
#' @return A character string object
#'
#' @examples
#' \dontrun{
#' gptstudio_request_perform(gptstudio_skeleton)
#' }
#' @export
gptstudio_process_response <- function(skeleton, ...) {
  UseMethod("gptstudio_process_response")
}

#' @export
gptstudio_process_response.openai <- function(skeleton, ...) {
  cli_inform(c("i" = "Using OpenAI API"))
  model <- if (is.null(model)) getOption("gptstudio.chat_model") else model
  stream_chat_completion(
    prompt = prompt,
    history = history,
    element_callback = element_callback,
    style = style,
    skill = skill,
    model = model
  )
}
