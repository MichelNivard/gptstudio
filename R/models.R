#' List supported models
#'
#' Get a list of the models supported by the OpenAI API.
#'
#' @param service The API service
#'
#' @return A character vector
#' @export
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
