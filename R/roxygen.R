#' Add Roxygen documentation to a function
#'
#' This function uses the OpenAI API to generate a roxygen skeleton for the
#' current selection in RStudio. The roxygen skeleton is then inserted into the
#'  document.
#'
#' @return NULL (nothing is returned; the generated roxygen skeleton is inserted into the document).
#' @export
#'
roxygenAddin <- function() {
  gpt_edit(
    model = "code-davinci-edit-001",
    instruction = "insert roxygen to document this function",
    temperature = 0.1,
    top_p = 1
  )
}
