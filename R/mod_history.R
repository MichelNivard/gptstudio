mod_history_ui <- function(id) {
  ns <- NS(id)

  btn_new_chat <- actionButton(
    inputId = ns("new_chat"),
    label = "New chat",
    icon = shiny::icon("plus"),
    class = "flex-grow-1 me-2"
  )

  btn_delete_all <- actionButton(
    inputId = ns("delete_all"),
    label = fontawesome::fa("trash"),
    class = "me-2"
  ) %>%
    bslib::tooltip("Delete all chats")

  btn_settings <-  actionButton(
    inputId = ns("settings"),
    label = fontawesome::fa("gear")
  ) %>%
    bslib::tooltip("Settings")

  tagList(
    tags$div(
      class = "d-flex mb-1",
      btn_new_chat,
      btn_delete_all,
      btn_settings,
    ),
    1:40 |> lapply(chat_element)
  )
}

mod_history_server <- function(id) {
  moduleServer(id, function(input, output, session) {
      rv <- reactiveValues()
      rv$selected_settings <- 0L
      rv$create_new_chat <- 0L

      observe({
        rv$selected_settings <- rv$selected_settings + 1L
      }) %>%
        bindEvent(input$settings)

      observe({
        rv$create_new_chat <- rv$create_new_chat + 1L
      }) %>%
        bindEvent(input$new_chat)

      # return value
      rv
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
    class = "px-2 py-1 mt-2 d-flex align-items-center",

    chat_title,
    edit_btn,
    delete_btn
  )
}
