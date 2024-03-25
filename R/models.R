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
#' get_available_endpoints()
get_available_models <- function(service) {
  if (service == "openai") {
    models <-
      request_base("models") %>%
      httr2::req_perform() %>%
      httr2::resp_body_json() %>%
      purrr::pluck("data") %>%
      purrr::map_chr("id")

    models <- models %>%
      stringr::str_subset("^gpt") %>%
      stringr::str_subset("instruct", negate = TRUE) %>%
      stringr::str_subset("vision", negate = TRUE) %>%
      sort()

    idx <- which(models == "gpt-3.5-turbo")
    models <- c(models[idx], models[-idx])
    return(models)
  } else if (service == "huggingface") {
    c("gpt2", "tiiuae/falcon-7b-instruct", "bigcode/starcoderplus")
  } else if (service == "anthropic") {
    c("claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-2.1", "claude-instant-1.2")
  } else if (service == "azure_openai") {
    "Using ENV variables"
  } else if (service == "perplexity") {
    c(
      "sonar-small-chat", "sonar-small-online", "sonar-medium-chat",
      "sonar-medium-online", "codellama-70b-instruct", "mistral-7b-instruct",
      "mixtral-8x7b-instruct"
    )
  } else if (service == "ollama") {
    if (!ollama_is_available()) stop("Couldn't find ollama in your system")
    ollama_list() %>%
      purrr::pluck("models") %>%
      purrr::map_chr("name")
  } else if (service == "cohere") {
    c("command", "command-light", "command-nightly", "command-light-nightly")
  } else if (service == "google") {
    get_available_models_google()
  }
}
