#' App UI
#'
#' @param id id of the module
#' @inheritParams gptstudio_run_chat_app
#'
#' @import htmltools
#' @import shiny
#'
mod_app_ui <- function(id,
                       ide_colors = get_ide_theme_info(),
                       code_theme_url = get_highlightjs_theme()) {
  ns <- NS(id)
  translator <- create_translator(language = getOption("gptstudio.language"))
  tagList(
    useBusyIndicators(),
    bslib::page_fluid(
      theme = create_chat_app_theme(ide_colors),
      title = "ChatGPT from gptstudio",
      class = "vh-100 p-0 m-0",
      html_dependencies(),
      bslib::layout_sidebar(
        class = "vh-100",
        sidebar = bslib::sidebar(
          open = "closed",
          width = 300,
          class = "p-0",
          padding = "0.5rem",
          mod_sidebar_ui(ns("sidebar"), translator)
        ),
        div(
          class = "row justify-content-center h-100",
          div(
            class = "col h-100",
            mod_chat_ui(ns("chat"), translator, code_theme_url)
          )
        )
      )
    )
  )
}

#' App Server
#'
#' @inheritParams mod_app_ui
#' @inheritParams gptstudio_run_chat_app
#'
mod_app_server <- function(id, ide_colors = get_ide_theme_info()) {
  moduleServer(id, function(input, output, session) {
    sidebar <- mod_sidebar_server("sidebar")
    mod_chat_server(
      id = "chat",
      ide_colors = ide_colors,
      translator = NULL,
      settings = sidebar$settings,
      history = sidebar$history
    )
  })
}


#' RGB str to hex
#'
#' @param rgb_string The RGB string as returned by `rstudioapi::getThemeInfo()`
#'
#' @return hex color
rgb_str_to_hex <- function(rgb_string) {
  check_installed("grDevices")
  rgb_vec <- unlist(strsplit(gsub("[rgba() ]", "", rgb_string), ","))
  grDevices::rgb(
    red = as.numeric(rgb_vec[1]),
    green = as.numeric(rgb_vec[2]),
    blue = as.numeric(rgb_vec[3]),
    names = FALSE,
    maxColorValue = 255
  ) |>
    unname()
}

#' Chat App Theme
#'
#' Create a bslib theme that matches the user's RStudio IDE theme.
#'
#' @inheritParams gptstudio_run_chat_app
#'
#' @return A bslib theme
create_chat_app_theme <- function(ide_colors = get_ide_theme_info()) {
  bslib::bs_theme(
    version = 5,
    preset = "shiny",
    bg = ide_colors$bg,
    fg = ide_colors$fg,
    font_scale = 0.9,
    `btn-padding-x` = "1em",
    `btn-padding-y` = ".5em"
  )
}


#' Get IDE Theme Information
#'
#' Retrieves the current RStudio IDE theme information including whether it is a dark theme,
#' and the background and foreground colors in hexadecimal format.
#'
#' @return A list with the following components:
#'   \item{is_dark}{A logical indicating whether the current IDE theme is dark.}
#'   \item{bg}{A character string representing the background color of the IDE theme in hex format.}
#'   \item{fg}{A character string representing the foreground color of the IDE theme in hex format.}
#'
#' If RStudio is unavailable, returns the fallback theme details.
#'
#' @examples
#' theme_info <- get_ide_theme_info()
#' print(theme_info)
#'
#' @export
get_ide_theme_info <- function() {
  if (rstudioapi::isAvailable()) {
    tryCatch(
      {
        rstudio_theme_info <- rstudioapi::getThemeInfo()

        # Create a list with theme components
        list(
          is_dark = rstudio_theme_info$dark,
          bg = rgb_str_to_hex(rstudio_theme_info$background),
          fg = rgb_str_to_hex(rstudio_theme_info$foreground)
        )
      },
      error = function(e) {
        cli::cli_warn("Error fetching theme info from RStudio: {e$message}")
        fallback_theme()
      }
    )
  } else {
    if (interactive()) cli::cli_inform("RStudio is not available. Using fallback IDE theme.")
    fallback_theme()
  }
}

# Fallback function to provide default values
fallback_theme <- function() {
  list(
    is_dark = TRUE,
    bg = "#181818",
    fg = "#C1C1C1"
  )
}


html_dependencies <- function() {
  htmltools::htmlDependency(
    name = "gptstudio-assets", version = "0.4.0",
    package = "gptstudio",
    src = "assets",
    script = c("js/copyToClipboard.js", "js/shiftEnter.js", "js/conversation.js"),
    stylesheet = c("css/mod_app.css")
  )
}

#' Internationalization for the ChatGPT addin
#'
#' The language can be set via `options("gptstudio.language" = "<language>")`
#' (defaults to "en").
#'
#' @param language The language to be found in the translation JSON file.
#'
#' @return A Translator from `shiny.i18n::Translator`
create_translator <- function(language = getOption("gptstudio.language")) {
  translator <- shiny.i18n::Translator$new(
    translation_json_path = system.file("translations/translation.json", package = "gptstudio")
  )
  supported_languages <- translator$get_languages()

  if (!language %in% supported_languages) {
    cli::cli_abort("Language {.val {language}} is not supported. Must be one of {.val {supported_languages}}") # nolint
  }

  translator$set_translation_language(language)

  translator
}
