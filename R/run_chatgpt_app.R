#' Run the ChatGPT app
#'
#' This starts the chatgpt app. It is exported to be able to run it from an R
#' script.
#'
#' @param ide_colors List containing the colors of the IDE theme.
#' @inheritParams shiny::runApp
#'
#' @return Nothing.
#' @export
run_chatgpt_app <- function(ide_colors = get_ide_theme_info(),
                            host = getOption("shiny.host", "127.0.0.1"),
                            port = getOption("shiny.port")) {
  ui <- mod_app_ui("app", ide_colors)

  server <- function(input, output, session) {
    mod_app_server("app", ide_colors)
  }

  shiny::shinyApp(ui, server, options = list(host = host, port = port))
}
