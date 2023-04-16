rlang::check_installed("waiter")
rlang::check_installed("bslib", version = "0.4.2")
library(gptstudio)
library(waiter)
library(shiny)

rstudio_theme_info <- rstudioapi::getThemeInfo()

rgb_str_to_hex <- function(rgb_string) {
  rgb_vec <- unlist(strsplit(gsub("[rgb() ]", "", rgb_string), ","))
  rgb(
    as.numeric(rgb_vec[1]) / 255,
    as.numeric(rgb_vec[2]) / 255,
    as.numeric(rgb_vec[3]) / 255,
    names = FALSE
  )
}

ui <- shiny::fluidPage(
  useWaiter(),
  theme = bslib::bs_theme(
    # bootswatch = "morph",
    version = 5,
    bg = rgb_str_to_hex(rstudio_theme_info$background),
    fg = rgb_str_to_hex(rstudio_theme_info$foreground)
  ),
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
