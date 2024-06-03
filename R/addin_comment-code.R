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

  file_ext <- get_file_extension()

  task <- glue::glue(
    "Add comments to explain this code.",
    "Your response will go directly into an open .{file_ext} file in an IDE",
    "without any post processing.",
    "Output only plain text. Do not output markdown.",
    .sep = " "
  )

  gptstudio_chat_in_source(
    task = task,
    keep_selection = FALSE
  )
}
