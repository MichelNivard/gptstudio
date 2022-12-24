#' write from prompt Addin
#'
#' Call this function as a Rstudio addin to ask GPT to write text from a descriptive prompt
#'
#' @export
wpAddin <- function() {
  selection <- selectionGet()

  create_completion(
    model = "text-davinci-003",
    prompt = selection$value,
    max_tokens = 200,
    temperature = 0.1,
    top_p = 1,
  )

  rstudioapi::insertText(edit$choices[1,1])


}
