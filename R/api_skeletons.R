new_gpstudio_request_skeleton <- function(url, api_key, model, prompt, history,
                                          stream, ..., class = character()) {
  validate_skeleton(url, api_key, model, prompt, history, stream)
  structure(
    list(
      url = url,
      api_key = api_key,
      model = model,
      prompt = prompt,
      history = history,
      stream = stream,
      extras = list(...)
    ),
    class = c(class, "gptstudio_request_skeleton")
  )
}

validate_skeleton <- function(url, api_key, model, prompt, history, stream) {
  if (!is_scalar_character(url)) {
    cli_abort("{.arg url} is not a valid character scalar.
              It is a {.cls {class(url)}}.")
  }

  if (!is_scalar_character(api_key) || api_key == "") {
    cli_abort("{.arg api_key} is not a valid character scalar.
              It is a {.cls {class(api_key)}}.")
  }

  if (!is_scalar_character(model) || model == "") {
    cli_abort("{.arg model} is not a valid character scalar.
              It is a {.cls {class(model)}}.")
  }

  if (!is_scalar_character(prompt)) {
    cli_abort("{.arg prompt} is not a valid character scalar.
              It is a {.cls {class(prompt)}}.")
  }

  if (!is_list(history) && !is.null(history)) {
    cli_abort("{.arg history} is not a valid list or NULL.
              It is a {.cls {class(history)}}.")
  }

  if (!is_scalar_logical(stream)) {
    cli_abort("{.arg stream} is not a valid boolean.
              It is a {.cls {class(stream)}}.")
  }
}

gptstudio_request_skeleton <- function(service, ...) {
  UseMethod("gptstudio_request_skeleton")
}

#' @export
gptstudio_request_skeleton.openai <- function(
    service = new_gptstudio_service("openai"),
    url = glue("{getOption(\"gptstudio.openai_url\")}/chat/completions"),
    api_key = Sys.getenv("OPENAI_API_KEY"),
    model = "gpt-4-turbo-preview",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = TRUE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_openai"
  )
}

#' @export
gptstudio_request_skeleton.huggingface <- function(
    service = new_gptstudio_service("huggingface"),
    url = "https://api-inference.huggingface.co/models",
    api_key = Sys.getenv("HF_API_KEY"),
    model = "gpt2",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_huggingface"
  )
}

#' @export
gptstudio_request_skeleton.anthropic <- function(
    service = new_gptstudio_service("anthropic"),
    url = "https://api.anthropic.com/v1/complete",
    api_key = Sys.getenv("ANTHROPIC_API_KEY"),
    model = "claude-3-5-sonnet-20240620",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_anthropic"
  )
}

#' @export
gptstudio_request_skeleton.google <- function(
    service = new_gptstudio_service("google"),
    url = "https://generativelanguage.googleapis.com/v1beta2/models/",
    api_key = Sys.getenv("GOOGLE_API_KEY"),
    model = ":generateText?key=",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_google"
  )
}

#' @export
gptstudio_request_skeleton.azure_openai <- function(
    service = new_gptstudio_service("azure_openai"),
    url = "user provided with environmental variables",
    api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
    model = "gpt-4o",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_azure_openai"
  )
}

#' @export
gptstudio_request_skeleton.ollama <- function(service = new_gptstudio_service("ollama"),
                                              model, prompt, history, stream) {
  new_gpstudio_request_skeleton(
    url = Sys.getenv("OLLAMA_HOST"),
    api_key = "JUST A PLACEHOLDER",
    model = model,
    prompt = prompt,
    history = history,
    stream = stream,
    class = "gptstudio_request_ollama"
  )
}

#' @export
gptstudio_request_skeleton.perplexity <- function(
    service = new_gptstudio_service("perplexity"),
    url = "https://api.perplexity.ai/chat/completions",
    api_key = Sys.getenv("PERPLEXITY_API_KEY"),
    model = "mistral-7b-instruct",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_perplexity"
  )
}

#' @export
gptstudio_request_skeleton.cohere <- function(service = new_gptstudio_service("cohere"),
                                              model = "command", prompt = "What is R?",
                                              history = NULL, stream = FALSE) {
  new_gpstudio_request_skeleton(
    url = "https://api.cohere.ai/v1/chat",
    api_key = Sys.getenv("COHERE_API_KEY"),
    model = model,
    prompt = prompt,
    history = history,
    stream = stream,
    class = "gptstudio_request_cohere"
  )
}

#' Create a Request Skeleton
#'
#' This function dynamically creates a request skeleton for different AI text
#' generation services.
#'
#' @param service The text generation service to use. Currently supports
#'   "openai", "huggingface", "anthropic", "google", "azure_openai", "ollama", and
#'   "perplexity".
#' @param prompt The initial prompt or question to pass to the text generation
#'   service.
#' @param history A list indicating the conversation history, where each element
#'   is a list with elements "role" (who is speaking; e.g., "system", "user")
#'   and "content" (what was said).
#' @param stream Logical; indicates if streaming responses should be used.
#'   Currently, this option is not supported across all services.
#' @param model The specific model to use for generating responses. Defaults to
#'   "gpt-3.5-turbo".
#' @param ... Additional arguments passed to the service-specific skeleton
#'   creation function.
#'
#' @return Depending on the selected service, returns a list that represents the
#'   configured request ready to be passed to the corresponding API.
#'
#' @examples
#' \dontrun{
#' request_skeleton <- gptstudio_create_skeleton(
#'   service = "openai",
#'   prompt = "Name the top 5 packages in R.",
#'   history = list(list(role = "system", content = "You are an R assistant")),
#'   stream = TRUE,
#'   model = "gpt-3.5-turbo"
#' )
#' }
#'
gptstudio_create_skeleton <- function(service = "openai",
                                      prompt = "Name the top 5 packages in R.",
                                      history = list(
                                        list(
                                          role = "system",
                                          content = "You are an R chat assistant"
                                        )
                                      ),
                                      stream = TRUE,
                                      model = "gpt-4o-mini",
                                      ...) {
  gptstudio_request_skeleton(
    service = new_gptstudio_service(service),
    model = model,
    prompt = prompt,
    history = history,
    stream = stream
  )
}
