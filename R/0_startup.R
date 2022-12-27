.onLoad <- function(lib, pkg) {
  op <- options()
  op.gptstudio <- list(
    gptstudio.valid_api = FALSE,
    gptstudio.openai_key = NULL
  )

  toset <- !(names(op.gptstudio) %in% names(op))
  if (any(toset)) options(op.gptstudio[toset])

  invisible()
}

globalVariables(".rs.invokeShinyPaneViewer")
