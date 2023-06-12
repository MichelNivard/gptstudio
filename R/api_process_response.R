#' Call API
#'
#' This function provides a generic interface for calling different APIs
#' (e.g., OpenAI, HuggingFace, PALM (MakerSuite)). It dispatches the actual API
#' calls to the relevant method based on the `class` of the `skeleton` argument.
#'
#' @param skeleton A `gptstudio_response_skeleton` object
#'
#' @return A `gptstudio_request_skeleton` with updated history and prompt removed
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
    skeleton <- skeleton$skeleton
    last_response <- gptstudio_get_last_response(x) # another nice generic to have

    new_history <- c(
      skeleton$history,
      list(
        list(role = "user", content = skeleton$prompt),
        list(role = "assistant", content = last_response)
      )
    )

    skeleton$history <- new_history
    skeleton$prompt <- NULL # remove the last prompt

    # return value
    skeleton
}
