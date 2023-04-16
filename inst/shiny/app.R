rlang::check_installed("waiter")
rlang::check_installed("bslib", version = "0.4.2")
library(gptstudio)
library(waiter)
library(shiny)


ui <- shiny::fluidPage(
  useWaiter(),
  theme = bslib::bs_theme(bootswatch = "morph", version = 5),
  title = "ChatGPT from gptstudio",
  class = "vh-100 p-3",

  div(
    class = "row justify-content-center h-100",
    div(
      class = "col h-100",
      style = htmltools::css(`max-width` = "800px"),
      gptstudio::mod_chat_ui("chat")
    )
  )
)

server <- function(input, output, session) {
  gptstudio::mod_chat_server("chat")
}

shiny::shinyApp(ui, server)
