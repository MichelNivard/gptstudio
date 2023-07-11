ui <- bslib::page_fluid(
  theme = gptstudio:::create_chat_app_theme(),
  gptstudio:::mod_prompt_ui("prompt")
)

server <- function(input, output, session) {
  gptstudio:::mod_prompt_server("prompt")
}

shinyApp(ui, server)
