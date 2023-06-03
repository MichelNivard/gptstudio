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
#' \dontrun{
#' addin_spelling_grammar()
#' }
addin_spelling_grammar <- function() {
  cli_process_start("Sending query to ChatGPT")
  gpt_chat_in_source(
    task = "Improve spelling and grammar of the text",
    style = getOption("gptstudio.code_style"),
    skill = getOption("gptstudio.skill")
  )
  cli_process_done()
}
