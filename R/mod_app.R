#' App UI
#'
#' @param id id of the module
#' @inheritParams run_chatgpt_app
#'
#' @import htmltools
#' @import shiny
#'
mod_app_ui <- function(id, ide_colors = get_ide_theme_info()) {
  ns <- NS(id)

  translator <- create_translator(language = getOption("gptstudio.language"))

  bslib::page_fluid(
    theme = create_chat_app_theme(ide_colors),
    title = "ChatGPT from gptstudio",
    class = "vh-100 p-3 m-0",
    html_dependencies(),
    div(
      class = "row justify-content-center h-100",
      div(
        class = "col h-100",
        style = htmltools::css(`max-width` = "800px"),
        mod_chat_ui(ns("chat"), translator)
      )
    )
  )
}



#' App Server
#'
#' @inheritParams mod_app_ui
#' @inheritParams run_chatgpt_app
#'
mod_app_server <- function(id, ide_colors = get_ide_theme_info()) {
  moduleServer(id, function(input, output, session) {
    mod_chat_server("chat", ide_colors)
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
    names = FALSE,
    maxColorValue = 255
  ) %>%
    unname()
}

#' Chat App Theme
#'
#' Create a bslib theme that matches the user's RStudio IDE theme.
#'
#' @inheritParams run_chatgpt_app
#'
#' @return A bslib theme
create_chat_app_theme <- function(ide_colors = get_ide_theme_info()) {
  bslib::bs_theme(
    version = 5,
    bg = ide_colors$bg,
    fg = ide_colors$fg,
    font_scale = 0.9
  )
}


#' Get IDE theme information.
#'
#' This function returns a list with the current IDE theme's information.
#'
#' @return A list with three components:
#' \item{is_dark}{A boolean indicating whether the current IDE theme is dark.}
#' \item{bg}{The current IDE theme's background color.}
#' \item{fg}{The current IDE theme's foreground color.}
#'
#' @export
#'
get_ide_theme_info <- function() {
  if (rstudioapi::isAvailable()) {
    rstudio_theme_info <- rstudioapi::getThemeInfo()

    # create a list with three components
    list(
      is_dark = rstudio_theme_info$dark,
      bg = rgb_str_to_hex(rstudio_theme_info$background),
      fg = rgb_str_to_hex(rstudio_theme_info$foreground)
    )
  } else {
    if (interactive()) cli::cli_inform("Using fallback ide theme")

    # create a list with three components with fallback values
    list(
      is_dark = TRUE,
      bg = "#002B36",
      fg = "#93A1A1"
    )
  }
}

html_dependencies <- function() {
  htmltools::htmlDependency(
    name = "gptstudio-assets", version = "0.2.0",
    package = methods::getPackageName(),
    src = "assets",
    script = c("js/copyToClipboard.js", "js/shiftEnter.js"),
    stylesheet = c("css/mod_app.css")
  )
}

#' Internationalization for the ChatGPT addin
#'
#' The language can be set via `options("gptstudio.language" = "<language>")`
#' (defaults to "en") or the "GPTSTUDIO_LANGUAGE" environment variable.
#'
#' @param language The language to be found in the translation JSON file.
#'
#' @return A Translator from `shiny.i18n::Translator`
create_translator <- function(language = getOption("gptstudio.language")) {
  translator  <- shiny.i18n::Translator$new(translation_json_path = system.file("translations/translation.json", package = "gptstudio"))
  supported_languages <- translator$get_languages()

  if (! language %in% supported_languages) {
    cli::cli_abort("Language {.val {language}} is not supported. Must be one of {.val {supported_languages}}")
  }

  translator$set_translation_language(language)

  translator
}
