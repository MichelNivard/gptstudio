#' Comment Code Addin
#'
#' Call this function as a Rstudio addin to ask GPT to add comments to your code
#'
#' @return This function has no return value.
#' @export
#'
#' @examples
#' # Open a R file in Rstudio
#' # Then call the function as an RStudio addin
#' \dontrun{addin_comment_code()}
addin_comment_code <- function() {
  gpt_edit(
    model = "code-davinci-edit-001",
    instruction = "add comments to each line of code to explain the code",
    temperature = 0.1
  )
}
