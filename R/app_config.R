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

  write_user_config_file(config)
  set_user_options(config)
}

user_config_dir <- function() {
  path <- tools::R_user_dir("gptstudio", which = "config")

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  return(path)
}

user_config_file <- function() {
  file.path(user_config_dir(), "config.yml")
}

read_user_config_file <- function() {
  yaml::read_yaml(user_config_file())
}

write_user_config_file <- function(config) {
  yaml::write_yaml(config, user_config_file())
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
