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
            "margin-left" = "20px",
            "margin-right" = "20px"
          ),
          htmltools::div(
            class = "position-relative",
            style = css(
              "width" = "100%"
            ),
            uiOutput(ns("chat_with_audio"))
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
#' @inheritParams gptstudio_run_chat_app
#'
mod_chat_server <- function(id,
                            ide_colors = get_ide_theme_info(),
                            translator = create_translator(),
                            settings,
                            history) {
  moduleServer(id, function(input, output, session) {
    # Session data ----
    rv <- reactiveValues(
      reset_welcome_message = 0L,
      reset_streaming_message = 0L,
      audio_input = getOption("gptstudio.audio_input")
    )

    # UI outputs ----
    output$welcome <-
      renderWelcomeMessage({
        welcomeMessage(ide_colors)
      }) %>% bindEvent(rv$reset_welcome_message)

    output$history <- renderUI({
      history$chat_history %>% style_chat_history(ide_colors = ide_colors)
    })

    output$streaming <- renderStreamingMessage({
      streamingMessage(ide_colors)
    }) %>% bindEvent(rv$reset_streaming_message)

    # Observers ----
    observeEvent(history$create_new_chat, {
      rv$reset_welcome_message <- rv$reset_welcome_message + 1L
    })

    # Helper function for chat processing
    process_chat <- function(prompt) {
      response <- chat(
        prompt = prompt,
        service = settings$service,
        history = history$chat_history,
        stream = settings$stream,
        model = settings$model,
        skill = settings$skill,
        style = settings$style,
        task = settings$task,
        custom_prompt = settings$custom_prompt,
        process_response = TRUE,
        session = session
      )

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
    }

    observeEvent(input$chat, {
      process_chat(input$chat_input)
    })

    observeEvent(input$clip, {
      req(input$clip)
      new_prompt <- transcribe_audio(input$clip)
      process_chat(new_prompt)
    })

    output$chat_with_audio <- renderUI({
      ns <- session$ns
      audio_recorder <- if (rv$audio_input) {
        div(
          style = "position: absolute; right: 20px; top: 25%; transform: translateY(-50%);",
          input_audio_clip(ns("clip"),
            record_label = NULL,
            stop_label = NULL,
            show_mic_settings = FALSE,
          )
        )
      }

      image_input <- if (TRUE) {
        div(
          # style = "position: absolute; right: 800px; top: 25%; transform: translateY(-50%);",
          fileInput(
            ns("image"),
            buttonLabel = bsicons::bs_icon("image"),
            placeholder = "Upload an image",
            label = NULL,
            multiple = FALSE,
            accept = "image/*"
          )
        )
      }

      tagList(
        div(
          div(
            style = "flex-grow: 1; height: 100%;",
            text_area_input_wrapper(
              inputId = ns("chat_input"),
              label = NULL,
              width = "100%",
              height = "100%",
              value = "",
              resize = "none",
              textarea_class = "chat-prompt"
            )
          ),
          div(
            style = "position: absolute; right: 10px; top: 50%; transform: translateY(-50%);",
            bslib::input_task_button(
              id = ns("chat"),
              label = icon("fas fa-paper-plane"),
              label_busy = NULL,
              class = "btn-secondary p-2 chat-send-btn"
            ) %>% bslib::tooltip("Send (click or Enter)")
          ),
          audio_recorder,
        ),
          # image_input,
      )
    })
  })
}
