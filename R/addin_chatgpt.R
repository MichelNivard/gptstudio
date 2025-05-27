#' Run GPTStudio Chat App
#'
#' This function initializes and runs the Chat GPT Shiny App as a background job
#' in RStudio and opens it in the viewer pane or browser window.
#'
#' @param host A character string specifying the host on which to run the app.
#'   Defaults to the value of `getOption("shiny.host", "127.0.0.1")`.
#'
#' @return This function does not return a value. It runs the Shiny app as a side effect.
#'
#' @details
#' The function performs the following steps:
#' 1. Verifies that RStudio API is available.
#' 2. Finds an available port for the Shiny app.
#' 3. Creates a temporary directory for the app files.
#' 4. Runs the app as a background job in RStudio.
#' 5. Opens the app in the RStudio viewer pane or browser window.
#'
#' @note This function is designed to work within the RStudio IDE and requires
#'   the rstudioapi package.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' gptstudio_chat()
#' }
gptstudio_chat <- function(host = getOption("shiny.host", "127.0.0.1")) {
  check_installed(c("miniUI", "future"))
  rstudioapi::verifyAvailable()

  app_port <- httpuv::randomPort()
  app_dir <- create_temp_app_dir()

  run_app_background(app_dir, "gptstudio", host, app_port)

  if (rstudioapi::versionInfo()$mode == "server") {
    Sys.sleep(3)
  }

  open_app_in_viewer(host, app_port)
}

# Helper functions

create_temp_app_dir <- function() {
  dir <- normalizePath(tempdir(), winslash = "/")
  app_file <- create_temp_app_file()
  file.copy(app_file, file.path(dir, "app.R"), overwrite = TRUE)
  dir
}

create_temp_app_file <- function() {
  temp_file <- tempfile(fileext = ".R")
  ide_colors <- dput(get_ide_theme_info())
  code_theme_url <- get_highlightjs_theme()

  internal_api_port <- NULL

  if (check_feature_flag("GPTSTUDIO_ENABLE_IDE_COMMUNICATION")) {
    internal_api_port <- httpuv::randomPort()
    cli::cli_alert_info("Port for internal API: {internal_api_port}")
    start_internal_api(internal_api_port)
  }

  line_options <- glue::glue(
    "options('gptstudio.internal_api_port' = {internal_api_port})"
  )

  writeLines(
    # nolint start
    glue::glue(
      "{{line_options}}
      ide_colors <- {{paste(deparse(ide_colors), collapse = '\n')}}
      ui <- gptstudio:::mod_app_ui('app', ide_colors, '{{code_theme_url}}')
      server <- function(input, output, session) {
          gptstudio:::mod_app_server('app', ide_colors)
      }
      shiny::shinyApp(ui, server)",
      .open = "{{", .close = "}}"
    ),
    temp_file)
    # nolint end
  temp_file
}

run_app_background <- function(app_dir, job_name, host, port, internal_api_port = NULL) {
  job_script <- tempfile(fileext = ".R")

  line_run_app <- glue::glue(
    "shiny::runApp(appDir = '{app_dir}', port = {port}, host = '{host}')"
  )

  writeLines(c(line_run_app), job_script)

  rstudioapi::jobRunScript(job_script, name = job_name)
  cli::cli_alert_success("{job_name} initialized as background job in RStudio")
}

open_app_in_viewer <- function(host, port) {
  url <- glue::glue("http://{host}:{port}")
  translated_url <- rstudioapi::translateLocalUrl(url, absolute = TRUE)

  if (host == "127.0.0.1") {
    cli::cli_inform(c(
      "i" = "Showing app in 'Viewer' pane",
      "i" = "Run {.run rstudioapi::viewer(\"{url}\")} to see it"
    ))
  } else {
    cli::cli_alert_info("Showing app in browser window")
  }

  wait_for_bg_app(translated_url)

  rstudioapi::viewer(translated_url)
}

wait_for_bg_app <- function(url, max_seconds = 10) {
  request(url) |>
    req_retry(
      max_seconds = max_seconds,
      is_transient = \(resp) resp_status(resp) >= 300,
      backoff = function(n) 0.2
    ) |>
    req_perform()
}

check_feature_flag <- function(flag, expected = "TRUE", default = "FALSE") {
  existent <- Sys.getenv(flag, unset = default)
  identical(existent, expected)
}
