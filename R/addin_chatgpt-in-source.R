#' ChatGPT in Source
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and
#' grammar of selected text.
#'
#' @export
addin_chatgpt_in_source <- function() {
  cli_inform(c("i" = "Sending query to ChatGPT..."))
  gpt_chat_in_source(
    style = getOption("gptstudio.code_style"),
    skill = getOption("gptstudio.skill")
  )
}
