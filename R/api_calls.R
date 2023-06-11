#' Call API
#'
#' This function provides a generic interface for calling different AI APIs (OpenAI, HuggingFace, MakerSuite).
#' It dispatches the actual API calls to the relevant method based on the `class` of the `endpoint` argument.
#'
#' @param endpoint A character string defining the API endpoint. The class of this argument determines the method to be used.
#' @param prompt A character string containing the input for the AI model.
#' @param history A character string or a list of strings providing the conversational history for context (defaults to NULL).
#' @param model A character string specifying the AI model to be used (defaults to NULL, which means the default model for each API is used).
#' @param style A character string defining the model's writing style (only applicable to some APIs; defaults to NULL).
#' @param skill A numeric value indicating the skill level of the AI model (only applicable to some APIs; defaults to NULL).
#' @param ... Additional arguments passed on to the method.
#'
#' @return Depends on the method. Could be a character string (response from the AI), a list (structured response), or NULL (in case of unimplemented services).
#'
#' @examples
#' \dontrun{
#' call_api("openai", "Hello, how are you?")
#' }
#' @export
call_api <- function(endpoint,
                     prompt,
                     history = NULL,
                     model = NULL,
                     style = NULL,
                     skill = NULL,
                     ...) {
  UseMethod("call_api")
}

#' @export
call_api.openai <- function(endpoint,
                            prompt,
                            history = NULL,
                            model = NULL,
                            element_callback = NULL,
                            style = NULL,
                            skill = NULL) {
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

#' @export
call_api.huggingface <- function(endpoint,
                                 prompt,
                                 history = NULL,
                                 model = "gpt2",
                                 ...) {
  cli_inform(c("i" = "Using HuggingFace API"))
  model <- if (is.null(model)) getOption("gptstudio.hf_model") else model
  answer <- create_completion_hf(prompt = prompt, model = model)
  cat_print(answer[[1]]$generated_text)
  answer[[1]]$generated_text
}

#' @export
call_api.palm <- function(endpoint,
                          prompt,
                          ...) {
  create_completion_palm(prompt = prompt)
}

#' @export
call_api.anthropic <- function(endpoint,
                               prompt,
                               ...) {
  create_completion_anthropic(prompt = prompt)
}

#' @export
call_api.default <- function(endpoint,
                             prompt,
                             ...) {
  cli_abort(
    c("x" = "This API service is not implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}")
  )
}
