add_copy_btns_to_pre <- function(tag_list) {
  tq <- htmltools::tagQuery(tag_list)
  tq$
    siblings("pre")$
    each(add_copy_btn_before_tag)$
    allTags()
}

add_copy_btn_before_tag <- function(tag, i) {
  tq <- tagQuery(tag)

  language <- get_code_language(tq)
  copy_btn_div <- create_copy_btn_div(language)

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

create_copy_btn_div <- function(language) {
  tags$div(
    class = "d-flex justify-content-between bg-dark",
    style = htmltools::css(`border-radius` = "5px 5px 0 0"),
    tags$p(
      class = "px-2 py-1 m-0 text-muted small",
      language
    ),
    tags$button(
      class = "btn btn-secondary btn-sm btn-clipboard",
      style = htmltools::css(`border-radius` = "0 5px 0 0"),
      "Copy"
    )
  )
}
