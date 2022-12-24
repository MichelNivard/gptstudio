#' Insert \%in\%.
#'
#' Call this function as an addin to ask GPT to improve spelling and grammar of selected text
#'
#' @export
sandgAddin <- function() {
   selection <- selectionGet()
   print(selection)

   edit <- create_edit(
     model = "text-davinci-edit-001",
     input = selection$value,
     instruction = "Improve spelling and grammar",
     temperature = 1,
     top_p = 1,
     openai_api_key = Sys.getenv("OPENAI_API_KEY"),
     openai_organization = NULL
   )
    print(edit)
   rstudioapi::insertText(edit$choices[1,1])


}
