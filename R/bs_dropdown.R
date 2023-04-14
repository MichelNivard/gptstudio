#' Boostrap 5 dropdown
#'
#' @param label The label
#' @param ... additional arguments passed to card_body()
#' @param class Additional classes
#'
#' @return A Bootstrap 5 dropdown
#' @export
#'
bs_dropdown <- function(label, ..., class = NULL) {
  id <- ids::random_id()
  div(
    class = "dropdown float-right",
    class = class,
    htmltools::tags$button(
      class="btn btn-secondary dropdown-toggle btn-sm",
      type="button",
      `data-bs-toggle`="dropdown",
      `data-bs-auto-close`="outside",
      `aria-expanded`="false",
      id=id,
      label
    ),
    div(
      class = "dropdown-menu p-3",
      style = htmltools::css(width = "250px"),
      `aria-labelledby`= id,
      ...
    )
  )
}
