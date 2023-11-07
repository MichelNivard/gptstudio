mod_history_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      style = htmltools::css("background-color" = "#C8C8C8", width = "100px", height = "100px")
    )
  )
}

mod_history_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {

    }
  )
}





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
