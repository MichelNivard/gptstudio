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
#' @param append_text Add text to selection rather than replace, defaults to
#'  FALSE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#'  RStudio session.
#' @export
#'
#' @examples
#' # Select some text in Rstudio
#' # Then call the function as an RStudio addin
#' \dontrun{
#' gpt_edit(
#'   model = "text-davinci-002",
#'   instruction = "Improve spelling and grammar",
#'   temperature = 0.5,
#'   openai_api_key = "my_api_key"
#' )
#' }
gpt_edit <- function(model,
                     instruction,
                     temperature,
                     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                     append_text = FALSE) {
  check_api()
  selection <- get_selection()
  inform("Asking GPT for help...")

  edit <- openai_create_edit(
    model = model,
    input = selection$value,
    instruction = instruction,
    temperature = temperature,
    openai_api_key = openai_api_key
  )

  cli::cat_print(edit)

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
    inform("Appending text from GPT...")
  } else {
    improved_text <- edit$choices$text
    inform("Inserting text from GPT...")
  }

  cli_text("{improved_text}")

  insert_text(improved_text)
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
#' @param append_text Add text to selection rather than replace, default to TRUE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#' RStudio session.
#' @export
#'
#' @examples
#' # Call the function as an RStudio addin
#' \dontrun{
#' gpt_create(
#'   model = "text-davinci-002",
#'   temperature = 0.5,
#'   max_tokens = 100,
#'   openai_api_key = "my_api_key"
#' )
#' }
gpt_create <- function(model,
                       temperature,
                       max_tokens = getOption("gptstudio.max_tokens"),
                       openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                       append_text = TRUE) {
  check_api()
  selection <- get_selection()


  edit <- openai_create_completion(
    model = model,
    prompt = selection$value,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key
  )

  inform("Inserting text from GPT...")

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
    inform("Appending text from GPT...")
  } else {
    improved_text <- edit$choices$text
    inform("Inserting text from GPT...")
  }
  insert_text(improved_text)
}

get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}

#' ChatGPT in RStudio
#'
#' This function uses the ChatGPT API tailored to a user-provided style and
#' skill level.
#'
#' @param query A character string representing the question or prompt to query
#'   the index with.
#' @param history A list of the previous chat responses
#' @param style A character string indicating the preferred coding style, the
#' default is "tidyverse".
#' @param skill The self-described skill level of the programmer,
#' default is "beginner"
#'
#' @return A list containing the instructions for answering the question, the
#'   context in which the question was asked, and the suggested answer.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Get help with a tidyverse question
#' tidyverse_query <- "How can I filter rows of a data frame?"
#' tidyverse_response <- gpt_chat(
#'   query = tidyverse_query,
#'   style = "tidyverse",
#'   skill = "beginner"
#' )
#' print(tidyverse_response)
#'
#' # Example 2: Get help with a base R question
#' base_r_query <- "How can I merge two data frames?"
#' base_r_response <- gpt_chat(
#'   query = base_r_query,
#'   style = "base",
#'   skill = "intermediate"
#' )
#' print(base_r_response)
#'
#' # Example 3: No style preference
#' no_preference_query <- "What is the best way to handle missing values in R?"
#' no_preference_response <- gpt_chat(
#'   query = no_preference_query,
#'   style = "no preference",
#'   skill = "advanced"
#' )
#' print(no_preference_response)
#' }
gpt_chat <- function(query,
                     history = NULL,
                     style = getOption("gptstudio.code_style"),
                     skill = getOption("gptstudio.skill")) {
  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style, skill, in_source = FALSE)
    ),
    list(
      role = "user",
      content = glue("{query}")
    )
  )

  history <- purrr::discard(history, ~ .x$role == "system")

  prompt <- c(history, instructions)
  answer <- openai_create_chat_completion(prompt)
  list(prompt, answer)
}


#' ChatGPT in Source
#'
#' Provides the same functionality as `gpt_chat()` with minor modifications to
#' give more useful output in a source (i.e., *.R) file.
#'
#' @inheritParams gpt_chat
#'
#' @return A list containing the instructions for answering the question, the
#'   context in which the question was asked, and the suggested answer.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Get help with a tidyverse question in a source file
#' # Select the following code comment in RStudio and run gpt_chat_in_source()
#' # How can I filter rows of a data frame?
#' tidyverse_response <- gpt_chat_in_source(
#'   style = "tidyverse",
#'   skill = "beginner"
#' )
#'
#' # Example 2: Get help with a base R question in a source file
#' # Select the following code comment in RStudio and run gpt_chat_in_source()
#' # How can I merge two data frames?
#' base_r_response <- gpt_chat_in_source(style = "base", skill = "intermediate")
#'
#' # Example 3: No style preference in a source file
#' # Select the following code comment in RStudio and run gpt_chat_in_source()
#' # What is the best way to handle missing values in R?
#' no_preference_response <- gpt_chat_in_source(
#'   style = "no preference",
#'   skill = "advanced"
#' )
#' }
#'
gpt_chat_in_source <- function(history = NULL,
                               style = getOption("gptstudio.code_style"),
                               skill = getOption("gptstudio.skill")) {

  check_api()
  query <- get_selection()

  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style, skill, in_source = TRUE)
    ),
    list(
      role = "user",
      content = glue("{query}")
    )
  )

  history <- purrr::discard(history, ~ .x$role == "system")
  prompt <- c(history, instructions)

  cli::cli_progress_step("Sending query to ChatGPT...", msg_done = "ChatGPT responded")

  answer <- openai_create_chat_completion(prompt)

  text_to_insert <- c(
    as.character(query),
    as.character(answer$choices[[1]]$message$content)
  )
  cli::cli_progress_step("Inserting response", msg_done = "Response was inserted")
  insert_text(text_to_insert)

}

#' Create system prompt
#'
#' This creates a system prompt based on the user defined parameters.
#'
#' @inheritParams gpt_chat
#' @param in_source Whether to add intructions to act as in a source script.
#'
#' @return A string
#'
chat_create_system_prompt <- function(style, skill, in_source) {
  arg_match(style, c("tidyverse", "base", "no preference"))
  arg_match(skill, c("beginner", "intermediate", "advanced", "genius"))
  assert_that(is.logical(in_source),
    msg = "chat system prompt creation needs logical `in_source`"
  )

  # nolint start
  intro <- "You are a helpful chat bot that answers questions for an R programmer working in the RStudio IDE."

  about_skill <- glue(
    "They consider themselves to be a {skill} R programmer. Provide answers with their skill level in mind."
  )

  about_style <- switch(style,
    "no preference" = "",
    "base" = "They prefer to use a base R style of coding. When possible, answer code quesetions using base R rather than the tidyverse.",
    "tidyverse" = "They prefer to use a tidyverse style of coding. When possible, answer code quesetions using tidyverse, r-lib, and tidymodels family of packages. R for Data Science is also a good resource to pull from."
  )

  in_source_intructions <- if (in_source) {
    "For any text that is not R code, write it as a code comment. Do not use code blocks or free text. Only use code and code comments."
  } else {
    ""
  }
  # nolint end

  glue("{intro} {about_skill} {about_style} {in_source_intructions}")
}
