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
                       append_text = FALSE) {
  check_api()
  selection <- get_selection()
  inform("Asking GPT for help...")

  prompt <- paste(prompt, selection$value)

  edit <- openai_create_completion(
    model = model,
    prompt = prompt,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key
  )

  inform("Inserting text from GPT...")

  if (append_text) {
    improved_text <- c(selection$value, edit$choices$text)
  } else {
    improved_text <- c(edit$choices$text, selection$value)
  }

  cli_format(improved_text)

  insert_text(improved_text)
}

#' Wrapper around selectionGet to help with testthat
#'
#' @return Text selection via `rstudioapi::selectionGet`
#'
#' @export
get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

#' Wrapper around selectionGet to help with testthat
#'
#' @param improved_text Text from model queries to inert into script or document
#'
#' @export
insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}

#' Query an Index
#'
#' This function queries an index with a given question or prompt and returns a
#' set of suggested answers.
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
gpt_chat <- function(query, history, style = "tidyverse", skill = "beginner") {
  arg_match(style, c("tidyverse", "base", "no preference"))
  arg_match(skill, c("beginner", "intermediate", "advanced", "genius"))

  instructions <-
    switch(
      style,
      "tidyverse" =
        list(
          list(
            role = "system",
            content =
              glue(
                "You are a helpful chat bot that answere questions for an R
                programmer working in the RStudio IDE. They consider themselves
                to be a {skill} R programmer. Provide answers with their skill
                level in mind. They prefer to use a tidyverse style
                of coding. When possible, answer code quesetions using
                tidyverse, r-lib, and tidymodels family of packages. R for Data
                Science is also a good resource to pull from."
              )
          ),
          list(
            role = "user",
            content = glue("{query}")
          )
        ),
      "base" =
        list(
          list(
            role = "system",
            content =
              glue(
                "You are a helpful chat bot that answere questions for an R
                programmer working in the RStudio IDE. They consider themselves
                to be a {skill} R programmer. Provide answers with their skill
                level in mind. They prefer to use a base R style of
                coding. When possible, answer code quesetions using base R
                rather than the tidyverse."
              )
          ),
          list(
            role = "user",
            content = glue("{query}")
          )
        ),
      "no preference" =
        list(
          list(
            role = "system",
            content =
              glue(
                "You are a helpful chat bot that answere questions for an R
                programmer working in the RStudio IDE. TThey consider themselves
                to be a {skill} R programmer. Provide answers with their skill
                level in mind."
              )
          ),
          list(
            role = "user",
            content = glue("{query}")
          )
        )
    )

  history <-
    purrr::map(history, ~{if (.x$role == "system") NULL else .x}) %>%
    purrr::compact()

  prompt <- c(history, instructions)

  answer <- openai_create_chat_completion(prompt)

  list(prompt, answer)
}
