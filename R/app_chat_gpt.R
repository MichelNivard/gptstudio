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
#' \dontrun{addin_chatgpt()}
addin_chatgpt <- function(host = getOption("shiny.host", "127.0.0.1")) {
  check_api()
  rstudioapi::verifyAvailable()
  stopifnot(rstudioapi::hasFun("viewer"))

  port <- random_port()
  app_dir <- system.file("shiny", package = "gptstudio")

  run_app_as_bg_job(appDir = app_dir, job_name = "GPT-Studio", host, port)

  open_bg_shinyapp(host, port)
}


#' Generate a random safe port number
#'
#' This function generates a random port allowed by shiny::runApp.
#'
#' @return A single integer representing the randomly selected safe port number.
#' @examples
#' random_port()
random_port <- function() {
  all_ports <- 3000:8000
  unsafe_ports <- c(3659, 4045, 5060, 5061, 6000, 6566, 6665:6669, 6697)
  safe_ports <- setdiff(all_ports, unsafe_ports)
  sample(safe_ports, size = 1)
}


#' Run an R Shiny app in the background
#'
#' This function runs an R Shiny app as a background job using the specified directory, name, host, and port.
#'
#' @param job_name The name of the background job to be created
#' @inheritParams shiny::runApp
#' @return This function returns nothing because is meant to run an app as a side effect.
run_app_as_bg_job <- function(appDir = ".", job_name, host, port) {
  job_script <- create_tmp_job_script(appDir = appDir, port = port, host = host)
  rstudioapi::jobRunScript(job_script, name = job_name)
  cli::cli_alert_success(paste0("'", job_name,"'", " initialized as background job in RStudio"))
}


#' Create a temporary job script
#'
#' This function creates a temporary R script file that runs the Shiny application from the specified directory with the specified port and host.
#' @inheritParams shiny::runApp
#' @return A string containing the path of a temporary job script
create_tmp_job_script <- function(appDir, port, host) {
	script_file <- tempfile(fileext = ".R")

	line <- glue::glue("shiny::runApp(appDir = '{appDir}', port = {port}, host = '{host}')")

	file_con <- file(script_file)
	writeLines(line, con = script_file)
	close(file_con)
	return(script_file)
}


#' Open browser to local Shiny app
#'
#' This function takes in the host and port of a local Shiny app and opens the app in the default browser.
#'
#' @param host A character string representing the IP address or domain name of the server where the Shiny app is hosted.
#' @param port An integer representing the port number on which the Shiny app is hosted.
#'
#' @return None (opens the Shiny app in the viewer pane or browser window)
open_bg_shinyapp <- function(host, port) {
  url <- glue::glue("http://{host}:{port}")
  translated_url <- rstudioapi::translateLocalUrl(url)

  if (host %in% c("127.0.0.1")) {
    cli::cli_alert_info("Showing app in 'Viewer' pane")
  } else {
    cli::cli_alert_info("Showing app in browser window")
  }

  rstudioapi::viewer(translated_url)
}




#' Make Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
#'
#' @return A list of formatted chat messages with styling applied, excluding
#' system messages.
#' @export
#' @examples
#' chat_history_example <- list(
#'   list(role = "user", content = "Hello, World!"),
#'   list(role = "system", content = "System message"),
#'   list(role = "assistant", content = "Hi, how can I help?")
#' )
#' make_chat_history(chat_history_example)
make_chat_history <- function(history) {
  history <-
    purrr::map(history, ~ {
      if (.x$role == "system") NULL else .x
    }) %>%
    purrr::compact()

  purrr::map(history, ~ {
    list(
      shiny::strong(toupper(.x$role)),
      shiny::markdown(.x$content)
    )
  })
}
