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
  assert_that(
    rlang::is_scalar_character(url),
    msg = "URL is not a valid character scalar"
  )
  assert_that(
    rlang::is_scalar_character(api_key) && api_key != "",
    msg = "API key is not valid"
  )
  assert_that(
    rlang::is_scalar_character(model) && model != "",
    msg = "Model name is not a valid character scalar"
  )
  assert_that(
    rlang::is_scalar_character(prompt),
    msg = "Prompt is not a valid list"
  )

  # is list or is NULL
  assert_that(
    rlang::is_list(history) || is.null(history),
    msg = "History is not a valid list or NULL"
  )
  assert_that(
    rlang::is_bool(stream),
    msg = "Stream is not a valid boolean"
  )
}

new_gptstudio_request_skeleton_openai <- function(
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
    stream = TRUE,
    n = 1) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_openai"
  )
}


new_gptstudio_request_skeleton_huggingface <- function(
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

new_gptstudio_request_skeleton_anthropic <- function(
    url = "https://api.anthropic.com/v1/complete",
    api_key = Sys.getenv("ANTHROPIC_API_KEY"),
    model = "claude-2.1",
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

new_gptstudio_request_skeleton_google <- function(
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

new_gptstudio_request_skeleton_azure_openai <- function(
    url = "user provided with environmental variables",
    api_key = Sys.getenv("AZURE_OPENAI_KEY"),
    model = "gpt-3.5-turbo",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE,
    n = 1) {
  new_gpstudio_request_skeleton(url,
    api_key,
    model,
    prompt,
    history,
    stream,
    class = "gptstudio_request_azure_openai"
  )
}

new_gptstudio_request_skeleton_ollama <- function(model, prompt, history, stream) {
  new_gpstudio_request_skeleton(
    url = Sys.getenv("OLLAMA_HOST"),
    api_key = "JUST A PLACESHOLDER",
    model = model,
    prompt = prompt,
    history = history,
    stream = stream,
    class = "gptstudio_request_ollama"
  )
}

new_gptstudio_request_skeleton_perplexity <- function(
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

# Cohere Skeleton Creation Function
new_gptstudio_request_skeleton_cohere <- function(model = "command", prompt = "What is R?",
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
#' @export
gptstudio_create_skeleton <- function(service = "openai",
                                      prompt = "Name the top 5 packages in R.",
                                      history = list(
                                        list(
                                          role = "system",
                                          content = "You are an R chat assistant"
                                        )
                                      ),
                                      stream = TRUE,
                                      model = "gpt-3.5-turbo",
                                      ...) {
  switch(service,
    "openai" = new_gptstudio_request_skeleton_openai(
      model = model,
      prompt = prompt,
      history = history,
      stream = stream
    ),
    "huggingface" = new_gptstudio_request_skeleton_huggingface(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for hf
      stream = FALSE
    ),
    "anthropic" = new_gptstudio_request_skeleton_anthropic(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for anthropic
      stream = FALSE
    ),
    "google" = new_gptstudio_request_skeleton_google(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for google
      stream = FALSE
    ),
    "azure_openai" = new_gptstudio_request_skeleton_azure_openai(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for azure openai
      stream = FALSE
    ),
    "ollama" = new_gptstudio_request_skeleton_ollama(
      model = model,
      prompt = prompt,
      history = history,
      stream = stream
    ),
    "perplexity" = new_gptstudio_request_skeleton_perplexity(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for perplexity
      stream = FALSE
    ),
    "cohere" = new_gptstudio_request_skeleton_cohere(
      model = model,
      prompt = prompt,
      history = history,
      # forcing false until streaming implemented for cohere
      stream = FALSE
    )
  )
}
