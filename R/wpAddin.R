#' write/code from prompt Addin
#'
#' Call this function as a Rstudio addin to ask GPT to write text or code from
#' a descriptive prompt
#'
#' @export
wpAddin <- function() {
  gpt_create(
    model = "text-davinci-003",
    max_tokens = 500,
    temperature = 0.1
  )
}
