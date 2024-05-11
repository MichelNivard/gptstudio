#' Create system prompt
#'
#' This function creates a customizable system prompt based on user-defined
#' parameters such as coding style, skill level, and task. It supports
#' customization for specific use cases through a custom prompt option.
#'
#' @param style A character string indicating the preferred coding style. Valid
#'   values are "tidyverse", "base", "no preference". Defaults to `getOption(gptstudio.code_style)`.
#' @param skill The self-described skill level of the programmer. Valid values
#'   are "beginner", "intermediate", "advanced", "genius". Defaults to `getOption(gptstudio.skill)`.
#' @param task The specific task to be performed: "coding", "general", "advanced
#'   developer", or "custom". This influences the generated system prompt.
#'   Defaults to "coding".
#' @param custom_prompt An optional custom prompt string to be utilized when
#'   `task` is set to "custom". Default is NULL.
#' @param in_source A logical indicating whether the instructions are intended
#'   for use in a source script. This parameter is required and must be
#'   explicitly set to TRUE or FALSE. Default is FALSE.
#'
#' @return Returns a character string that forms a system prompt tailored to the
#'   specified parameters. The string provides guidance or instructions based on
#'   the user's coding style, skill level, and task.
#'
#' @examples
#' \dontrun{
#' chat_create_system_prompt(in_source = TRUE)
#' chat_create_system_prompt(
#'   style = "tidyverse",
#'   skill = "advanced",
#'   task = "coding",
#'   in_source = FALSE
#' )
#' }
chat_create_system_prompt <-
  function(style = getOption("gptstudio.code_style"),
           skill = getOption("gptstudio.skill"),
           task = getOption("gptstudio.task"),
           custom_prompt = getOption("gptstudio.custom_prompt"),
           in_source = FALSE) {
    style %|!|%
      rlang::arg_match(style,
        values = c("tidyverse", "base", "no preference")
      )
    skill %|!|%
      rlang::arg_match(skill,
        values = c("beginner", "intermediate", "advanced", "genius")
      )
    task %|!|%
      rlang::arg_match(
        task,
        c("coding", "general", "advanced developer", "custom")
      )

    # Custom prompt bypass
    if (!is.null(custom_prompt) && task == "custom" && custom_prompt != "") {
      return(custom_prompt)
    }

    task %|!|%
      switch(task,
        "general" = return("You are a helpful chat assistant."),
        "advanced developer" = return("Write code only. Fewer instructions and comments.")
      )

    if (is.null(c(skill, style))) {
      intro <-
        glue::glue(
          "You are a chat bot assisting an R programmer working in RStudio."
        )
    } else {
      intro <-
        glue::glue(
          "As a chat bot assisting an R programmer working in the RStudio IDE",
          "it is important to tailor responses to their skill level and",
          "preferred coding style.",
          .sep = " "
        )
    }

    # Crafting the message parts based on provided arguments

    about_skill <- if (!is.null(skill)) {
      glue::glue("They consider themselves to be a {skill} R programmer.",
        "Provide answers with their skill level in mind.",
        .sep = " "
      )
    } else {
      ""
    }
    # nolint start
    about_style <- if (!is.null(style)) {
      switch(style,
        "no preference" = "",
        "base" = "They prefer to use a base R style of coding. When possible, answer code questions using base R.",
        "tidyverse" = "They prefer to use a tidyverse style of coding. When possible, answer code questions using tidyverse, r-lib, and tidymodels family of packages. R for Data Science is also a good resource to pull from."
      )
    } else {
      ""
    }
    # nolint end

    in_source_instructions <-
      if (in_source) {
        glue::glue("For any text that is not R code, write it as a code",
          "comment. Do not use code blocks or free text. Only use",
          "code and code comments.",
          .sep = " "
        )
      } else {
        ""
      }
    glue::glue("{intro} {about_skill} {about_style} {in_source_instructions}")
  }


#' Prepare chat completion prompt
#'
#' This function prepares the chat completion prompt to be sent to the OpenAI API.
#' It also generates a system message according to the given parameters and inserts
#' it at the beginning of the conversation.
#'
#' @param history A list of previous messages in the conversation. This can include
#'   roles such as 'system', 'user', or 'assistant'. System messages are discarded.
#'   Default is NULL.i
#' @param style The style of code to use. Applicable styles can be
#'   retrieved from the "gptstudio.code_style" option. Default is the
#'   "gptstudio.code_style" option. Options are "base", "tidyverse", or
#'   "no preference".
#' @param skill The skill level of the user for the chat conversation. This
#'   can be set through the "gptstudio.skill" option. Default is the
#'   "gptstudio.skill" option. Options are "beginner", "intermediate",
#'   "advanced", and "genius".
#' @param task Specifies the task that the assistant will help with. Default is
#'   "coding". Others are "general", "advanced developer", and "custom".
#' @param custom_prompt This is a custom prompt that may be used to guide the AI in
#'   its responses. Default is NULL. It will be the only content provided to the
#'   system prompt.
#'
#' @return A list where the first entry is an initial system message followed by any
#'   non-system entries from the chat history.
#'
prepare_chat_history <- function(history = NULL,
                                 style = getOption("gptstudio.code_style"),
                                 skill = getOption("gptstudio.skill"),
                                 task = "coding",
                                 custom_prompt = NULL) {
  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style,
        skill,
        task,
        custom_prompt,
        in_source = FALSE
      )
    )
  )

  history <- purrr::discard(history, ~ .x$role == "system")
  c(instructions, history)
}

get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}

`%|!|%` <- function(x, y) {
  if (is_null(x)) x else y
}

`%||%` <- function(x, y) {
  if (is_null(x)) y else x
}
