#' Run Chat GPT
#' Run the Chat GPT Shiny App as a background job and show it in the viewer pane
#'
#' @export
#'
#' @return This function has no return value.
#'
#' @inheritParams shiny::runApp
#' @examples
#' # Call the function as an RStudio addin
#' \dontrun{
#' addin_chatgpt()
#' }
addin_chatgpt <- function(host = getOption("shiny.host", "127.0.0.1")) {
  check_api()
  rstudioapi::verifyAvailable()
  stopifnot(rstudioapi::hasFun("viewer"))

  port <- random_port()
  app_dir <- create_tmp_app_dir()

  run_app_as_bg_job(appDir = app_dir, job_name = "gptstudio", host, port)

  if (.Platform$OS.type == "unix") Sys.sleep(1.5)

  open_bg_shinyapp(host, port)
}


#' Generate a random safe port number
#'
#' This function generates a random port allowed by shiny::runApp.
#'
#' @return A single integer representing the randomly selected safe port number.
random_port <- function() {
  all_ports <- 3000:8000
  unsafe_ports <- c(3659, 4045, 5060, 5061, 6000, 6566, 6665:6669, 6697)
  safe_ports <- setdiff(all_ports, unsafe_ports)
  sample(safe_ports, size = 1)
}


#' Run an R Shiny app in the background
#'
#' This function runs an R Shiny app as a background job using the specified
#' directory, name, host, and port.
#'
#' @param job_name The name of the background job to be created
#' @inheritParams shiny::runApp
#' @return This function returns nothing because is meant to run an app as a
#'   side effect.
run_app_as_bg_job <- function(appDir = ".", job_name, host, port) {
  job_script <- create_tmp_job_script(
    appDir = appDir,
    port = port,
    host = host
  )
  rstudioapi::jobRunScript(job_script, name = job_name)
  cli_alert_success(
    glue("{job_name} initialized as background job in RStudio")
  )
}


#' Create a temporary job script
#'
#' This function creates a temporary R script file that runs the Shiny
#' application from the specified directory with the specified port and host.
#' @inheritParams shiny::runApp
#' @return A string containing the path of a temporary job script
create_tmp_job_script <- function(appDir, port, host) {
  script_file <- tempfile(fileext = ".R")

  line <-
    glue::glue(
      "shiny::runApp(appDir = '{appDir}', port = {port}, host = '{host}')"
    )

  file_con <- file(script_file)
  writeLines(line, con = script_file)
  close(file_con)
  return(script_file)
}

create_tmp_app_dir <- function() {
  dir <- tempdir()

  if (.Platform$OS.type == "windows") {
    dir <- gsub(pattern = "[\\]", replacement = "/", x = dir)
  }

  app_file <- create_tmp_app_file()
  file.copy(from = app_file, to = file.path(dir, "app.R"), overwrite = TRUE)
  return(dir)
}

create_tmp_app_file <- function() {
  script_file <- tempfile(fileext = ".R")
  ide_theme <- get_ide_theme_info() %>%
    dput() %>%
    utils::capture.output()

  line_theme <- glue::glue(
    "ide_colors <- {ide_theme}"
  )
  line_ui <- glue::glue(
    "ui <- gptstudio:::mod_app_ui('app', ide_colors)"
  )
  line_server <- glue::glue(
    "server <- function(input, output, session) {
      gptstudio:::mod_app_server('app', ide_colors)
    }",
    .open = "{{",
    .close = "}}"
  )
  line_run_app <- glue::glue("shiny::shinyApp(ui, server)")

  file_con <- file(script_file)

  writeLines(
    text = c(line_theme, line_ui, line_server, line_run_app),
    sep = "\n\n",
    con = script_file
  )

  close(file_con)
  return(script_file)
}


#' Open browser to local Shiny app
#'
#' This function takes in the host and port of a local Shiny app and opens the
#' app in the default browser.
#'
#' @param host A character string representing the IP address or domain name of
#'   the server where the Shiny app is hosted.
#' @param port An integer representing the port number on which the Shiny app is
#'   hosted.
#'
#' @return None (opens the Shiny app in the viewer pane or browser window)
open_bg_shinyapp <- function(host, port) {
  url <- glue::glue("http://{host}:{port}")
  translated_url <- rstudioapi::translateLocalUrl(url, absolute = TRUE)

  if (host %in% c("127.0.0.1")) {
    cli::cli_inform(c(
      "i" = "Showing app in 'Viewer' pane",
      "i" = "Run {.run rstudioapi::viewer(\"{url}\")} to see it"
    ))
  } else {
    cli::cli_alert_info("Showing app in browser window")
  }

  rstudioapi::viewer(translated_url)
}
