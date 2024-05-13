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

  btn_settings <- actionButton(
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
    uiOutput(ns("conversation_history"))
  )
}

mod_history_server <- function(id, settings) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues()
    rv$selected_settings <- 0L
    rv$reload_conversation_history <- 0L
    rv$selected_conversation <- NULL # list
    rv$chat_history <- list()

    conversation_history <- reactive(read_conversation_history()) %>%
      bindEvent(rv$reload_conversation_history, rv$chat_history)

    output$conversation_history <- renderUI({
      conversation_history() %>%
        purrr::map(~ conversation(id = .x$id, title = .x$title, ns = ns))
    })

    observe({
      rv$selected_settings <- rv$selected_settings + 1L
    }) %>%
      bindEvent(input$settings)

    observe({
      rv$chat_history <- list()
      rv$selected_conversation <- NULL

      rv$reload_conversation_history <- rv$reload_conversation_history + 1L
    }) %>%
      bindEvent(input$new_chat, settings$create_new_chat, ignoreInit = TRUE)

    observe({
      conversation_history <- read_conversation_history()
      rv$selected_conversation <- conversation_history() %>%
        purrr::keep(~ .x$id == input$conversation_id) %>%
        purrr::pluck(1L)

      rv$chat_history <- rv$selected_conversation$messages
    }) %>%
      bindEvent(input$conversation_id)

    observe({
      showModal(modalDialog(
        tags$p("Are you sure?"),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_delete_all"), "Ok")
        )
      ))
    }) %>%
      bindEvent(input$delete_all)

    observe({
      conversation_history_file <- conversation_history_path()$file
      file.remove(conversation_history_file)
      removeModal(session)

      showNotification(
        ui = "Deleted all conversations",
        type = "warning",
        duration = 3,
        session = session
      )
      rv$reload_conversation_history <- rv$reload_conversation_history + 1L
    }) %>%
      bindEvent(input$confirm_delete_all)

    observe({
      rv$selected_conversation <- conversation_history() %>%
        purrr::keep(~ .x$id == input$conversation_to_edit) %>%
        purrr::pluck(1L)

      showModal(modalDialog(
        textAreaInput(
          inputId = ns("new_title"),
          label = "New title",
          value = rv$selected_conversation$title,
          width = "100%"
        ),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_new_title"), "Ok")
        )
      ))
    }) %>%
      bindEvent(input$conversation_to_edit)

    observe({
      if (!isTruthy(input$confirm_new_title)) {
        return()
      }

      append_to_conversation_history(
        id = rv$selected_conversation$id,
        title = input$new_title,
        messages = rv$selected_conversation$messages
      )

      rv$selected_conversation <- NULL

      rv$reload_conversation_history <- rv$reload_conversation_history + 1L

      removeModal(session)
    }) %>%
      bindEvent(input$confirm_new_title)

    observe({
      rv$selected_conversation <- conversation_history() %>%
        purrr::keep(~ .x$id == input$conversation_to_delete) %>%
        purrr::pluck(1L)

      msg <- glue::glue("Confirm deletion of conversation: {rv$selected_conversation$title}")

      showModal(modalDialog(
        tags$p(msg),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_single_delete"), "Ok")
        )
      ))
    }) %>%
      bindEvent(input$conversation_to_delete)

    observe({
      if (!isTruthy(input$confirm_single_delete)) {
        return()
      }

      conversation_history() %>%
        purrr::discard(~ .x$id == rv$selected_conversation$id) %>%
        write_conversation_history()



      rv$selected_conversation <- NULL

      rv$reload_conversation_history <- rv$reload_conversation_history + 1L

      removeModal(session)
      showNotification("Deleted!", duration = 3, type = "message", session = session)
    }) %>%
      bindEvent(input$confirm_single_delete)



    # return value
    rv
  })
}




conversation_history_path <- function() {
  dir <- tools::R_user_dir("gptstudio", which = "data")
  file <- file.path(dir, "conversation_history.json")

  list(dir = dir, file = file)
}

write_conversation_history <- function(conversation_history) {
  path <- conversation_history_path()
  if (!dir.exists(path$dir)) dir.create(path$dir, recursive = TRUE)

  conversation_history %>%
    purrr::keep(~ !rlang::is_empty(.x$messages)) %>%
    jsonlite::write_json(path = path$file, auto_unbox = TRUE)
}

read_conversation_history <- function() {
  path <- conversation_history_path()

  if (!file.exists(path$file)) {
    return(list())
  }
  jsonlite::read_json(path$file)
}

append_to_conversation_history <- function(id = ids::random_id(),
                                           title = "Some title",
                                           messages = list()) {
  conversation_history <- read_conversation_history() %>%
    purrr::discard(~ .x$id == id)

  chat_to_append <- list(
    id = id,
    title = title,
    last_modified = Sys.time(),
    messages = messages
  )

  conversation_history <- c(list(chat_to_append), conversation_history)
  write_conversation_history(conversation_history)
}

ns_safe <- function(id, ns = NULL) if (is.null(ns)) id else ns(id)

conversation <- function(
    id = ids::random_id(),
    title = "This is the title. Sometimes the title can be very  very long",
    ns = NULL) {
  conversation_title <- tags$div(
    class = "multi-click-input flex-grow-1 text-truncate",
    `shiny-input-id` = ns_safe("conversation_id", ns),
    value = id,
    fontawesome::fa("message"),
    title
  ) %>%
    tooltip_on_hover(title, placement = "right")

  edit_btn <- tags$span(
    fontawesome::fa("pen-to-square", margin_left = "0.4em"),
    class = "multi-click-input",
    `shiny-input-id` = ns_safe("conversation_to_edit", ns),
    value = id
  ) %>%
    tooltip_on_hover("Edit title", placement = "left")

  delete_btn <- tags$span(
    fontawesome::fa("trash-can", margin_left = "0.4em"),
    class = "multi-click-input",
    `shiny-input-id` = ns_safe("conversation_to_delete", ns),
    value = id
  ) %>%
    tooltip_on_hover("Delete this chat", placement = "right")

  tags$div(
    id = id,
    class = "px-2 py-1 mt-2 d-flex align-items-center",
    conversation_title,
    edit_btn,
    delete_btn
  )
}

tooltip_on_hover <- purrr::partial(bslib::tooltip, options = list(trigger = "hover"))

# Finds the first user prompt and returns it truncated
find_placeholder_title <- function(chat_history) {
  chat_history %>%
    purrr::keep(~(!is.null(.x$name)) && .x$name == "user_message") %>%
    purrr::pluck(1L, "content") %>%
    stringr::str_trunc(40L)
}
