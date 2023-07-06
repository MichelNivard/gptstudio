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
chat_create_system_prompt <-
  function(style = c("tidyverse", "base", "no preference", NULL),
           skill = c("beginner", "intermediate", "advanced", "genius", NULL),
           task = c("coding", "general", "advanced developer", "custom"),
           custom_prompt = NULL,
           in_source) {
    arg_match(style)
    arg_match(skill)
    arg_match(task)
    assert_that(is.logical(in_source),
                msg = "chat system prompt creation needs logical `in_source`")

    if (!is.null(custom_prompt) && task == "custom") {
      return(custom_prompt)
    }

    if (task == "general") {
      return("You are a helpful chat assistant.")
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
                                 task  = "coding",
                                 custom_prompt = NULL) {
  instructions <- list(
    list(
      role = "system",
      content = chat_create_system_prompt(style,
                                          skill,
                                          task,
                                          custom_prompt,
                                          in_source = FALSE)
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
