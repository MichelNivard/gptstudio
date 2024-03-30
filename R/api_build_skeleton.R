#' Construct a GPT Studio request skeleton.
#'
#' @param skeleton A GPT Studio request skeleton object.
#' @param style The style of code to use. Applicable styles can be retrieved
#'   from the "gptstudio.code_style" option. Default is the
#'   "gptstudio.code_style" option. Options are "base", "tidyverse", or "no
#'   preference".
#' @param skill The skill level of the user for the chat conversation. This can
#'   be set through the "gptstudio.skill" option. Default is the
#'   "gptstudio.skill" option. Options are "beginner", "intermediate",
#'   "advanced", and "genius".
#' @param task Specifies the task that the assistant will help with. Default is
#'   "coding". Others are "general", "advanced developer", and "custom".
#' @param custom_prompt This is a custom prompt that may be used to guide the AI
#'   in its responses. Default is NULL. It will be the only content provided to
#'   the system prompt.
#' @param ... Additional arguments.
#'
#' @return An updated GPT Studio request skeleton.
#'
#' @export
gptstudio_skeleton_build <- function(skeleton, skill, style, task, custom_prompt, ...) {
  UseMethod("gptstudio_skeleton_build")
}

#' @export
gptstudio_skeleton_build.gptstudio_request_openai <-
  function(skeleton = gptstudio_create_skeleton(),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_openai(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_huggingface <-
  function(skeleton = gptstudio_create_skeleton("huggingface"),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_huggingface(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_anthropic <-
  function(skeleton = gptstudio_create_skeleton("anthropic"),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_anthropic(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_google <-
  function(skeleton = gptstudio_create_skeleton("google"),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_google(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_azure_openai <-
  function(skeleton = gptstudio_create_skeleton(),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_azure_openai(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_ollama <-
  function(skeleton = gptstudio_create_skeleton(),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_ollama(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_perplexity <-
  function(skeleton = gptstudio_create_skeleton("perplexity"),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_perplexity(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }

#' @export
gptstudio_skeleton_build.gptstudio_request_cohere <-
  function(skeleton = gptstudio_create_skeleton(),
           skill = getOption("gptstudio.skill"),
           style = getOption("gptstudio.code_style"),
           task = "coding",
           custom_prompt = NULL,
           ...) {
    prompt <- skeleton$prompt
    history <- skeleton$history
    model <- skeleton$model
    stream <- skeleton$stream
    new_history <- prepare_chat_history(history, style, skill, task, custom_prompt)

    new_gptstudio_request_skeleton_cohere(
      model = model,
      prompt = prompt,
      history = new_history,
      stream = stream
    )
  }
