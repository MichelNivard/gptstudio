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
    url = glue("{getOption(\"gptstudio.openai_url\")}/chat/completions"),
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

new_gptstudio_request_skeleton_palm <- function(
    url = "https://generativelanguage.googleapis.com/v1beta2/models/",
    api_key = Sys.getenv("PALM_API_KEY"),
    model = ":generateText?key=",
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
                                class = "gptstudio_request_palm")
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
    n = 1
) {
  new_gpstudio_request_skeleton(url,
                                api_key,
                                model,
                                prompt,
                                history,
                                stream,
                                class = "gptstudio_request_azure_openai")
}


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
           stream = stream),
         "huggingface" = new_gptstudio_request_skeleton_huggingface(
           model = model,
           prompt = prompt,
           history = history,
           # forcing false until streaming implemented for hf
           stream = FALSE),
         "anthropic" = new_gptstudio_request_skeleton_anthropic(
           model = model,
           prompt = prompt,
           # forcing false until streaming implemented for anthropic
           stream = FALSE),
         "palm" = new_gptstudio_request_skeleton_palm(
           model = model,
           prompt = prompt,
           history = history,
           # forcing false until streaming implemented for palm
           stream = FALSE),
         "azure_openai" = new_gptstudio_request_skeleton_azure_openai(
           model = model,
           prompt = prompt,
           history = history,
           # forcing false until streaming implemented for palm
           stream = FALSE))
}

