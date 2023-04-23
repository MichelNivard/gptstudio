add_copy_btns_to_pre <- function(tag_list, copy_btn_id = "codeCopied") {
  tq <- htmltools::tagQuery(tag_list)
  tq$
    siblings("pre")$
    each(add_copy_btn_before_tag)$
    allTags()
}

add_copy_btn_before_tag <- function(tag, i) {
  tq <- tagQuery(tag)

  language <- get_code_language(tq)
  code_text <- get_pre_text(tag)
  copy_btn_div <- create_copy_btn_div(language, code_text, copy_btn_id = paste0("copy_", i))

  tq$
    addAttrs(
      style = htmltools::css(`border-radius` = "0 0 5px 5px")
    )$
    before(copy_btn_div)

  tq$allTags()
}

get_code_language <- function(tq) {
  code_element <- tq$children("code")$selectedTags()[[1]]
  tagGetAttribute(code_element, "class") %||% "output"
}

create_copy_btn_div <- function(language, text_to_copy, copy_btn_id = "codeCopied") {
  tags$div(
    class = "d-flex justify-content-between bg-dark",
    style = htmltools::css(`border-radius` = "5px 5px 0 0"),
    tags$p(
      class = "px-2 py-1 m-0 text-muted small",
      language
    ),
    create_copy_btn(
      class = "btn-secondary btn-sm btn-clipboard",
      style = htmltools::css(`border-radius` = "0 5px 0 0"),
      inputId = copy_btn_id,
      label = "Copy",
      text_to_copy = text_to_copy
    )
  )
}

create_copy_btn <- function(inputId, label, text_to_copy, ...) {
  tag <- rclipboard::rclipButton(
    inputId = inputId,
    label = label,
    clipText = text_to_copy,
    ...
  )

  tq <- htmltools::tagQuery(tag)

  tq$siblings("button")$removeClass("btn-default")$allTags()
}

get_pre_text <- function(pre_tag) {
  pre_tag |>
    as.character() |>
    xml2::read_html() |>
    xml2::xml_find_first("./body/*") |>
    xml2::xml_text(trim = TRUE)
}
