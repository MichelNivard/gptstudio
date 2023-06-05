#' Chat UI
#'
#' @param id id of the module
#' @param translator A Translator from `shiny.i18n::Translator`
#'
mod_chat_nostream_ui <- function(id, translator = create_translator()) {
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
          shiny::uiOutput(ns("history"))
        ),
        div(
          class = "mt-auto",
          mod_prompt_ui(ns("prompt"), translator)
        )
      )
    )
  )
}

#' Chat server
#'
#' @param id id of the module
#' @inheritParams run_chatgpt_app
#'
mod_chat_nostream_server <- function(id, ide_colors = get_ide_theme_info()) {
  moduleServer(id, function(input, output, session) {
    rv <- reactiveValues()
    rv$stream_ended <- 0L

    prompt <- mod_prompt_server("prompt")

    output$welcome <- renderWelcomeMessage({
      welcomeMessage(ide_colors)
    }) %>%
      bindEvent(prompt$clear_history)

    output$history <- shiny::renderUI({
      prompt$chat_history %>%
        style_chat_history(ide_colors = ide_colors)
    }) %>%
      bindEvent(prompt$chat_history, prompt$clear_history)

    shiny::observe({
      answer <- gpt_chat(history = prompt$chat_history,
                         style   = prompt$input_style,
                         skill   = prompt$input_skill,
                         model   = prompt$input_model)
      prompt$chat_history <- chat_history_append(
        history = prompt$chat_history,
        role    = "assistant",
        content = answer
      )
      rv$stream_ended <- rv$stream_ended + 1L
    }) %>%
      shiny::bindEvent(prompt$start_stream, ignoreInit = TRUE)
  })
}
