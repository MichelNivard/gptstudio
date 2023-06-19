#' Construct a GPT Studio request skeleton.
#'
#' @param skeleton A GPT Studio request skeleton object.
#' @param skill A parameter that affects the style of the chat conversation.
#' @param style A parameter that affects the style of the chat conversation.
#' @param ... Additional arguments.
#'
#' @return An updated GPT Studio request skeleton.
#'
#' @export
gptstudio_skeleton_build <- function(skeleton, skill, style, ...) {
  UseMethod("gptstudio_skeleton_build")
}

#' @export
gptstudio_skeleton_build.gptstudio_request_openai <-
  function(skeleton, skill, style, ...) {
    prompt      <- skeleton$prompt
    history     <- skeleton$history
    model       <- skeleton$model
    stream      <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill)

    new_gptstudio_request_skeleton_openai(model   = model,
                                          prompt  = prompt,
                                          history = new_history,
                                          stream  = stream)
  }


#' @export
gptstudio_skeleton_build.gptstudio_request_huggingface <-
  function(skeleton, skill, style, ...) {
    prompt         <- skeleton$prompt
    history        <- skeleton$history
    model          <- skeleton$model
    stream         <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill)

    new_gptstudio_request_skeleton_huggingface(model   = model,
                                               prompt  = prompt,
                                               history = new_history,
                                               stream  = stream)
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_anthropic <-
  function(skeleton, skill, style, ...) {
    prompt         <- skeleton$prompt
    history        <- skeleton$history
    model          <- skeleton$model
    stream         <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill)

    new_gptstudio_request_skeleton_anthropic(model   = model,
                                             prompt  = prompt,
                                             history = new_history,
                                             stream  = stream)
  }
