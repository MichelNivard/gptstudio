#' App UI
#'
#' @param id id of the module
#'
#' @import htmltools
#' @import shiny
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
mod_app_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    mod_chat_server("chat")
  })
}


#' RGB str to hex
#'
#' @param rgb_string The RGB string as returned by `rstudioapi::getThemeInfo()`
#'
#' @return hex color
rgb_str_to_hex <- function(rgb_string) {
  rgb_vec <- unlist(strsplit(gsub("[rgba() ]", "", rgb_string), ","))
  grDevices::rgb(
    red = as.numeric(rgb_vec[1]),
    green = as.numeric(rgb_vec[2]),
    blue = as.numeric(rgb_vec[3]),
    # alpha = if (is.na(rgb_vec[4])) 1 else rgb_vec[4],
    names = FALSE,
    maxColorValue = 255
  ) %>%
    unname()
}

#' Chat App Theme
#'
#' Create a bslib theme that matches the user's RStudio IDE theme.
#'
#' @return A bslib theme
create_chat_app_theme <- function() {

  theme_info <- get_ide_theme_info()

  bslib::bs_theme(
    version = 5,
    bg = theme_info$bg,
    fg = theme_info$fg,
    font_scale = 0.9
  )
}

get_ide_theme_info <- function() {
  if (rstudioapi::isAvailable()) {
    rstudio_theme_info <- rstudioapi::getThemeInfo()

    list(
      is_dark = rstudio_theme_info$dark,
      bg = rgb_str_to_hex(rstudio_theme_info$background),
      fg = rgb_str_to_hex(rstudio_theme_info$foreground)
    )
  } else {
    if (interactive()) cli::cli_inform("Using fallback ide theme")
    list(
      is_dark = TRUE,
      bg = "#002B36",
      fg = "#93A1A1"
    )
  }
}
