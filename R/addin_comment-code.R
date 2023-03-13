#' active voice Addin
#'
#' Call this function as a Rstudio addin to ask GPT to add comments to your code
#'
#' @export
addin_comment_code <- function() {
  gpt_edit(
    model = "code-davinci-edit-001",
    instruction = "add comments to each line of code to explain the code",
    temperature = 0.1
  )
}
