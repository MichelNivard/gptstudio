#' Insert \%in\%.
#'
#' Call this function as an addin to ask GPT tp improve spelling and grammar of selected text
#'
#' @export
sandgAddin <- function() {
   selection <- selectionGet()


   edit <- create_edit(
     model = "text-davinci-edit-001",
     input = selection$selection,
     instruction = "Improve spellign and grammar",
     temperature = 1,
     top_p = 1,
     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
     openai_organization = NULL
   )

   rstudioapi::insertText("edit")


}
