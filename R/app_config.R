save_user_config <- function(code_style,
                             skill,
                             task,
                             language,
                             service,
                             model,
                             custom_prompt,
                             stream,
                             read_docs,
                             audio_input) {
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
      stream,
      read_docs,
      audio_input
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
  op_gptstudio <- list(
    gptstudio.code_style    = config$code_style,
    gptstudio.skill         = config$skill,
    gptstudio.task          = config$task,
    gptstudio.language      = config$language,
    gptstudio.service       = config$service,
    gptstudio.model         = config$model,
    gptstudio.custom_prompt = config$custom_prompt,
    gptstudio.stream        = config$stream,
    # added in v.3.1+ dev version
    gptstudio.read_docs     = config$read_docs,
    gptstudio.audio_input   = config$audio_input
  )
  options(op_gptstudio)
  invisible()
}
