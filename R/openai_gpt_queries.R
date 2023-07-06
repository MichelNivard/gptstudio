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
                     model = getOption("gptstudio.model")) {

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
      content = chat_create_system_prompt(style,
                                          skill,
                                          task = "coding",
                                          custom_prompt = NULL,
                                          in_source = TRUE)
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
