#' Freeform GPT editor
#'
#' Call this function as a Rstudio addin to open a GPT shiny app.
#'
#' @export
gptAddin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  shiny::runApp(system.file(package = "gptstudio", "gpt_freeform"))
}
