new_gpstudio_request_skeleton <- function(url, api_key, model, prompt, history,
                                          stream, ..., class = character()) {
  assertthat::assert_that(
    rlang::is_scalar_character(url),
    rlang::is_scalar_character(api_key) && api_key != "",
    rlang::is_scalar_character(model),
    rlang::is_scalar_character(prompt),
    rlang::is_list(history),
    rlang::is_bool(stream),
    msg = "Not a valid skeleton"
  )

  structure(
    list(
      url = url,
      api_key = api_key,
      model = model,
      prompt = prompt,
      history = history,
      stream = stream,
      extras = list(
        ...
      )
    ),
    class = c(class, "gptstudio_request_skeleton")
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
    stream = FALSE,
    max_tokens = getOption("gptstudio.max_tokens"),
    n = 1
) {
  new_gpstudio_request_skeleton(url,
                                api_key,
                                model,
                                prompt,
                                history,
                                stream,
                                extrax = list(max_tokens, n),
                                class = "gptstudio_request_skeleton_openai")
}
