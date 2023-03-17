#' Spelling and Grammar Addin
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and
#' grammar of selected text.
#'
#' @return This function has no return value.
#'
#' @export
#'
#' @examples
#' # Select some text in Rstudio
#' # Then call the function as an RStudio addin
#' \dontrun{addin_spelling_grammar()}
addin_spelling_grammar <- function() {
  gpt_edit(
    model = "text-davinci-edit-001",
    instruction = "Improve spelling and grammar of this text",
    temperature = 0.1
  )
}
