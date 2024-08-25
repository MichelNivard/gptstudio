#' Style Chat History
#'
#' This function processes the chat history, filters out system messages, and
#' formats the remaining messages with appropriate styling.
#'
#' @param history A list of chat messages with elements containing 'role' and
#' 'content'.
#' @inheritParams gptstudio_run_chat_app
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
#' @inheritParams gptstudio_run_chat_app
#' @return An HTML element.
style_chat_message <- function(message,
                               ide_colors = get_ide_theme_info()) {
  colors <- create_ide_matching_colors(message$role, ide_colors)
  icon_name <- switch(message$role,
    "user" = "person-fill",
    "assistant" = "robot"
  )

  if (!is.null(message$name) && message$name == "docs") {
    message_content <- render_docs_message_content(message$content)
  } else {
    message_content <- shiny::markdown(message$content)
  }

  bubble_style <- htmltools::css(
    `color` = colors$fg_color,
    `background-color` = colors$bg_color,
    `border-radius` = if (message$role == "user") "20px 20px 0 20px" else "20px 20px 20px 0",
    `box-shadow` = "0 2px 4px rgba(0, 0, 0, 0.2)"
  )

  icon_style <- htmltools::css(
    `width` = "30px",
    `height` = "30px",
    `background-color` = colors$bg_color,
    `color` = colors$fg_color,
    `border-radius` = "50%",
    `display` = "flex",
    `align-items` = "center",
    `justify-content` = "center",
    `flex-shrink` = "0"
  )

  htmltools::div(
    class = "row m-0 p-2",
    htmltools::div(
      class = if (message$role == "user") {
        "d-flex justify-content-end w-100"
      } else {
        "d-flex w-100"
      },
      htmltools::div(
        class = "d-flex align-items-end",
        if (message$role == "assistant") {
          htmltools::div(
            style = icon_style,
            class = "m-1",
            bsicons::bs_icon(icon_name)
          )
        },
        htmltools::div(
          class = glue("p-3 mb-2 rounded d-inline-block chat-bubble {message$role}-bubble"),
          style = bubble_style,
          htmltools::div(
            class = glue("{message$role}-message-wrapper"),
            htmltools::tagList(message_content)
          )
        ),
        if (message$role == "user") {
          htmltools::div(
            style = icon_style,
            class = "m-1",
            bsicons::bs_icon(icon_name)
          )
        }
      )
    )
  )
}

#' Chat message colors in RStudio
#'
#' This returns a list of color properties for a chat message
#'
#' @param role The role of the message author
#' @inheritParams gptstudio_run_chat_app
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

render_docs_message_content <- function(x) {
  docs_info <- x %>%
    stringr::str_extract("gptstudio-metadata-docs-start.*gptstudio-metadata-docs-end") %>%
    stringr::str_remove("gptstudio-metadata-docs-start-") %>%
    stringr::str_remove("-gptstudio-metadata-docs-end") %>%
    stringr::str_split_1(pattern = "-")

  pkg_ref <- docs_info[1]
  topic <- docs_info[2]

  message_content <- x %>%
    stringr::str_remove("gptstudio-metadata-docs-start.*gptstudio-metadata-docs-end") %>%
    shiny::markdown()

  message_content <- tags$div(
    "R documentation:",
    tags$code(glue::glue("{pkg_ref}::{topic}")) %>%
      bslib::tooltip(message_content)
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
  function(inputId, # nolint
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
#' @param name Name for the author of the message. Currently used to support rendering of help pages
#'
#' @return list of chat messages
#'
chat_history_append <- function(history, role, content, name = NULL) {
  new_message <- list(
    role = role,
    content = content,
    name = name
  ) %>%
    purrr::compact()

  c(history, list(new_message))
}
