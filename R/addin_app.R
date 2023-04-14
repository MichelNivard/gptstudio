#' Chat card
#'
#' @return A chat card
#' @export
#'
chat_card <- function() {
  bslib::card(
    height = "100%",
    bslib::card_header(
      "Chat",
      class = "bg-primary",

      bs_dropdown(
        label = fontawesome::fa("gear"),
        shiny::selectInput(
          "style", "Programming Style",
          choices = c("tidyverse", "base", "no preference"),
          width = "100%"
        ),
        shiny::selectInput(
          "skill", "Programming Proficiency",
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "100%"
        )
      ),

      actionButton("clear_history", fontawesome::fa("eraser")) |> tagAppendAttributes(class = "float-end btn-sm")
    ),
    bslib::card_body(
      fill = TRUE,

      shiny::uiOutput("all_chats_box")
    ),
    bslib::card_footer(
      shiny::textAreaInput(
        inputId = "chat_input",
        label = NULL,
        placeholder = "Write your prompt here",
        value = "",
        resize = "vertical",
        rows = 3,
        width = "100%"
      ),
      shiny::actionButton(
        width = "100%",
        inputId = "chat", label = "Chat",
        icon = shiny::icon("robot"), class = "btn-primary"
      )
    )
  )
}
