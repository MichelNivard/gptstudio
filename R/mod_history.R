mod_history_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(ns("new"), "New chat", icon = shiny::icon("plus")),
    actionButton(ns("delete_all"), "Delete All", icon = shiny::icon("trash")),
    1:6 |> lapply(chat_element)
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

chat_element <- function(id = ids::random_id(), label = "This is the title. Sometimes the title can be very  very long") {
  chat_title <- tags$div(
    class = "flex-grow-1 text-truncate",
    fontawesome::fa("message"),
    label
  ) %>%
    bslib::tooltip(label, placement = "right")

  edit_btn <- fontawesome::fa("pen-to-square", margin_left = "0.4em") %>%
    bslib::tooltip("Edit title", placement = "left")

  delete_btn <- fontawesome::fa("trash-can", margin_left = "0.4em") %>%
    bslib::tooltip("Delete this chat", placement = "right")

  tags$div(
    id = id,
    class = "p-2 d-flex align-items-center",

    chat_title,
    edit_btn,
    delete_btn
  )
}
