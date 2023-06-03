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
#' \dontrun{
#' addin_comment_code()
#' }
addin_comment_code <- function() {
  cli_process_start("Sending query to ChatGPT")
  gpt_chat_in_source(
    task = "Add comments to explain this code. Your output will go directly into
    a source (.R) file. Comment the code line by line",
    style = getOption("gptstudio.code_style"),
    skill = getOption("gptstudio.skill")
  )
  cli_process_done()
}
