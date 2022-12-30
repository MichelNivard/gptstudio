#' Specify Model Addin
#'
#' This function launches the GPT Specify Model Addin.
#'
#' @export
specify_model_addin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  shiny::runApp(system.file(package = "gpt_tools", "gpt_specify_model"))
}
