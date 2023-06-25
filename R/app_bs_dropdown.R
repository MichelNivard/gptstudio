#' Boostrap 5 dropdown
#'
#' @param label The label
#' @param id ID of the dropdown element
#' @param ... additional arguments passed to card_body()
#' @param class Additional classes
#'
#' @return A Bootstrap 5 dropdown
#'
bs_dropdown <- function(label, id, ..., class = NULL) {
  div(
    class = "dropdown",
    htmltools::tags$button(
      class = "btn dropdown-toggle",
      class = class,
      type = "button",
      `data-bs-toggle` = "dropdown",
      `data-bs-auto-close` = "outside",
      `aria-expanded` = "false",
      id = id,
      label
    ),
    div(
      class = "dropdown-menu p-3",
      style = htmltools::css(width = "250px"),
      `aria-labelledby` = id,
      ...
    )
  )
}
