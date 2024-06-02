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
#' gptstudio_comment_code()
#' }
gptstudio_comment_code <- function() {
  gptstudio_chat_in_source(
    task = "Add comments to explain this code. Comment the code line by line",
    keep_selection = FALSE
  )
}
