#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param instruction Instruction given to the model on how to improve the text.
#' @param temperature A parameter for controlling the randomness of the GPT model's output.
#' @param openai_api_key An API key for the OpenAI API.
#' @param openai_organization An optional organization ID for the OpenAI API.
#' @param append_text Add text to selection rather than replace, defaults to FALSE
#'
#' @return Nothing is returned. The improved text is inserted into the current RStudio session.
#' @export
gpt_edit <- function(model,
                      instruction,
                      temperature,
                      openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                      openai_organization = NULL,
                      append_text = FALSE) {
  check_api()
  selection <- get_selection()
  cli::cli_progress_step("Asking GPT for help...")

  edit <- openai_create_edit(
    model = model,
    input = selection$value,
    instruction = instruction,
    temperature = temperature,
    openai_api_key = openai_api_key,
    openai_organization = openai_organization
  )

  cli::cli_progress_step("Inserting text from GPT...")

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
    cli::cli_progress_step("Appending text from GPT...")
  } else {
    improved_text <- edit$choices$text
    cli::cli_progress_step("Inserting text from GPT...")
  }
  insert_text(improved_text)
}

# Wrapper around create_edit to help with testthat
# @export
openai_create_edit <- function(model, input, instruction, temperature,
                               openai_api_key, openai_organization){
  openai::create_edit(
    model = model,
    input = input,
    instruction = instruction,
    temperature = temperature,
    openai_api_key = openai_api_key,
    openai_organization = openai_organization
  )
}

#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param temperature A parameter for controlling the randomness of the GPT model's output.
#' @param max_tokens Maximum number of tokens to return (related to length of response), defaults to 500
#' @param openai_api_key An API key for the OpenAI API.
#' @param openai_organization An optional organization ID for the OpenAI API.
#' @param append_text Add text to selection rather than replace, defaults to TRUE
#'
#' @return Nothing is returned. The improved text is inserted into the current RStudio session.
#' @export
gpt_create <- function(model,
                     temperature,
                     max_tokens,
                     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                     openai_organization = NULL,
                     append_text = TRUE) {
  check_api()
  selection <- get_selection()
  cat('here\n')
  cli::cli_progress_step("Asking GPT for help...")

  edit <- openai_create_completion(
    model = model,
    prompt = selection$value,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key,
    openai_organization = openai_organization
  )

  cli::cli_progress_step("Inserting text from GPT...")

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
    cli::cli_progress_step("Appending text from GPT...")
  } else {
    improved_text <- edit$choices$text
    cli::cli_progress_step("Inserting text from GPT...")
  }
  insert_text(improved_text)
}


# Wrapper around create_completion to help with testthat
# @export
openai_create_completion <- function(model, prompt, temperature, max_tokens,
                               openai_api_key, openai_organization){
  openai::create_completion(
    model = model,
    prompt = prompt,
    max_tokens = max_tokens,
    temperature = temperature,
    openai_api_key = openai_api_key,
    openai_organization = openai_organization
  )
}

# Wrapper around selectionGet to help with testthat
get_selection <- function(){
  rstudioapi::selectionGet()
}

# Wrapper around selectionGet to help with testthat
insert_text <- function(improved_text){
  rstudioapi::insertText(improved_text)
}
