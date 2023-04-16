#' App UI
#'
#' @param id id of the module
#'
#' @import htmltools
#' @import shiny
#' @export
#'
mod_app_ui <- function(id) {
  ns <- NS(id)

  bslib::page_fluid(
    waiter::useWaiter(),
    theme = create_chat_app_theme(),
    title = "ChatGPT from gptstudio",
    class = "vh-100 p-3 m-0",

    div(
      class = "row justify-content-center h-100",
      div(
        class = "col h-100",
        style = htmltools::css(`max-width` = "800px"),
        mod_chat_ui(ns("chat"))
      )
    )
  )
}



#' App Server
#'
#' @param id id of the module
#'
#' @export
#'
mod_app_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    mod_chat_server("chat")
  })
}


rgb_str_to_hex <- function(rgb_string) {
  rgb_vec <- unlist(strsplit(gsub("[rgb() ]", "", rgb_string), ","))
  rgb(
    as.numeric(rgb_vec[1]) / 255,
    as.numeric(rgb_vec[2]) / 255,
    as.numeric(rgb_vec[3]) / 255,
    names = FALSE
  )
}

create_chat_app_theme <- function() {

  rstudio_theme_info <- rstudioapi::getThemeInfo()

  bslib::bs_theme(
    # bootswatch = "morph",
    version = 5,
    bg = rgb_str_to_hex(rstudio_theme_info$background),
    fg = rgb_str_to_hex(rstudio_theme_info$foreground)
  )
}
