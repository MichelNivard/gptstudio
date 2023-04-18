#' Chat UI
#'
#' @param id id of the module
#'
mod_chat_ui <- function(id) {
    ns <- NS(id)

    bslib::card(
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
#'
mod_chat_server <- function(id) {
    moduleServer(id, function(input, output, session) {
      prompt <- mod_prompt_server("prompt")

      output$all_chats_box <- shiny::renderUI({
        prompt$chat_history %>%
          style_chat_history()
      })

    })
}






#' Style Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
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
#' \dontrun{style_chat_history(chat_history_example)}
style_chat_history <- function(history) {
  history %>%
    purrr::discard(~.x$role == "system") %>%
    purrr::map(style_chat_message)
}

#' Style chat message
#'
#' Style a message based on the role of its author.
#'
#' @param message A chat message.
#'
#' @return An HTML element.
style_chat_message <- function(message) {
  colors <- create_ide_matching_colors(message$role)

  icon_name <- switch (message$role,
                       "user" = "fas fa-user",
                       "assistant" = "fas fa-robot"
  )

  position_class <- switch (message$role,
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
      shiny::markdown(message$content)
    )
  )
}

#' Chat message colors in RStudio
#'
#' This returns a list of color properties for a chat message
#'
#' @param role The role of the message author
#'
#' @return list
#'
create_ide_matching_colors <- function(role) {
  ide_colors <- get_ide_colors()

  bg_colors <- if (ide_colors$is_dark) {
    list(
      user = lighten_color(ide_colors$bg, 0.20),
      assistant = lighten_color(ide_colors$bg, 0.35)
    )
  } else {
    list(
      user = lighten_color(ide_colors$bg, -0.2),
      assistant = lighten_color(ide_colors$bg, -0.1)
    )
  }

  list(
    bg_color = bg_colors[[role]],
    fg_color = ide_colors$fg
  )
}

get_ide_colors <- function() {
  if (rstudioapi::isAvailable()) {
    rstheme_info <- rstudioapi::getThemeInfo()

    list(
      is_dark = rstheme_info$dark,
      bg = rgb_str_to_hex(rstheme_info$background),
      fg = rgb_str_to_hex(rstheme_info$foreground)
    )
  } else {
    # based on RStudio IDE theme "Solarized Dark"
    list(
      is_dark = TRUE,
      bg = "#002B36",
      fg = "#93A1A1"
    )
  }
}

#' Make a color lighter or darker
#'
#' This wraps `grDevices::adjustcolor()` for easier usage. Leaves the alpha value as is.
#'
#' @param color An hex color
#' @param percentage A number from 0 to 1 indicating how lighter should the color be. When negative it will darken `color`
#'
#' @return An hex color
#'
lighten_color <- function(color, percentage = 0) {
  ratio <- 1 + percentage
  grDevices::adjustcolor(color, red.f = ratio, green.f = ratio, blue.f = ratio)
}
