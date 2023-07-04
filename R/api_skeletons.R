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
    rlang::is_scalar_character(model),
    msg = "Model name is not a valid character scalar"
  )
  assert_that(
    rlang::is_scalar_character(prompt),
    msg = "Prompt is not a valid list"
  )
  assert_that(
    rlang::is_list(history),
    msg = "History is not a valid list"
  )
  assert_that(
    rlang::is_bool(stream),
    msg = "Stream is not a valid boolean"
  )
}

new_gptstudio_request_skeleton_openai <- function(
    url = "https://api.openai.com/v1/chat/completions",
    api_key = Sys.getenv("OPENAI_API_KEY"),
    model = "gpt-3.5-turbo",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = TRUE,
    max_tokens = getOption("gptstudio.max_tokens"),
    n = 1
) {
  new_gpstudio_request_skeleton(url,
                                api_key,
                                model,
                                prompt,
                                history,
                                stream,
                                class = "gptstudio_request_openai")
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
    stream = FALSE
) {
  new_gpstudio_request_skeleton(url,
                                api_key,
                                model,
                                prompt,
                                history,
                                stream,
                                class = "gptstudio_request_huggingface")
}

new_gptstudio_request_skeleton_anthropic <- function(
    url = "https://api.anthropic.com/v1/complete",
    api_key = Sys.getenv("ANTHROPIC_API_KEY"),
    model = "claude-1",
    prompt = "What is a ggplot?",
    history = list(
      list(
        role = "system",
        content = "You are an R chat assistant"
      )
    ),
    stream = FALSE
) {
  new_gpstudio_request_skeleton(url,
                                api_key,
                                model,
                                prompt,
                                history,
                                stream,
                                class = "gptstudio_request_anthropic")
}

gptstudio_create_skeleton <- function(service = "openai",
                                      prompt = "What is a ggplot?",
                                      history = list(
                                        list(
                                          role = "system",
                                          content = "You are an R chat assistant"
                                        )
                                      ),
                                      stream,
                                      model = "gpt-3.5-turbo",
                                      ...) {
  switch(service,
         "openai" = new_gptstudio_request_skeleton_openai(
           model = model,
           prompt = prompt,
           history = history,
           stream = stream),
         "huggingface" = new_gptstudio_request_skeleton_huggingface(
           model = model,
           prompt = prompt,
           history = history,
           stream = stream),
         "anthropic" = new_gptstudio_request_skeleton_anthropic(
           model = model,
           prompt = prompt,
           history = history,
           stream = stream))
}
