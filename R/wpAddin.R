#' write/code from prompt Addin
#'
#' Call this function as a Rstudio addin to ask GPT to write text or code from a descriptive prompt
#'
#' @export
wpAddin <- function() {
  selection <- rstudioapi::selectionGet()

  product <- openai::create_completion(
    model = "text-davinci-003",
    prompt = selection$value,
    max_tokens = 500,
    temperature = 0.1,
    top_p = 1,
  )

  rstudioapi::insertText(product$choices[1,1])

}
