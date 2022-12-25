#' write/code from prompt Addin
#'
#' Call this function as a Rstudio addin to ask GPT to write text or code from a descriptive prompt
#'
#' @export
wpAddin <- function() {
  selection <- selectionGet()

  product <- create_completion(
    model = "text-davinci-003",
    prompt = selection$value,
    temperature = 0.1,
    top_p = 1,
  )

  rstudioapi::insertText(product$choices[1,1])


}
