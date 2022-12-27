#' spelling and grammar Addin
#'
#' Call this function as a Rstudio addin to ask GPT to improve spelling and grammar of selected text
#'
#' @export
sandgAddin <- function() {
   check_api_connection()
   selection <- rstudioapi::selectionGet()

   edit <- openai::create_edit(
     model = "text-davinci-edit-001",
     input = selection$value,
     instruction = "Improve spelling and grammar of this text",
     temperature = .05,
     top_p = 1,
     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
     openai_organization = NULL
   )

   rstudioapi::insertText(edit$choices[1,1])


}
