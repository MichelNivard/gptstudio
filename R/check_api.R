#' Check connection to OpenAI's API works
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY`
#' environment variable is valid.
#'
#' @param api_key An API key.
#' @param update_api Whether to attempt to update api if invalid
#' @param verbose Whether to provide information about the API connection
#'
#' @return Nothing is returned. If the API key is valid, a success message is
#' printed. If the API key is invalid, an error message is printed and the
#' function is aborted.
#' @export
#'
#' @examples
#' # Call the function with an API key
#' \dontrun{
#' check_api_connection("my_api_key")
#' }
#' # Call the function with an API key and avoid updating the API key
#' \dontrun{
#' check_api_connection("my_api_key", update_api = FALSE)
#' }
check_api_connection <- function(api_key, update_api = TRUE, verbose = FALSE) {
  if (!check_api_key(api_key, update_api)) {
    invisible()
  } else {
    status_code <- simple_api_check(api_key)
    if (status_code == 200) {
      if (verbose) {
        cli_alert_success("API key is valid and a simple API call worked.")
        cli_alert_info("The API is validated once per session.")
        cli_text("The default value for number of tokens per query is 500.
                    This equates to approximately $0.01 USD per query. You can
                    increase or decrease the number of tokens with the
                    `gptstudio.max_tokens` option. Here is an example to lower
                    the max tokens to 100 tokens per query:")
        cli_code("options(\"gptstudio.max_tokens\" = 100)")
        options("gptstudio.valid_api" = TRUE)
        options("gptstudio.openai_key" = api_key)
      }
      invisible(TRUE)
    } else {
      cli_alert_danger("API key found but call was unsuccessful.")
      cli_alert_info("Attempted to use API key: {obscure_key(api_key)}")
      if (interactive() && update_api) {
        cli_inform("Satus code: {status_code}")
        ask_to_set_api()
      } else {
        invisible(FALSE)
      }
    }
  }
}

#' Check API key
#'
#' This function checks whether the API key provided as an argument is in the
#' correct format.
#'
#' @param api_key An API key.
#' @param update_api Whether to attempt to update api if invalid
#'
#' @return Nothing is returned. If the API key is in the correct format, a
#' success message is printed. If the API key is not in the correct format,
#' an error message is printed and the function aborts.
#' @export
#'
#' @examples
#' # Call the function with an API key
#' \dontrun{
#' check_api_key("my_api_key")
#' }
#' # Call the function with an API key and avoid updating the API key
#' \dontrun{
#' check_api_key("my_api_key", update_api = FALSE)
#' }
check_api_key <- function(api_key, update_api = TRUE) {
  if (api_key == "") {
    cli_alert_warning("OPENAI_API_KEY is not set.")
    ask_to_set_api()
    invisible(FALSE)
  } else {
    regex <- "^[a-zA-Z0-9-]{30,60}$"
    if (grepl(regex, api_key)) {
      invisible(TRUE)
    } else {
      cli_alert_danger(
        c(
          "!" = "API key not found or is not formatted correctly.",
          "i" = "Attempted to validate key: {obscure_key(api_key)}",
          "i" = "Generate a key at {.url
        https://platform.openai.com/account/api-keys}"
        )
      )
      if (update_api) {
        ask_to_set_api()
      }
    }
  }
}

#' Check API setup
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY`
#' environment variable is valid. This function will not re-check an API if it
#' has already been validated in the current session.
#'
#' @return Nothing is returned. If the API key is valid, a success message is
#' printed. If the API key is invalid, an error message is printed and the
#' function aborts.
#' @export
#'
#' @examples
#' # Call the function to check the API key
#' \dontrun{
#' check_api()
#' }
check_api <- function() {
  api_key <- Sys.getenv("OPENAI_API_KEY")
  valid_api <- getOption("gptstudio.valid_api")
  saved_key <- getOption("gptstudio.openai_key")
  if (!valid_api) {
    check_api_connection(api_key)
  } else if (saved_key == Sys.getenv("OPENAI_API_KEY")) {
    invisible(TRUE)
  } else {
    cli_alert_warning("API key has changed. Re-checking API connection.")
    check_api_connection(api_key)
  }
}

simple_api_check <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  request_base(task = "models", token = api_key) %>%
    httr2::req_error(is_error = \(resp) FALSE) %>%
    httr2::req_perform() %>%
    httr2::resp_status()
}

set_openai_api_key <- function() {
  new_api_key <- readline_wrapper("Copy and paste your API key here: ")
  Sys.setenv(OPENAI_API_KEY = new_api_key)
  if (check_api()) {
    cli_alert_success(
      c(
        "v" = "API key is valid.",
        "i" = "Setting OPENAI_API_KEY environment variable.",
        "i" = "You can set this variable in your .Renviron file."
      )
    )
    invisible(TRUE)
  } else {
    cli_alert_danger(
      c(
        "!" = "API key is invalid.",
        "i" = "Get key from {.url https://platform.openai.com/account/api-keys}"
      )
    )
    if (interactive()) {
      try_again <- ui_yeah_wrapper("Woud you like to try again?")
      ifelse(try_again, set_openai_api_key(), FALSE)
    } else {
      invisible(FALSE)
    }
  }
}

ask_to_set_api <- function() {
  if (interactive()) {
    set_api <- ui_yeah_wrapper(
      "Do you want to set the OPENAI_API_KEY for this session?"
    )
    if (set_api) {
      set_openai_api_key()
    } else {
      cli_warn("Not setting OPENAI_API_KEY environment variable.")
      invisible(FALSE)
    }
  } else {
    invisible(FALSE)
  }
}

obscure_key <- function(api_key) {
  if (nchar(api_key) == 0) {
    "no key provided"
  } else if (nchar(api_key) > 8) {
    api_start <- substr(api_key, 1, 4)
    api_mid <- paste0(rep("*", nchar(api_key) - 8), collapse = "")
    api_end <- substr(api_key, nchar(api_key) - 3, nchar(api_key))
    paste0(api_start, api_mid, api_end)
  } else {
    "<hidden> (too short to obscure)"
  }
}

ui_yeah_wrapper <- function(prompt) usethis::ui_yeah(prompt)
readline_wrapper <- function(prompt) readline(prompt)
