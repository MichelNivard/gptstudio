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
  icon_name <- switch(
    message$role,
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
    `box-shadow` = "0 2px 4px rgba(0, 0, 0, 0.2)",
    `max-width` = "85%", # Increased from 80% to allow more space
    `min-width` = "auto", # Allow the bubble to shrink to fit content
    `width` = "fit-content", # Make the bubble fit its content
    `word-break` = "break-word", # Changed from word-wrap to word-break
    `white-space` = "normal" # Ensure normal wrapping behavior
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
    style = "max-width: 100%; overflow-x: hidden;",
    htmltools::div(
      class = if (message$role == "user") {
        "d-flex justify-content-end w-100"
      } else {
        "d-flex w-100"
      },
      htmltools::div(
        class = "d-flex align-items-end",
        style = "max-width: 100%;",
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
            style = "overflow-x: auto;",
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
create_ide_matching_colors <- function(role = c("user", "assistant"),
                                       ide_colors = get_ide_theme_info()) {
  arg_match(role)

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

get_highlightjs_theme <- function() {
  if (.Platform$GUI == "RStudio") {
    rstudio_theme <- rstudioapi::getThemeInfo()$editor
    clean_theme_name <- tolower(gsub(" \\{rsthemes\\}$", "", rstudio_theme))

    theme_mapping <- list(
      # Original mappings
      "a11y-dark" = "a11y-dark",
      "a11y-light" = "a11y-light",
      "base16 3024" = "base16/3024",
      "base16 apathy" = "base16/apathy",
      "base16 ashes" = "base16/ashes",
      "base16 atelier cave light" = "base16/atelier-cave-light",
      "base16 atelier cave" = "base16/atelier-cave",
      "base16 atelier dune light" = "base16/atelier-dune-light",
      "base16 atelier dune" = "base16/atelier-dune",
      "base16 atelier estuary light" = "base16/atelier-estuary-light",
      "base16 atelier estuary" = "base16/atelier-estuary",
      "base16 atelier forest light" = "base16/atelier-forest-light",
      "base16 atelier forest" = "base16/atelier-forest",
      "base16 atelier heath light" = "base16/atelier-heath-light",
      "base16 atelier heath" = "base16/atelier-heath",
      "base16 atelier lakeside light" = "base16/atelier-lakeside-light",
      "base16 atelier lakeside" = "base16/atelier-lakeside",
      "base16 atelier plateau light" = "base16/atelier-plateau-light",
      "base16 atelier plateau" = "base16/atelier-plateau",
      "base16 atelier savanna light" = "base16/atelier-savanna-light",
      "base16 atelier savanna" = "base16/atelier-savanna",
      "base16 atelier seaside light" = "base16/atelier-seaside-light",
      "base16 atelier seaside" = "base16/atelier-seaside",
      "base16 atelier sulphurpool light" = "base16/atelier-sulphurpool-light",
      "base16 atelier sulphurpool" = "base16/atelier-sulphurpool",
      "base16 bespin" = "base16/bespin",
      "base16 brewer" = "base16/brewer",
      "base16 bright" = "base16/bright",
      "base16 chalk" = "base16/chalk",
      "base16 codeschool" = "base16/codeschool",
      "base16 cupcake" = "base16/cupcake",
      "base16 darktooth" = "base16/darktooth",
      "base16 default dark" = "base16/default-dark",
      "base16 default light" = "base16/default-light",
      "base16 dracula" = "dracula",
      "base16 eighties" = "base16/eighties",
      "base16 embers" = "base16/embers",
      "base16 flat" = "base16/flat",
      "base16 google dark" = "base16/google-dark",
      "base16 google light" = "base16/google-light",
      "base16 grayscale dark" = "base16/grayscale-dark",
      "base16 grayscale light" = "base16/grayscale-light",
      "base16 green screen" = "base16/greenscreen",
      "base16 gruvbox dark, hard" = "base16/gruvbox-dark-hard",
      "base16 gruvbox dark, medium" = "base16/gruvbox-dark-medium",
      "base16 gruvbox dark, pale" = "base16/gruvbox-dark-pale",
      "base16 gruvbox dark, soft" = "base16/gruvbox-dark-soft",
      "base16 gruvbox light, hard" = "base16/gruvbox-light-hard",
      "base16 gruvbox light, medium" = "base16/gruvbox-light-medium",
      "base16 gruvbox light, soft" = "base16/gruvbox-light-soft",
      "base16 harmonic16 dark" = "base16/harmonic16-dark",
      "base16 harmonic16 light" = "base16/harmonic16-light",
      "base16 hopscotch" = "base16/hopscotch",
      "base16 ir black" = "base16/ir-black",
      "base16 isotope" = "base16/isotope",
      "base16 london tube" = "base16/london-tube",
      "base16 macintosh" = "base16/macintosh",
      "base16 marrakesh" = "base16/marrakesh",
      "base16 materia" = "base16/materia",
      "base16 mexico light" = "base16/mexico-light",
      "base16 mocha" = "base16/mocha",
      "base16 monokai" = "monokai",
      "base16 nord" = "nord",
      "base16 ocean" = "base16/ocean",
      "base16 oceanicnext" = "base16/oceanicnext",
      "base16 onedark" = "base16/onedark",
      "base16 paraiso" = "base16/paraiso",
      "base16 phd" = "base16/phd",
      "base16 pico" = "base16/pico",
      "base16 pop" = "base16/pop",
      "base16 railscasts" = "base16/railscasts",
      "base16 rebecca" = "base16/rebecca",
      "base16 seti ui" = "base16/seti-ui",
      "base16 shapeshifter" = "base16/shapeshifter",
      "base16 solar flare" = "base16/solar-flare",
      "base16 solarized dark" = "solarized-dark",
      "base16 solarized light" = "solarized-light",
      "base16 spacemacs" = "base16/spacemacs",
      "base16 summerfruit dark" = "base16/summerfruit-dark",
      "base16 summerfruit light" = "base16/summerfruit-light",
      "base16 tomorrow night" = "tomorrow-night",
      "base16 tomorrow" = "tomorrow",
      "base16 twilight" = "twilight",
      "base16 unikitty dark" = "base16/unikitty-dark",
      "base16 unikitty light" = "base16/unikitty-light",
      "base16 woodland" = "base16/woodland",
      "elm dark" = "atom-one-dark",
      "elm light" = "atom-one-light",
      "embark" = "dracula",
      "fairyfloss" = "rainbow",
      "flat white" = "github",
      "github" = "github",
      "horizon dark" = "night-owl",
      "material darker" = "atom-one-dark",
      "material lighter" = "atom-one-light",
      "material ocean" = "ocean",
      "material palenight" = "atom-one-dark",
      "material" = "atom-one-dark",
      "night owl" = "night-owl",
      "nord polar night aurora" = "nord",
      "nord snow storm" = "nord",
      "oceanic plus" = "ocean",
      "one dark" = "atom-one-dark",
      "one light" = "atom-one-light",
      "serendipity dark" = "dracula",
      "serendipity light" = "github",
      "solarized dark" = "solarized-dark",
      "solarized light" = "solarized-light",
      "yule rstudio (reduced motion)" = "github",
      "yule rstudio" = "github",
      "textmate" = "github",
      "cobalt" = "cobalt",
      "eclipse" = "eclipse",
      "vibrant ink" = "vibrant-ink",
      "clouds" = "clouds",
      "clouds midnight" = "tomorrow-night-blue",
      "merbivore" = "merbivore",
      "ambiance" = "ambiance",
      "chaos" = "chaos",
      "tomorrow night blue" = "tomorrow-night-blue",
      "tomorrow night bright" = "tomorrow-night-bright",
      "tomorrow night eighties" = "tomorrow-night-eighties"
    )

    theme <- theme_mapping[[clean_theme_name]] %||% "github-dark"
  } else {
    cli::cli_inform("Failed to get RStudio theme. Using default 'github-dark' theme.")
    theme <- "github-dark"
  }
  base_url <-
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.10.0/build/styles/"
  glue::glue("{base_url}{theme}.min.css")
}
