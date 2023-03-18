#' Run Chat GPT
#' Run the Chat GPT Shiny App
#'
#' @export
#'
#' @return This function has no return value.
#'
#' @examples
#' # Call the function as an RStudio addin
#' \dontrun{addin_chatgpt()}
addin_chatgpt <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = ".rs.invokeShinyPaneViewer")
  app_dir <- system.file("shiny", package = "gptstudio")
  shiny::shinyAppDir(app_dir)
}

#' Make Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
#'
#' @return A list of formatted chat messages with styling applied, excluding
#' system messages.
#' @export
#' @examples
#' chat_history_example <- list(
#'   list(role = "user", content = "Hello, World!"),
#'   list(role = "system", content = "System message"),
#'   list(role = "assistant", content = "Hi, how can I help?")
#' )
#' make_chat_history(chat_history_example)
make_chat_history <- function(history) {
  history <-
    purrr::map(history, ~ {
      if (.x$role == "system") NULL else .x
    }) %>%
    purrr::compact()

  purrr::map(history, ~ {
    list(
      shiny::strong(toupper(.x$role)),
      shiny::markdown(.x$content)
    )
  })
}
