.onLoad <- function(lib, pkg) {
  env_language <- Sys.getenv("GPTSTUDIO_LANGUAGE")

  op <- options()

  op_gptstudio <- list(
    gptstudio.valid_api  = FALSE,
    gptstudio.openai_key = NULL,
    gptstudio.max_tokens = 500,
    gptstudio.code_style = "no preference",
    gptstudio.skill      = "beginner",
    gptstudio.task       = "coding",
    gptstudio.language   = if (env_language == "") "en" else (env_language),
    gptstudio.chat_model = "gpt-3.5-turbo",
    gptstudio.huggingface_model   = "gpt2",
    gptstudio.custom_prompt = "You are a helpful assistant."
  )
  toset <- !(names(op_gptstudio) %in% names(op))
  if (any(toset)) options(op_gptstudio[toset])
  invisible()
}

utils::globalVariables(".rs.invokeShinyPaneViewer")
