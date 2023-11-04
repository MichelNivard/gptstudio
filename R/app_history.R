write_chat_history <- function(chat_history) {
  dir_path <- tools::R_user_dir("gptstudio", which = "history")
  if (!dir.exists(dir_path)) dir.create(dir_path)

  file_path <- file.path(dir_path, "history.json")
  jsonlite::write_json(x = chat_history, path = file_path)
}

read_chat_history <- function() {
  dir_path <- tools::R_user_dir("gptstudio", which = "history")
  file_path <- file.path(dir_path, "history.json")

  if(!file.exists(file_path)) return(list())
  jsonlite::read_json(file_path)
}
