#' Check connection to OpenAI's API works
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY` environment variable is valid.
#'
#' @param api_key An API key. Defaults to the value of the `OPENAI_API_KEY` environment variable.
#'
#' @return Nothing is returned. If the API key is valid, a success message is printed. If the API key is invalid, an error message is printed and the function is aborted.
#' @export
check_api_connection <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  check_api_key(api_key)
  status_code <- simple_api_check(api_key)
  if (status_code == 200) {
    # If the status code is 200, the key is valid
    cli::cli_alert_success("API key is valid and a simple API call worked.")
    cli::cli_alert_info("The API is checked once per session.")
    options("gptstudio.valid_api" = TRUE)
    options("gptstudio.openai_key" = api_key)
  } else {
    # If the status code is not 200, the key is invalid
    cli::cli_abort(c(
      "x" = "API key found but call was unsuccessful",
      "i" = "OPEN_API_KEY is set to {Sys.getenv(\"OPENAI_API_KEY\")}",
      "i" = "Generate new API key at https://beta.openai.com/account/api-keys")
    )
  }
}

#' Check API key
#'
#' This function checks whether the API key provided as an argument is in the correct format.
#'
#' @param api_key An API key. Defaults to the value of the `OPENAI_API_KEY` environment variable.
#' @return Nothing is returned. If the API key is in the correct format, a success message is printed. If the API key is not in the correct format, an error message is printed and the function aborts.
#' @export
#'
check_api_key <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  regex <- "^[a-zA-Z0-9-]{30,60}$"
  if (grepl(regex, api_key)) {
    cli::cli_alert_success("API key found and matches the expected format.")
  } else {
    cli::cli_abort(c(
      "x" = "API key not found or is not formatted appropriately.",
      "i" = "OPEN_API_KEY is set to {Sys.getenv(\"OPENAI_API_KEY\")}",
      "i" = "Check OPEN_API_KEY is set with Sys.getenv(\"OPENAI_API_KEY\")",
      "i" = "Get key from https://beta.openai.com/account/api-keys")
    )
  }
}

#' Check API setup
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY`
#' environment variable is valid. This function will not re-check an API if it
#' has already been validated in the current session.
#'
#' @param api_key An API key. Defaults to the value of the `OPENAI_API_KEY`
#' environment variable.
#'
#' @return Nothing is returned. If the API key is valid, a success message is
#' printed. If the API key is invalid, an error message is printed and the
#' function aborts.
#' @export
check_api <- function(api_key = Sys.getenv("OPENAI_API_KEY")){
  valid_api <- getOption("gptstudio.valid_api")
  key   <- getOption("gptstudio.openai_key")

  if (!valid_api) {
    check_api_connection(api_key)
  } else if (key == Sys.getenv("OPENAI_API_KEY")) {
    cli::cli_alert_success("API already validated in this session.")
  } else {
    cli::cli_alert_warning("API key has changed. Checking API connection again.")
    check_api_connection(api_key)
  }
}

simple_api_check <- function(api_key){
  httr::GET("https://api.openai.com/v1/models",
            httr::add_headers(Authorization = paste0("Bearer ", api_key))) |>
    httr::status_code()
}
