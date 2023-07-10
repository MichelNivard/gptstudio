save_user_config <- function(code_style,
                             skill,
                             task,
                             language,
                             service,
                             model,
                             custom_prompt,
                             stream) {
  if (is.null(custom_prompt)) custom_prompt <- ""
  config <-
    data.frame(
      code_style,
      skill,
      task,
      language,
      service,
      model,
      custom_prompt,
      stream
    )
  user_config_path <- tools::R_user_dir("gptstudio", which = "config")
  user_config <- file.path(user_config_path, "config.yml")
  if (!dir.exists(user_config_path)) {
    dir.create(user_config_path, recursive = TRUE)
  }
  yaml::write_yaml(config, user_config)
  set_user_options(config)
}

set_user_options <- function(config) {
  op <- options()

  op_gptstudio <- list(
    gptstudio.code_style    = config$code_style,
    gptstudio.skill         = config$skill,
    gptstudio.task          = config$task,
    gptstudio.language      = config$language,
    gptstudio.service       = config$service,
    gptstudio.model         = config$model,
    gptstudio.custom_prompt = config$custom_prompt,
    gptstudio.stream        = config$stream
  )
  options(op_gptstudio)
  invisible()
}
