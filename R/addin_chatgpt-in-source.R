#' ChatGPT in Source
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and
#' grammar of selected text.
#'
#' @export
addin_chatgpt_in_source <- function() {
  cli_inform(c("i" = "Sending query to ChatGPT..."))
  query <- get_selection()
  response <-
    gpt_chat_in_source(
      query = query,
      history = NULL,
      style   = getOption("gptstudio.code_style"),
      skill   = getOption("gptstudio.skill")
    )
  response <- response[[2]]$choices$message.content
  text_to_insert <- c(as.character(query), response)
  cli_inform(c("i" = "Inserting response from ChatGPT..."))
  insert_text(text_to_insert)
}
