#' Chat UI
#'
#' @param id id of the module
#' @param translator A Translator from `shiny.i18n::Translator`
#'
mod_chat_ui <- function(id, translator = create_translator()) {
  ns <- NS(id)

  bslib::card(
    class = "h-100",
    bslib::card_body(
      class = "py-2 h-100",
      div(
        class = "d-flex flex-column h-100",
        div(
          class = "p-2 mh-100 overflow-auto",
          welcomeMessageOutput(ns("welcome")),
          uiOutput(ns("history")),
          streamingMessageOutput(ns("streaming")),
        ),
        div(
          class = "mt-auto",
          style = css(
            "margin-left" = "40px",
            "margin-right" = "40px"
          ),
          htmltools::div(
            class = "position-relative",
            style = css(
              "width" = "100%"
            ),
            div(
              text_area_input_wrapper(
                inputId = ns("chat_input"),
                label = NULL,
                width = "100%",
                placeholder = translator$t("Write your prompt here"),
                value = "",
                resize = "none",
                textarea_class = "chat-prompt"
              )
            ),
            div(
              class = "position-absolute top-50 end-0 translate-middle",
              actionButton(
                inputId = ns("chat"),
                label = icon("fas fa-paper-plane"),
                class = "w-100 btn-primary p-1 chat-send-btn"
              ) %>%
                bslib::tooltip("Send (click or Enter)")
            )
          )
        )
      )
    )
  )
}

#' Chat server
#'
#' @param id id of the module
#' @param translator Translator from `shiny.i18n::Translator`
#' @param settings,history Reactive values from the settings and history module
#' @inheritParams run_chatgpt_app
#'
mod_chat_server <- function(id,
                            ide_colors = get_ide_theme_info(),
                            translator = create_translator(),
                            settings,
                            history) {
  # This is where changes will focus
  moduleServer(id, function(input, output, session) {
    # Session data ----

    rv <- reactiveValues()
    rv$reset_welcome_message <- 0L
    rv$reset_streaming_message <- 0L

    # UI outputs ----

    output$welcome <- renderWelcomeMessage({
      welcomeMessage(ide_colors)
    }) %>%
      bindEvent(rv$reset_welcome_message)


    output$history <- renderUI({
      history$chat_history %>%
        style_chat_history(ide_colors = ide_colors)
    })


    output$streaming <- renderStreamingMessage({
      # This has display: none by default. It is only shown when receiving a stream
      # After the stream is completed, it will reset.
      streamingMessage(ide_colors)
    }) %>%
      bindEvent(rv$reset_streaming_message)


    # Observers ----

    observe({
      rv$reset_welcome_message <- rv$reset_welcome_message + 1L
    }) %>%
      bindEvent(history$create_new_chat)


    observe({

      skeleton <- gptstudio_create_skeleton(
        service = settings$service,
        model = settings$model,
        prompt = input$chat_input,
        history = history$chat_history,
        stream = settings$stream
      ) %>%
        gptstudio_skeleton_build(
          skill = settings$skill,
          style = settings$style,
          task = settings$task,
          custom_prompt = settings$custom_prompt
        )

      response <- gptstudio_request_perform(
        skeleton = skeleton,
        shiny_session = session
      ) %>%
        gptstudio_response_process()

      history$chat_history <- response$history

      append_to_conversation_history(
        id = history$selected_conversation$id %||% ids::random_id(),
        title = history$selected_conversation$title %||% find_placeholder_title(history$chat_history), # nolint
        messages = history$chat_history
      )

      if (settings$stream) {
        rv$reset_streaming_message <- rv$reset_streaming_message + 1L
      }

      updateTextAreaInput(session, "chat_input", value = "")
    }) %>%
      bindEvent(input$chat)
  })
}
