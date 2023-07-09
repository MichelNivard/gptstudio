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
style_chat_message <- function(message,
                               ide_colors = get_ide_theme_info()) {
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
      shiny::icon(icon_name, lib = "font-awesome"),
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

#' Custom textAreaInput
#'
#' Modified version of `textAreaInput()` that removes the label container.
#' It's used in `mod_prompt_ui()`
#'
#' @inheritParams shiny::textAreaInput
#' @param textarea_class Class to be applied to the textarea element
#'
#' @return A modified textAreaInput
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
#' @param role Author of the message. One of `c("user", "assistant")`
#' @param content Content of the message. If it is from the user most probably
#' comes from an interactive input.
#'
#' @return list of chat messages
#'
chat_history_append <- function(history, role, content) {
  c(history, list(
    list(role = role, content = content)
  ))
}
