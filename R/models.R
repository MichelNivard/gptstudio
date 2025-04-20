#' List supported models
#'
#' Get a list of the models supported by the selected service.
#'
#' @param service The API service
#'
#' @return A character vector
#' @export
#'
#' @seealso [get_all_available_services()]
#'
#' @examples
#' \dontrun{
#' get_available_models()
#' }
get_available_models <- function(service) {
  list_available_models(new_gptstudio_service(service))
}

list_available_models <- function(service) {
  UseMethod("list_available_models")
}

new_gptstudio_service <- function(service_name = character()) {
  stopifnot(rlang::is_scalar_character(service_name))
  class(service_name) <- c(service_name, "gptstudio_service")

  service_name
}

#' @export
list_available_models.openai <- function(service) {
  models <-
    request_base("models") |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    purrr::pluck("data") |>
    purrr::map_chr("id") |>
    sort()

  idx <- which(models == "gpt-4o-mini")

  # OpenAI compatible services might not have the model selected in idx
  if (is_empty(idx)) return(models)

  models <- c(models[idx], models[-idx])
  return(models)
}

#' @export
list_available_models.huggingface <- function(service) {
  c(
    "google/gemma-2-2b-it",
    "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B",
    "meta-llama/Meta-Llama-3.1-8B-Instruct",
    "microsoft/phi-4",
    "Qwen/Qwen2.5-Coder-32B-Instruct",
    "deepseek-ai/DeepSeek-R1"
  )
}

#' @export
list_available_models.anthropic <- function(service) {
  c(
    "claude-3-5-sonnet-20240620", "claude-3-opus-20240229", "claude-3-sonnet-20240229",
    "claude-3-haiku-20240307", "claude-2.1", "claude-instant-1.2"
  )
}

#' @export
list_available_models.azure_openai <- function(service) {
  "Using ENV variables"
}

#' @export
list_available_models.perplexity <- function(service) {
  c(
    "sonar", "sonar-pro", "sonar-deep-research", "sonar-reasoning", "sonar-reasoning-pro"
  )
}

#' @export
list_available_models.ollama <- function(service) {
  if (!ollama_is_available()) stop("Couldn't find ollama in your system")
  ollama_list() |>
    purrr::pluck("models") |>
    purrr::map_chr("name")
}

#' @export
list_available_models.cohere <- function(service) {
  get_available_models_cohere()
}

#' @export
list_available_models.google <- function(service) {
  get_available_models_google()
}

#' List supported service providers
#'
#' List the names of all providers/vendors supported by the gptstudio chat app.
#'
#' @returns A character vector
#'
#' @examples
#' get_all_available_services()
#'
#'
#' @export
get_all_available_services <- function() {
  methods(list_available_models) |>
    as.character() |>
    stringr::str_remove("^list_available_models\\.")
}

#' Set allowed models by provider
#'
#' Sometimes it is useful to restrict the list of options in the model selection dropdown of the
#' chat app. This function will check against `get_available_models()` to restrict the list to
#' models that are actually available.
#'
#' @param service The API service
#' @param models A character vector containing the list of allowed models that should be shown
#' in the dropdown selector. If `NULL` (default), all models will be available.
#'
#' @returns NULL
#'
#' @export
set_allowed_models <- function(service, models = NULL) {
  stopifnot(rlang::is_scalar_character(service))

  available_services <- get_all_available_services()
  if (!service %in% available_services) {
    cli::cli_abort("{.var service} must be one of {.str {available_services}}")
  }

  current_config <- read_user_config_file()

  if (is.null(models)) {
    cli::cli_alert_warning(
      "This will allow all available models for {.str {service}}"
    )

    continue <- utils::menu(
      choices = c("Yes", "No"),
      title = "Do you want to continue?"
    )

    if (!identical(continue, 1L)) return(invisible())

    current_config$allowed_models[[service]] <- NULL
    write_user_config_file(config = current_config)
    cli::cli_alert_info("You can use all available models for {.str {service}}")

    return(invisible())
  }

  stopifnot(rlang::is_bare_character(models))
  if (rlang::is_empty(models)) cli::cli_abort("{.var models} can't be empty")

  cli::cli_alert_info("Checking available models for service {.str {service}}")
  available_models <- get_available_models(service)

  diff <- setdiff(models, available_models)

  if (!rlang::is_empty(diff)) {
    cli::cli_abort(
      c(
        "{.str {diff}} {?is/are} not on the list of available models for {.str {service}}",
        "i" = "Run {.run gptstudio::get_available_models({.str {service}})} to see the full list"
      )
    )
  }

  allowed_models <- current_config$allowed_models %||% list()
  allowed_models[[service]] <- models

  current_config$allowed_models <- allowed_models

  write_user_config_file(config = current_config)

  cli::cli_alert_info("Saved models for {.str {service}} service: {.str {models}}")
}

get_allowed_models <- function(service) {
  available_services <- get_all_available_services()
  if (!service %in% available_services) {
    cli::cli_abort("{.var service} must be one of {.str {available_services}}")
  }

  config <- read_user_config_file()
  config$allowed_models[[service]]
}
