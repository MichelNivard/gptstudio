#' Create system prompt
#'
#' This creates a system prompt based on the user defined parameters.
#'
#' @inheritParams gpt_chat
#' @param task The task to be performed: "coding", "general", or "advanced developer".
#' @param custom_prompt An optional custom prompt to be displayed.
#' @param in_source Whether to add instructions to act as in a source script.
#'
#' @return A string
#'
chat_create_system_prompt <- function(style, skill, task = "coding", custom_prompt = NULL, in_source) {
  arg_match(style, c("tidyverse", "base", "no preference"))
  arg_match(skill, c("beginner", "intermediate", "advanced", "genius"))
  arg_match(task, c("coding", "general", "advanced developer"))
  assert_that(is.logical(in_source),
              msg = "chat system prompt creation needs logical `in_source`"
  )

  if (!is.null(custom_prompt)) {
    return(custom_prompt)
  }

  if (task == "general") {
    return("You are a helpful chat assistnat.")
  }

  if (task == "advanced developer") {
    "Write code only. Fewer instructions and comments."
  }

  # nolint start

  intro <- "As a chat bot assisting an R programmer working in the RStudio IDE, it is important to tailor responses to their skill level and preferred coding style."
  about_skill <- glue(
    "They consider themselves to be a {skill} R programmer. Provide answers with their skill level in mind."
  )

  about_style <-
    switch(style,
           "no preference" = "",
           "base" = "They prefer to use a base R style of coding. When possible, answer code questions using base R rather than the tidyverse.",
           "tidyverse" = "They prefer to use a tidyverse style of coding. When possible, answer code questions using tidyverse, r-lib, and tidymodels family of packages. R for Data Science is also a good resource to pull from."
    )

  in_source_instructions <- if (in_source) {
    "For any text that is not R code, write it as a code comment. Do not use code blocks or free text. Only use code and code comments."
  } else {
    ""
  }

  # nolint end

  glue("{intro} {about_skill} {about_style} {in_source_instructions}")
}


#' Prepare chat completion prompt
#'
#' This function prepares the chat completion prompt to be sent to the OpenAI API.
#'
#' @param history A list of previous messages in the conversation (optional).
#' @param style The style of the chat conversation (optional). Default is
#'   retrieved from the "gptstudio.code_style" option.
#' @param skill The skill to use for the chat conversation (optional). Default
#'   is retrieved from the "gptstudio.skill" option.
#'
#' @return A list containing the body of the request.
#'
prepare_chat_history <- function(history = NULL,
                                 style = getOption("gptstudio.code_style"),
                                 skill = getOption("gptstudio.skill")) {
  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style, skill, in_source = FALSE)
    )
  )

  history <- purrr::discard(history, ~ .x$role == "system")
  c(history, instructions)
}

get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}
