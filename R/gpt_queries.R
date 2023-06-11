#' ChatGPT in RStudio
#'
#' This function uses the ChatGPT API tailored to a user-provided style and
#' skill level.
#'
#' @param history A list of the previous chat responses
#' @param style A character string indicating the preferred coding style, the
#' default is "tidyverse".
#' @param skill The self-described skill level of the programmer,
#' default is "beginner"
#' @param model The name of the GPT model to use.
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
gpt_chat <- function(history,
                     style = getOption("gptstudio.code_style"),
                     skill = getOption("gptstudio.skill"),
                     model = getOption("gptstudio.chat_model")) {

  history <- purrr::discard(history, ~ .x$role == "system")

  system <- list(
    role = "system",
    content = chat_create_system_prompt(style, skill, in_source = FALSE)
  )

  query <- c(list(system), history)

  answer <- openai_create_chat_completion(query, model = model)
  answer$choices[[1]]$message$content
}


#' ChatGPT in Source
#'
#' Provides the same functionality as `gpt_chat()` with minor modifications to
#' give more useful output in a source (i.e., *.R) file.
#'
#' @inheritParams gpt_chat
#' @param task Specific instructions to provide to the model as a system prompt
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
                               task = NULL,
                               style = getOption("gptstudio.code_style"),
                               skill = getOption("gptstudio.skill")) {

  check_api()
  query <- get_selection()

  if (!is.null(task)) {
    task <- list(
      role = "system",
      content = task
    )
  }

  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style, skill, in_source = TRUE)
    ),
    task,
    list(
      role = "user",
      content = query$value
    )
  ) %>% purrr::compact()

  history <- purrr::discard(history, ~ .x$role == "system")
  prompt <- c(history, instructions)

  cli::cli_progress_step("Sending query to ChatGPT...", msg_done = "ChatGPT responded")

  answer <- openai_create_chat_completion(prompt)
  text_to_insert <- as.character(answer$choices[[1]]$message$content)
  insert_text(text_to_insert)
}

#' Create system prompt
#'
#' This creates a system prompt based on the user defined parameters.
#'
#' @inheritParams gpt_chat
#' @param in_source Whether to add instructions to act as in a source script.
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
  intro <- "As a chat bot assisting an R programmer working in the RStudio IDE, it is important to tailor responses to their skill level and preferred coding style."

  about_skill <- glue(
    "They consider themselves to be a {skill} R programmer. Provide answers with their skill level in mind."
  )

  about_style <-
    switch(style,
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


get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}
