# Define the generic function
api_call <- function(prompt, model = NULL, ...) {
  UseMethod("api_call")
}

# Define the method for OpenAI
#' @export
api_call.openai <- function(prompt, model = NULL, ...) {
  cli_inform(c("i" = "Using OpenAI API"))
  if (is.null(model)) model <- getOption("gptstudio.chat_model")
  openai_create_chat_completion(prompt = prompt, model = model)
}

# Define the method for HuggingFace
#' @export
api_call.huggingface <- function(prompt, model = NULL, ...) {
  if (is.null(model)) model <- getOption("gptstudio.hf_model")
  cli_inform(c("i" = "Using HuggingFace API"))
  hf_create_completion(prompt = prompt, model = model)
}

# Define the method for MakerSuite
#' @export
api_call.makersuite <- function(prompt, ...) {
  # Your code for calling the MakerSuite API goes here
  cli_warn("MakerSuite API calls are not yet implemented")
}

#' @export
api_call.default <- function(prompt, ...) {
  cli_abort(
    c("x" = "This API service is not been implemented or is missing.",
      "i" = "Class attribute for `prompt`: {class(prompt)}")
  )
}
