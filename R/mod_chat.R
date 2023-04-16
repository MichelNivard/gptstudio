#' Chat
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
        # fill = TRUE,
        class = "py-2 h-100",

        div(
          class = "d-flex flex-column h-100",

          div(
            class = "p-2 bg-warning",
            style = htmltools::css(
              `max-height` = "100%",
              overflow = "auto"
            ),
            lapply(1:10, \(x) {
              tagList(
                htmltools::div(
                  class = "bg-info mb-2",
                  style = htmltools::css(height = "100px")
                ),
                htmltools::div(
                  class = "bg-danger mb-2",
                  style = htmltools::css(height = "100px")
                )
              )
            }),
            shiny::uiOutput("all_chats_box"),
          ),
          div(
            class = "mt-auto",
            mod_prompt_ui(ns("prompt"))
          )
        )
      )
    )
}

mod_chat_server <- function(id) {
    moduleServer(id, function(input, output, session) {
      rv <- reactiveValues()

      prompt <- mod_prompt_server("prompt", rv)

    })
}

