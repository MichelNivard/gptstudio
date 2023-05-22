#' ChatGPT in Source
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and
#' grammar of selected text.
#'
#' @export
#'
#' @return This function has no return value.
#'
#' @examples
#' # Select some text in a source file
#' # Then call the function as an RStudio addin
#' \dontrun{
#' addin_chatgpt_in_source()
#' }
addin_chatgpt_in_source <- function() {
  gpt_chat_in_source(
    style = getOption("gptstudio.code_style"),
    skill = getOption("gptstudio.skill")
  )
}
