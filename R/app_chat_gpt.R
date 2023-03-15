#' Run Chat GPT
#' Run the Chat GPT Shiny App
#' @export
#'
addin_chatgpt <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = ".rs.invokeShinyPaneViewer")
  app_dir <- system.file("shiny", package = "gptstudio")
  shiny::shinyAppDir(app_dir)
}

make_chat_history <- function(history) {
  cli_inform("Making history...")
  cat_print(history)
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
