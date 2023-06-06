# Define the generic function
#' @export
call_api <- function(endoint, prompt, history = NULL, model = NULL, ...) {
  UseMethod("call_api")
}

# Define the method for OpenAI
#' @export
call_api.openai <- function(endpoint,
                            prompt,
                            history = NULL,
                            model = NULL,
                            element_callback,
                            style,
                            skill) {
  cli_inform(c("i" = "Using OpenAI API"))
  if (is.null(model)) model <- getOption("gptstudio.chat_model")
  stream_chat_completion(
    prompt = prompt,
    history = history,
    element_callback = element_callback,
    style = style,
    skill = skill,
    model = model
  )
}

# Define the method for HuggingFace
#' @export
call_api.huggingface <- function(prompt, history = NULL, model = "gpt2", ...) {
  if (is.null(model)) model <- getOption("gptstudio.hf_model")
  cli_inform(c("i" = "Using HuggingFace API"))
  model = "gpt2"
  answer <- hf_create_completion(prompt = prompt, model = model)
  cat_print(answer[[1]]$generated_text)
  answer[[1]]$generated_text
}

# Define the method for MakerSuite
#' @export
call_api.makersuite <- function(prompt, ...) {
  # Your code for calling the MakerSuite API goes here
  cli_warn("MakerSuite API calls are not yet implemented")
}

#' @export
call_api.default <- function(prompt, ...) {
  cli_abort(
    c("x" = "This API service is not been implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}")
  )
}
