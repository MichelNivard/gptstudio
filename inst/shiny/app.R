library(gptstudio)

ui <- mod_app_ui("app")

server <- function(input, output, session) {
  mod_app_server("app")
}

shiny::shinyApp(ui, server)
