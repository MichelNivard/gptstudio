mod_history_ui <- function(id) {
  ns <- NS(id)
  chat_history_messages <- read_chat_history()

  print(chat_history_messages)

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
    chat_history_messages %>%
      purrr::map(~chat_element(id = .x$id, title = .x$title))
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




chat_history_path <- function() {
  dir <- tools::R_user_dir("gptstudio", which = "data")
  file <- file.path(dir, "history.json")

  list(dir = dir, file = file)
}

write_chat_history <- function(chat_history) {
  history_path <- chat_history_path()
  if (!dir.exists(history_path$dir)) dir.create(history_path$dir)

  chat_history %>%
    purrr::keep(~!rlang::is_empty(.x$messages)) %>%
    jsonlite::write_json(path = history_path$file, auto_unbox = TRUE)
}

read_chat_history <- function() {
  history_path <- chat_history_path()

  if(!file.exists(history_path$file)) return(list())
  jsonlite::read_json(history_path$file)
}

chat_element <- function(
    id = ids::random_id(),
    title = "This is the title. Sometimes the title can be very  very long") {
  chat_title <- tags$div(
    class = "flex-grow-1 text-truncate",
    fontawesome::fa("message"),
    title
  ) %>%
    bslib::tooltip(title, placement = "right")

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
