#' Chat card
#'
#' @return A chat card
#' @export
#'
mod_prompt_ui <- function(id) {
  ns <- shiny::NS(id)

  htmltools::div(
    class = "d-flex p-3",
    div(
      class = "flex-grow-1 pe-3",
      textAreaInputWrapper(
        inputId = ns("chat_input"),
        label = NULL,
        width = "100%",
        placeholder = "Write your prompt here",
        value = "",
        resize = "vertical",
        rows = 3
      )
    ),
    div(
      style = htmltools::css(width = "50px"),
      shiny::actionButton(
        inputId = ns("chat"),
        label = fontawesome::fa("fas fa-paper-plane"),
        class = "w-100 btn-primary p-1"
      ),
      actionButton(
        inputId = ns("clear_history"),
        label = fontawesome::fa("eraser"),
        class = "w-100 btn-primary mt-2 p-1"
      ),
      bs_dropdown(
        label = fontawesome::fa("gear"),
        class = "w-100 btn-primary mt-2 p-1",
        shiny::selectInput(
          inputId = ns("style"),
          label = "Programming Style",
          choices = c("tidyverse", "base", "no preference"),
          width = "100%"
        ),
        shiny::selectInput(
          inputId = ns("skill"),
          label = "Programming Proficiency",
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "100%"
        )
      )
    )
  )
}

mod_prompt_server <- function(id) {
    moduleServer(id, function(input, output, session) {

    })
}

textAreaInputWrapper <-
  function(inputId,
           label,
           value = "",
           width = NULL,
           height = NULL,
           cols = NULL,
           rows = NULL,
           placeholder = NULL,
           resize = NULL) {

    tag <- shiny::textAreaInput(
      inputId = inputId,
      label = label,
      value = value,
      height = height,
      cols = cols,
      rows = rows,
      placeholder = placeholder,
      resize = resize
    )

    if(is.null(label)) {
      tag_query <- htmltools::tagQuery(tag)

      tag_query$children("label")$remove()$allTags()

    } else {
      tag
    }
  }
