#' Chat UI
#'
#' @param id id of the module
#'
mod_chat_ui <- function(id) {
  ns <- NS(id)

  bslib::card(
    rclipboard::rclipboardSetup(),
    height = "100%",
    bslib::card_body(
      class = "py-2 h-100",
      div(
        class = "d-flex flex-column h-100",
        div(
          class = "p-2 mh-100 overflow-auto",
          shiny::uiOutput(ns("all_chats_box")),
        ),
        div(
          class = "mt-auto",
          mod_prompt_ui(ns("prompt"))
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
    ns <- session$ns

    prompt <- mod_prompt_server("prompt", ide_colors)

    output$all_chats_box <- shiny::renderUI({
      prompt$chat_history %>%
        style_chat_history(ide_colors = ide_colors)
    })

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

  position_class <- switch(message$role,
    "user" = "justify-content-end",
    "assistant" = "justify-content-start"
  )

  htmltools::div(
    class = glue("row m-0 p-0 {position_class}"),
    htmltools::tags$div(
      class = glue("p-2 mb-2 rounded d-inline-block w-auto mw-100"),
      style = htmltools::css(
        `color` = colors$fg_color,
        `background-color` = colors$bg_color
      ),
      fontawesome::fa(icon_name),
      htmltools::tagList(
        shiny::markdown(message$content) |>
          html_to_taglist() |>
          add_copy_btns_to_pre()
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
create_ide_matching_colors <- function(role, ide_colors = get_ide_theme_info()) {
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

copy_to_clipboard_dep <- function() {
  htmltools::htmlDependency(
    name = "copyToClipboard",
    version = "0.1.0",
    src = "js",
    script = "copyToClipboard.js",
    package = "gptstudio"
  )
}
