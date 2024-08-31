#' Run the ChatGPT app
#'
#' This starts the chatgpt app. It is exported to be able to run it from an R
#' script.
#'
#' @param ide_colors List containing the colors of the IDE theme.
#' @param code_theme_url URL to the highlight.js theme
#' @inheritParams shiny::runApp
#'
#' @return Nothing.
#' @export
gptstudio_run_chat_app <- function(ide_colors = get_ide_theme_info(),
                                   code_theme_url = get_highlightjs_theme(),
                                   host = getOption("shiny.host", "127.0.0.1"),
                                   port = getOption("shiny.port")) {
  check_installed("future")
  ui <- mod_app_ui("app", ide_colors, code_theme_url)

  server <- function(input, output, session) {
    mod_app_server("app", ide_colors)
  }

  shiny::shinyApp(ui, server, options = list(host = host, port = port))
}
