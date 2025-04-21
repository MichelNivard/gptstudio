#' Check API Connection
#'
#' This generic function checks the API connection for a specified service
#' by dispatching to related methods.
#'
#' @param service The name of the API service for which the connection is being checked.
#' @param api_key The API key used for authentication.
#' @param model The service's model to check
#' @return A logical value indicating whether the connection was successful.
check_api_connection <- function(service, api_key = "", model = NULL) {
  if (service != "ollama" && (is.null(api_key) || api_key == "")) {
    cli::cli_alert_danger("API key is not set or invalid for {service} service.")
    return(invisible(NULL))
  }

  rlang::try_fetch({
    chat("what is 1+1", service = service, history = NULL, model = model)
    cli::cli_alert_success("Successfully connected to the {service} API service.")
  }, error = function(cnd) {
    cli::cli_alert_danger("Failed to connect to the {service} API service.")
  })
  invisible()
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
    check_api_connection(
      service = "openai",
      api_key = Sys.getenv("OPENAI_API_KEY")
    )
    cli::cli_h3("Checking HuggingFace API connection")
    check_api_connection(
      "huggingface",
      Sys.getenv("HF_API_KEY")
    )
    cli::cli_h3("Checking Anthropic API connection")
    check_api_connection(
      service = "anthropic",
      api_key = Sys.getenv("ANTHROPIC_API_KEY")
    )
    cli::cli_h3("Checking Google AI Studio API connection")
    check_api_connection(
      service = "google",
      api_key = Sys.getenv("GOOGLE_API_KEY")
    )
    cli::cli_h3("Checking Azure OpenAI API connection")
    check_api_connection(
      service = "azure_openai",
      api_key = Sys.getenv("AZURE_OPENAI_API_KEY")
    )
    cli::cli_h3("Checking Perplexity API connection")
    check_api_connection(
      service = "perplexity",
      api_key = Sys.getenv("PERPLEXITY_API_KEY")
    )
    cli::cli_h3("Checking Cohere API connection")
    check_api_connection(
      service = "cohere",
      api_key = Sys.getenv("COHERE_API_KEY"),
      model = "command-r"
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
