#' Prompt of the chat
#'
#' HTML element with a text input and some buttons
#'
#' @param id id of the module
#' @inheritParams mod_chat_ui
#'
#' @return HTML element
mod_prompt_ui <- function(id, translator = create_translator()) {
  ns <- shiny::NS(id)

  htmltools::div(
    class = "d-flex p-3",
    div(
      class = "flex-grow-1 pe-3",
      text_area_input_wrapper(
        inputId = ns("chat_input"),
        label = NULL,
        width = "100%",
        placeholder = translator$t("Write your prompt here"),
        value = "",
        resize = "vertical",
        rows = 5,
        textarea_class = "chat-prompt"
      )
    ),
    div(
      style = htmltools::css(width = "50px"),
      shiny::actionButton(
        inputId = ns("chat"),
        label = fontawesome::fa("fas fa-paper-plane"),
        class = "w-100 btn-primary p-1 chat-send-btn"
      ),
      actionButton(
        inputId = ns("clear_history"),
        label = fontawesome::fa("eraser"),
        class = "w-100 btn-primary mt-2 p-1"
      ),
      bs_dropdown(
        label = fontawesome::fa("gear"),
        id = "dropd_settings",
        class = "w-100 btn-primary mt-2 p-1",
        shiny::selectInput(
          inputId = ns("style"),
          label = translator$t("Programming Style"),
          choices = c("tidyverse", "base", "no preference"),
          width = "100%"
        ),
        shiny::selectInput(
          inputId = ns("skill"),
          label = translator$t("Programming Proficiency"),
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "100%"
        )
      )
    )
  )
}

#' Prompt Server
#'
#' This server receives the input of the user and makes the chat history
#'
#' @param id id of the module
#'
#' @return A shiny server
mod_prompt_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    rv <- reactiveValues()
    rv$chat_history <- list()
    rv$clear_history <- 0L
    rv$start_stream <- 0L
    rv$input_prompt <- NULL
    rv$input_style <- NULL
    rv$input_skill <- NULL


    shiny::observe({
      rv$chat_history <- chat_history_append(
        history = rv$chat_history,
        role = "user",
        content = input$chat_input
      )

      rv$input_prompt <- input$chat_input
      rv$input_style <- input$style
      rv$input_skill <- input$skill

      shiny::updateTextAreaInput(session, "chat_input", value = "")
      rv$start_stream <- rv$start_stream + 1L
    }) %>%
      shiny::bindEvent(input$chat)


    shiny::observe({
      rv$chat_history <- list()
      rv$clear_history <- rv$clear_history + 1L
    }) %>%
      shiny::bindEvent(input$clear_history)



    # testing ----
    exportTestValues(
      chat_history = rv$chat_history
    )

    # module return ----
    rv
  })
}




#' Custom textAreaInput
#'
#' Modified version of `textAreaInput()` that removes the label container.
#' It's used in `mod_prompt_ui()`
#'
#' @inheritParams shiny::textAreaInput
#' @param textarea_class Class to be applied to the textarea element
#'
#' @return A modified textAreaInput
#'
text_area_input_wrapper <-
  function(inputId,
           label,
           value = "",
           width = NULL,
           height = NULL,
           cols = NULL,
           rows = NULL,
           placeholder = NULL,
           resize = NULL,
           textarea_class = NULL) {
    tag <- shiny::textAreaInput(
      inputId = inputId,
      label = label,
      value = value,
      width = width,
      height = height,
      cols = cols,
      rows = rows,
      placeholder = placeholder,
      resize = resize
    )

    tag_query <- htmltools::tagQuery(tag)

    if (is.null(label)) {
      tag_query$children("label")$remove()$resetSelected()
    }

    if (!is.null(textarea_class)) {
      tag_query$children("textarea")$addClass(textarea_class)$resetSelected
    }

    tag_query$allTags()
  }

#' Append to chat history
#'
#' This appends a new response to the chat history
#'
#' @param history List containing previous responses.
#' @param role Author of the message. One of `c("user", "assitant")`
#' @param content Content of the message. If it is from the user most probably comes from an interactive input.
#'
#' @return list of chat messages
#'
chat_history_append <- function(history, role, content) {
  c(history, list(
    list(role = role, content = content)
  ))
}
