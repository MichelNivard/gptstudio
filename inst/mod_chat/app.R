ui <- bslib::page_fluid(
  theme = gptstudio:::create_chat_app_theme(),
  gptstudio:::mod_chat_ui("chat")
)

server <- function(input, output, session) {
  gptstudio:::mod_chat_server("chat")
}

shinyApp(ui, server)
