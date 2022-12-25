#' active voice Addin
#'
#' Call this function as a Rstudio addin to ask GPT to change selected text into the active voice
#'
#' @export
comAddin <- function() {
  selection <- selectionGet()

  edit <- create_edit(
    model = "code-davinci-edit-001",
    input = selection$value,
    instruction = "add commenta that explain what the code does",
    temperature = 0.1,
    top_p = 1,
    openai_api_key = Sys.getenv("OPENAI_API_KEY"),
    openai_organization = NULL
  )

  rstudioapi::insertText(edit$choices[1,1])


}
