#' simplify Addin
#'
#' Call this function as a Rstudio addin to ask GPT to simplify complex language
#'
#' @export
simpAddin <- function() {
  selection <- selectionGet()

  edit <- create_edit(
    model = "text-davinci-edit-001",
    input = selection$value,
    instruction = "simplify text so anyone can understand it",
    temperature = 0.1,
    top_p = 1,
    openai_api_key = Sys.getenv("OPENAI_API_KEY"),
    openai_organization = NULL
  )
  print(edit)
  rstudioapi::insertText(edit$choices[1,1])


}
