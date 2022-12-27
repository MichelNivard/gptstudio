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
  # Check that the API connection is working
  check_api_connection()

  # Get the current selection
  selection <- rstudioapi::selectionGet()

  # Use the OpenAI API to generate the roxygen skeleton
  edit <- openai::create_edit(
    model = "code-davinci-edit-001",
    input = selection$value,
    instruction = "insert roxygen to document this function",
    temperature = 0.1,
    top_p = 1,
    openai_api_key = Sys.getenv("OPENAI_API_KEY"),
    openai_organization = NULL
  )

  # Insert the generated roxygen skeleton into the document
  rstudioapi::insertText(edit$choices[1,1])
}
