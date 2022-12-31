#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and
#' grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param instruction Instruction given to the model on how to improve the text.
#' @param temperature A parameter for controlling the randomness of the GPT
#' model's output.
#' @param openai_api_key An API key for the OpenAI API.
#' @param openai_organization An optional organization ID for the OpenAI API.
#' @param append_text Add text to selection rather than replace, defaults to
#'  FALSE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#'  RStudio session.
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
                               openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                               openai_organization = NULL) {
  if ("openai" %in% utils::installed.packages()) {
    openai::create_edit(
      model = model,
      input = input,
      instruction = instruction,
      temperature = temperature,
      openai_api_key = openai_api_key,
      openai_organization = openai_organization
    )
  } else {
    warn_about_openai_pkg()
    create_edit2(
      model = model,
      input = input,
      instruction = instruction,
      temperature = temperature,
      openai_api_key = openai_api_key,
      openai_organization = openai_organization
    )
  }
}

#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and
#'  grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param temperature A parameter for controlling the randomness of the GPT
#'  model's output.
#' @param max_tokens Maximum number of tokens to return (related to length of
#' response), defaults to 500
#' @param openai_api_key An API key for the OpenAI API.
#' @param openai_organization An optional organization ID for the OpenAI API.
#' @param append_text Add text to selection rather than replace, default to TRUE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#' RStudio session.
#' @export
gpt_create <- function(model,
                       temperature,
                       max_tokens = getOption("gptstudio.max_tokens"),
                       openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                       openai_organization = NULL,
                       append_text = TRUE) {
  check_api()
  selection <- get_selection()
  cat("here\n")
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
openai_create_completion <- function(
    model, prompt, temperature,
    max_tokens = getOption("gptstudio.max_tokens"),
    openai_api_key = Sys.getenv("OPENAI_API_KEY"),
    openai_organization = NULL,
    suffix = NULL) {
  if ("openai" %in% utils::installed.packages()) {
    openai::create_completion(
      model = model,
      prompt = prompt,
      temperature = temperature,
      max_tokens = max_tokens,
      openai_api_key = openai_api_key,
      openai_organization = openai_organization,
      suffix = NULL
    )
  } else {
    warn_about_openai_pkg()
    create_completion2(
      model = model,
      prompt = prompt,
      temperature = temperature,
      max_tokens = max_tokens,
      openai_api_key = openai_api_key,
      openai_organization = openai_organization,
      suffix = NULL
    )
  }
}

#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and
#' grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param prompt Instructions for the insertion
#' @param temperature A parameter for controlling the randomness of the GPT
#' model's output.
#' @param max_tokens Maximum number of tokens to return (related to length of
#' response), defaults to 500
#' @param openai_api_key An API key for the OpenAI API.
#' @param openai_organization An optional organization ID for the OpenAI API.
#' @param append_text Add text to selection rather than replace, defaults to
#' FALSE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#' RStudio session.
#' @export
gpt_insert <- function(model,
                       prompt,
                       temperature = 0.1,
                       max_tokens = getOption("gptstudio.max_tokens"),
                       openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                       openai_organization = NULL,
                       append_text = FALSE) {
  check_api()
  selection <- get_selection()
  cli::cli_progress_step("Asking GPT for help...")

  prompt <- paste(prompt, selection$value)

  edit <- openai_create_completion(
    model = model,
    prompt = prompt,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key,
    openai_organization = openai_organization
  )

  cli::cli_progress_step("Inserting text from GPT...")

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
  } else {
    improved_text <- c(edit$choices$text, selection$value)
  }

  cli::cli_format(improved_text)

  insert_text(improved_text)
}

# Wrapper around selectionGet to help with testthat
get_selection <- function() {
  rstudioapi::selectionGet()
}

# Wrapper around selectionGet to help with testthat
insert_text <- function(improved_text) {
  rstudioapi::insertText(improved_text)
}

#' Warn about openai package
#'
#' Warn the user if the openai package is not installed and their R version is
#' compatible with the current release of the package.
#'
#' @return NULL
#'
#' @export

#' @examples
#' \dontrun{
#' warn_about_openai_pkg()
#' }
warn_about_openai_pkg <- function() {
  rlang::inform("Package `openai` not detected in installed packages.")
  current_r_version <- as.character(utils::packageVersion("base"))
  if (utils::compareVersion(current_r_version, "4.2.0") >= 0) {
    message <- "Your R version {current_r_version} is compatible with the
                 current release of the openai package but it is not installed.
                 Please install it with: `install.packages(\"openai\")`"
    rlang::warn(message,
                .frequency = "regularly",
                .frequency_id = "openai_pkg",
                use_cli_format = TRUE
    )
  }
}
