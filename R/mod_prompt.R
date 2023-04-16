#' Chat card
#'
#' @return A chat card
#' @export
#'
mod_prompt_ui <- function(id) {
  ns <- shiny::NS(id)

  htmltools::div(
    class = "d-flex p-3",
    div(
      class = "flex-grow-1 pe-3",
      textAreaInputWrapper(
        inputId = ns("chat_input"),
        label = NULL,
        width = "100%",
        placeholder = "Write your prompt here",
        value = "",
        resize = "vertical",
        rows = 3
      )
    ),
    div(
      style = htmltools::css(width = "50px"),
      shiny::actionButton(
        inputId = ns("chat"),
        label = fontawesome::fa("fas fa-paper-plane"),
        class = "w-100 btn-primary p-1"
      ),
      actionButton(
        inputId = ns("clear_history"),
        label = fontawesome::fa("eraser"),
        class = "w-100 btn-primary mt-2 p-1"
      ),
      bs_dropdown(
        label = fontawesome::fa("gear"),
        class = "w-100 btn-primary mt-2 p-1",
        shiny::selectInput(
          inputId = ns("style"),
          label = "Programming Style",
          choices = c("tidyverse", "base", "no preference"),
          width = "100%"
        ),
        shiny::selectInput(
          inputId = ns("skill"),
          label = "Programming Proficiency",
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "100%"
        )
      )
    )
  )
}

mod_prompt_server <- function(id, rv) {
    moduleServer(id, function(input, output, session) {

      rv$all_chats_formatted <- NULL
      rv$all_chats <- NULL

      shiny::observe({
        waiter::waiter_show(
          html = shiny::tagList(spin_flower(), shiny::h3("Asking ChatGPT...")),
          color = waiter::transparent(0.5)
        )

        interim <- gpt_chat(
          query = input$chat_input,
          history = rv$all_chats,
          style = input$style,
          skill = input$skill
        )

        rv$all_chats <- chat_create_history(interim)

        rv$all_chats_formatted <- make_chat_history(rv$all_chats)

        waiter::waiter_hide()
        shiny::updateTextAreaInput(session, "chat_input", value = "")
      }) %>%
        shiny::bindEvent(input$chat)

      shiny::observe(rv$all_chats <- NULL) %>%
        shiny::bindEvent(input$clear_history)

    })
}

textAreaInputWrapper <-
  function(inputId,
           label,
           value = "",
           width = NULL,
           height = NULL,
           cols = NULL,
           rows = NULL,
           placeholder = NULL,
           resize = NULL) {

    tag <- shiny::textAreaInput(
      inputId = inputId,
      label = label,
      value = value,
      height = height,
      cols = cols,
      rows = rows,
      placeholder = placeholder,
      resize = resize
    )

    if(is.null(label)) {
      tag_query <- htmltools::tagQuery(tag)

      tag_query$children("label")$remove()$allTags()

    } else {
      tag
    }
  }

chat_create_history <- function(response) {
  previous_responses <- response[[1]]
  last_response <- response[[2]]$choices

  c(
    previous_responses,
    list(
      list(
        role    = last_response$message.role,
        content = last_response$message.content
      )
    )
  )
}


#' Make Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
#'
#' @return A list of formatted chat messages with styling applied, excluding
#' system messages.
#' @export
#' @examples
#' chat_history_example <- list(
#'   list(role = "user", content = "Hello, World!"),
#'   list(role = "system", content = "System message"),
#'   list(role = "assistant", content = "Hi, how can I help?")
#' )
#' make_chat_history(chat_history_example)
make_chat_history <- function(history) {
  history <- purrr::discard(history, ~.x$role == "system")

  purrr::map(history, chat_message)
}

chat_message <- function(message) {
  icon_name <- switch (message$role,
    "user" = "fas fa-user",
    "assistant" = "fas fa-robot"
  )

  bg_class <- switch (message$role,
    "user" = "bg-primary",
    "assistant" = "bg-secondary"
  )

  position_class <- switch (message$role,
    "user" = "justify-content-end",
    "assistant" = "justify-content-start"
  )

  htmltools::div(
    class = glue("row m-0 p-0 {position_class}"),
    htmltools::tags$div(
      class = glue("p-2 mb-2 rounded d-inline-block w-auto mw-100 {bg_class}"),
      fontawesome::fa(icon_name),
      shiny::markdown(message$content)
    )
  )
}
