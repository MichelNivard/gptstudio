#' Check API Connection
#'
#' This generic function checks the API connection for a specified service
#' by dispatching to related methods.
#'
#' @param service The name of the API service for which the connection is being checked.
#' @param api_key The API key used for authentication.
#' @return A logical value indicating whether the connection was successful.
check_api_connection_openai <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  response <-
    request_base_openai(task = "models") |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()
  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_huggingface <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }
  response <- request_base_huggingface(task = "gpt2") |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_anthropic <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  response <-
    request_base_anthropic(key = Sys.getenv("ANTHROPIC_API_KEY")) |>
    req_body_json(
      data = list(
        prompt = "\n\nHuman: Hello, Claude\n\nAssistant:",
        model = "claude-2.1",
        max_tokens_to_sample = 1024
      )
    ) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_google <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  request_body <-
    list(contents = list(list(parts = list(list(text = "Hello there")))))

  response <- request_base_google(model = "gemini-pro", api_key = api_key) |>
    req_body_json(data = request_body) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_azure_openai <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  response <- request_base_azure_openai() |>
    req_body_json(list(messages = list(list(
      role = "user",
      content = "Hello world!"
    )))) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_perplexity <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  response <- request_base_perplexity() |>
    req_body_json(data = list(
      model = "sonar-small-chat",
      messages = list(list(role = "user", content = "Hello world!"))
    )) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' @inheritParams check_api_connection_openai
check_api_connection_cohere <- function(service, api_key) {
  api_check <- check_api_key(service, api_key)
  if (rlang::is_false(api_check)) {
    return(invisible(NULL))
  }

  response <- request_base_cohere(api_key = api_key) |>
    req_body_json(data = list(message = "Hello world!")) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform()

  process_response(response, service)
}

#' Current Configuration for gptstudio
#'
#' This function prints out the current configuration settings for gptstudio and
#' checks API connections if verbose is TRUE.
#'
#' @param verbose Logical value indicating whether to output additional information,
#' such as API connection checks. Defaults to TRUE.
#'
#' @return Invisibly returns NULL, as the primary purpose of this function is to
#' print to the console.
#'
#' @examples
#' \dontrun{
#' gptstudio_sitrep(verbose = FALSE) # Print basic settings, no API checks
#' gptstudio_sitrep() # Print settings and check API connections
#' }
#' @export
gptstudio_sitrep <- function(verbose = TRUE) {
  cli::cli_h1("Configuration for gptstudio")

  user_config <-
    file.path(tools::R_user_dir("gptstudio", which = "config"), "config.yml")

  if (file.exists(user_config)) {
    cli::cli_inform("Using user configuration file at {.file {user_config}}")
  } else {
    cli::cli_text(
      "No user configuration file found at {.file {user_config}}.
      Using default configuration.
      Change configuration settings in the chat app.
      Lauch the chat app with addins or {.run [gptstudio_chat()](gptstudio::gptstudio_chat())}."
    )
  }
  cli::cli_h2("Current Settings")
  cli::cli_bullets(c(
    "- Model: {getOption('gptstudio.model')}",
    "- Task: {getOption('gptstudio.task')}",
    "- Language: {getOption('gptstudio.language')}",
    "- Service: {getOption('gptstudio.service')}",
    "- Custom prompt: {getOption('gptstudio.custom_prompt')}",
    "- Stream: {getOption('gptstudio.stream')}",
    "- Code style: {getOption('gptstudio.code_style')}",
    "- Skill: {getOption('gptstudio.skill')}"
  ))
  if (verbose) {
    cli::cli_h2("Checking API connections")
    cli::cli_h3("Checking OpenAI API connection")
    check_api_connection_openai(
      service = "OpenAI",
      api_key = Sys.getenv("OPENAI_API_KEY")
    )
    cli::cli_h3("Checking HuggingFace API connection")
    check_api_connection_huggingface(
      "HuggingFace",
      Sys.getenv("HF_API_KEY")
    )
    cli::cli_h3("Checking Anthropic API connection")
    check_api_connection_anthropic(
      service = "Anthropic",
      api_key = Sys.getenv("ANTHROPIC_API_KEY")
    )
    cli::cli_h3("Checking Google AI Studio API connection")
    check_api_connection_google(
      service = "Google AI Studio",
      api_key = Sys.getenv("GOOGLE_API_KEY")
    )
    cli::cli_h3("Checking Azure OpenAI API connection")
    check_api_connection_azure_openai(
      service = "Azure OpenAI",
      api_key = Sys.getenv("AZURE_OPENAI_API_KEY")
    )
    cli::cli_h3("Checking Perplexity API connection")
    check_api_connection_perplexity(
      service = "Perplexity",
      api_key = Sys.getenv("PERPLEXITY_API_KEY")
    )
    cli::cli_h3("Checking Cohere API connection")
    check_api_connection_cohere(
      service = "Cohere",
      api_key = Sys.getenv("COHERE_API_KEY")
    )
    cli::cli_h3("Check Ollama for Local API connection")
    ollama_is_available(verbose = TRUE)
    cli::cli_h2("Getting help")
    cli::cli_inform("See the {.href [gptstudio homepage](https://michelnivard.github.io/gptstudio/)} for getting started guides and package documentation. File an issue or contribute to the package at the {.href [GitHub repo](https://github.com/MichelNivard/gptstudio)}.") # nolint
  } else {
    cli::cli_text("Run {.run [gptstudio_sitrep(verbose = TRUE)](gptstudio::gptstudio_sitrep(verbose = TRUE))} to check API connections.") # nolint
  }
  cli::cli_rule(left = "End of gptstudio configuration")
}

# helper functions --------------------------------------------------------

check_api_key <- function(service, api_key) {
  if (is.null(api_key) || api_key == "") {
    cli::cli_alert_danger("API key is not set or invalid for {service} service.")
    return(invisible(FALSE))
  } else {
    return(invisible(TRUE))
  }
}

process_response <- function(response, service) {
  if (resp_is_error(response)) {
    cli::cli_alert_danger("Failed to connect to the {service} API service.")
  } else {
    cli::cli_alert_success("Successfully connected to the {service} API service.")
  }
}
