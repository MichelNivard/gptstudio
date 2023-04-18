#' Run the ChatGPT app
#'
#' This starts the chatgpt app. It is exported to be able to run it from an R script.
#'
#' @return Nothing.
#' @export
run_chatgpt_app <- function() {
  ui <- mod_app_ui("app")

  server <- function(input, output, session) {
    mod_app_server("app")
  }

  shiny::shinyApp(ui, server)
}
