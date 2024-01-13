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
#' gptstudio_spelling_grammar()
#' }
gptstudio_spelling_grammar <- function() {
  cli_process_start("Sending query to ChatGPT")
  gptstudio_chat_in_source(
    task = "Improve spelling and grammar of the text"
  )
  cli_process_done()
}
