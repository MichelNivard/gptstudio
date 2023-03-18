.onLoad <- function(lib, pkg) {
  op <- options()
  op_gptstudio <- list(
    gptstudio.valid_api  = FALSE,
    gptstudio.openai_key = NULL,
    gptstudio.max_tokens = 500,
    gptstudio.code_style = "no preference",
    gptstudio.skill      = "beginner"
  )
  toset <- !(names(op_gptstudio) %in% names(op))
  if (any(toset)) options(op_gptstudio[toset])
  invisible()
}

globalVariables(".rs.invokeShinyPaneViewer")
