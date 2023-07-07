.onLoad <- function(lib, pkg) {
  user_config <-
    file.path(tools::R_user_dir("gptstudio", which = "config"), "config.yml")

  if (file.exists(user_config)) {
    config <- yaml::read_yaml(user_config)
  } else {
    config <- yaml::read_yaml(system.file("rstudio/config.yml",
                                          package = "gptstudio"))
  }

  op <- options()

  op_gptstudio <- list(
    gptstudio.valid_api     = FALSE,
    gptstudio.openai_key    = NULL,
    gptstudio.max_tokens    = 500,
    gptstudio.openai_url    = "https://api.openai.com/v1",
    gptstudio.code_style    = config$code_style,
    gptstudio.skill         = config$skill,
    gptstudio.task          = config$task,
    gptstudio.language      = config$language,
    gptstudio.service       = config$service,
    gptstudio.model         = config$model,
    gptstudio.custom_prompt = config$custom_prompt,
    gptstudio.stream        = config$stream
  )

  toset <- !(names(op_gptstudio) %in% names(op))
  if (any(toset)) options(op_gptstudio[toset])
  invisible()
}

utils::globalVariables(".rs.invokeShinyPaneViewer")
