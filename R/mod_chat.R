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
          shiny::uiOutput(ns("history")),
          streamingMessageOutput(ns("streaming"))
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
mod_chat_server <- function(id, ide_colors = get_ide_theme_info()) {
  moduleServer(id, function(input, output, session) {
    rv <- reactiveValues()
    rv$stream_ended <- 0L

    waiter_color <-
      if (ide_colors$is_dark) "rgba(255,255,255,0.5)" else "rgba(0,0,0,0.5)"

    prompt <- mod_prompt_server("prompt")

    output$welcome <- renderWelcomeMessage({
      welcomeMessage(ide_colors)
    }) %>%
      bindEvent(prompt$clear_history)


    output$streaming <- renderStreamingMessage({
      # This has display: none by default. It is inly shown when receiving an stream
      # After the stream is completed it will reset.
      streamingMessage(ide_colors)
    }) %>%
      bindEvent(rv$stream_ended)


    output$history <- shiny::renderUI({
      prompt$chat_history %>%
        style_chat_history(ide_colors = ide_colors)
    }) %>%
      bindEvent(prompt$chat_history, prompt$clear_history)


    shiny::observe({

      stream_handler <- StreamHandler$new(
        session = session,
        user_prompt = prompt$input_prompt
      )

      stream_chat_completion(
        prompt = prompt$input_prompt,
        history = prompt$chat_history,
        style = prompt$input_style,
        skill = prompt$input_skill,
        element_callback = stream_handler$handle_streamed_element
      )

      prompt$chat_history <- chat_history_append(
        history = prompt$chat_history,
        role = "assistant",
        content = stream_handler$current_value
      )

      rv$stream_ended <- rv$stream_ended + 1L

    }) %>%
      shiny::bindEvent(prompt$start_stream, ignoreInit = TRUE)

    # testing ----
    exportTestValues(
      chat_history = prompt$chat_history
    )
  })
}






#' Style Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
#' @inheritParams run_chatgpt_app
#'
#' @return A list of formatted chat messages with styling applied, excluding
#' system messages.
#' @examples
#' chat_history_example <- list(
#'   list(role = "user", content = "Hello, World!"),
#'   list(role = "system", content = "System message"),
#'   list(role = "assistant", content = "Hi, how can I help?")
#' )
#'
#' \dontrun{
#' style_chat_history(chat_history_example)
#' }
style_chat_history <- function(history, ide_colors = get_ide_theme_info()) {
  history %>%
    purrr::discard(~ .x$role == "system") %>%
    purrr::map(style_chat_message, ide_colors = ide_colors)
}

#' Style chat message
#'
#' Style a message based on the role of its author.
#'
#' @param message A chat message.
#' @inheritParams run_chatgpt_app
#' @return An HTML element.
style_chat_message <- function(message, ide_colors = get_ide_theme_info()) {
  colors <- create_ide_matching_colors(message$role, ide_colors)

  icon_name <- switch(message$role,
    "user" = "fas fa-user",
    "assistant" = "fas fa-robot"
  )

  # nolint start
  position_class <- switch(message$role,
    "user" = "justify-content-end",
    "assistant" = "justify-content-start"
  )
  # nolint end

  htmltools::div(
    class = glue("row m-0 p-0 {position_class}"),
    htmltools::tags$div(
      class = glue("p-2 mb-2 rounded d-inline-block w-auto mw-100"),
      style = htmltools::css(
        `color` = colors$fg_color,
        `background-color` = colors$bg_color
      ),
      fontawesome::fa(icon_name),
      htmltools::tags$div(
        class = glue("{message$role}-message-wrapper"),
        htmltools::tagList(
          shiny::markdown(message$content)
        )
      )
    )
  )
}

#' Chat message colors in RStudio
#'
#' This returns a list of color properties for a chat message
#'
#' @param role The role of the message author
#' @inheritParams run_chatgpt_app
#' @return list
#'
create_ide_matching_colors <- function(role,
                                       ide_colors = get_ide_theme_info()) {
  assert_that(role %in% c("user", "assistant"))

  bg_colors <- if (ide_colors$is_dark) {
    list(
      user = colorspace::lighten(ide_colors$bg, 0.15),
      assistant = colorspace::lighten(ide_colors$bg, 0.25)
    )
  } else {
    list(
      user = colorspace::lighten(ide_colors$bg, -0.2),
      assistant = colorspace::lighten(ide_colors$bg, -0.1)
    )
  }

  list(
    bg_color = bg_colors[[role]],
    fg_color = ide_colors$fg
  )
}
