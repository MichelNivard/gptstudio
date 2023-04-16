#' Chat UI
#'
#' @param id id of the module
#'
#' @export
#'
mod_chat_ui <- function(id) {
    ns <- NS(id)

    bslib::card(
      height = "100%",
      bslib::card_body(
        class = "py-2 h-100",

        div(
          class = "d-flex flex-column h-100",

          div(
            class = "p-2 mh-100 overflow-auto",
            shiny::uiOutput(ns("all_chats_box")),
          ),
          div(
            class = "mt-auto",
            mod_prompt_ui(ns("prompt"))
          )
        )
      )
    )
}

#' Chat server
#'
#' @param id id of the module
#'
#' @export
#'
mod_chat_server <- function(id) {
    moduleServer(id, function(input, output, session) {
      prompt <- mod_prompt_server("prompt")

      output$all_chats_box <- shiny::renderUI({
        prompt$all_chats_formatted
      })

    })
}

