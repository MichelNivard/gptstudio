#' Freeform GPT editor
#'
#' Call this function as a RStudio addin to open a GPT shiny app.
#'
#' @export
gpt_addin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  run_gpt_freeform()
}

#' Shiny app that supports GPT freeform addin
#'
#' @return Nothing is returned, a shiny app is run
#' @export
run_gpt_freeform <- function() {
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      title = "GPTstudio Freeform Editor",
      left  = miniUI::miniTitleBarButton("cancel", "Close", primary = FALSE),
      right = miniUI::miniTitleBarButton("button", "Run GPT", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(1, 1),
        shiny::fillRow(
          flex = c(1, 1, 3),
          shiny::radioButtons(
            inputId = "model",
            label = "What OpenAI model do you want to use to edit?",
            choices = list(
              "Use text model" = "text-davinci-edit-001",
              "Use code model (alpha)" = "code-davinci-edit-001"
            ),
            width = "90%"
          ),
          shiny::sliderInput(
            inputId = "temperature",
            label = "Model temperature, higher is more creative/random",
            min = 0,
            max = 1,
            value = .1,
            width = "90%"
          ),
          shiny::textAreaInput(
            inputId = "question",
            label = "Editing Instruction for GPT:",
            value = "",
            rows = 5,
            width = "90%"
          )
        ),
        shiny::verbatimTextOutput(
          outputId = "response",
          placeholder = TRUE
        )
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observe({
      selection <- rstudioapi::selectionGet()

      rlang::inform(c("i" = "Querying OpenAI's API..."))

      interim <- openai_create_edit(
        model = input$model,
        input = selection$value,
        instruction = input$question,
        temperature = input$temperature
      )

      rlang::inform(c("i" = "Response received. Providng output text."))

      output$response <- shiny::renderText(interim$choices[1, 1])
    }) %>%
      shiny::bindEvent(input$button)

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)
}
