.onLoad <- function(lib, pkg) {
  env_language <- Sys.getenv("GPTSTUDIO_LANGUAGE")

  op <- options()

  op_gptstudio <- list(
    gptstudio.valid_api  = FALSE,
    gptstudio.openai_key = NULL,
    gptstudio.max_tokens = 500,
    gptstudio.code_style = "no preference",
    gptstudio.skill      = "beginner",
    gptstudio.language = if (env_language == "") "en" else (env_language)
  )
  toset <- !(names(op_gptstudio) %in% names(op))
  if (any(toset)) options(op_gptstudio[toset])
  invisible()
}

utils::globalVariables(".rs.invokeShinyPaneViewer")
