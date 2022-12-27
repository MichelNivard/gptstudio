#' active voice Addin
#'
#' Call this function as a Rstudio addin to ask GPT to add comments to your code
#'
#' @export
comAddin <- function() {
  gpt_edit(
    model = "code-davinci-edit-001",
    instruction = "add comments to each line of code, explaining what the code does",
    temperature = 0.1,
    top_p = 1
  )
}
