#' active voice Addin
#'
#' Call this function as a Rstudio addin to ask GPT to change selected text into the active voice
#'
#' @export
avAddin <- function() {
  selection <- selectionGet()
  print(selection)

  edit <- create_edit(
    model = "text-davinci-edit-001",
    input = selection$value,
    instruction = "rewrite in the active voice",
    temperature = 1,
    top_p = 1,
    openai_api_key = Sys.getenv("OPENAI_API_KEY"),
    openai_organization = NULL
  )
  print(edit)
  rstudioapi::insertText(edit$choices[1,1])


}
