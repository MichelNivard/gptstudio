ui <- miniUI::miniPage(

  miniUI::gadgetTitleBar(
    "GPTstudio Freeform Editor",
    left = miniUI::miniTitleBarButton("button", "Run GPT", primary = TRUE),
    right = miniUI::miniTitleBarCancelButton(inputId = "cancel", label = "Close",primary = FALSE)),
  miniUI::miniContentPanel(
    shiny::fillCol(
      flex = c(1,1),
      shiny::fillRow(
        flex = c(1,1,3),
        shiny::radioButtons(
          inputId = "model",
          label = "What OpenAI model do you want to use to edit?",
          choices=list("Use text model" = "text-davinci-edit-001",
                       "Use code model (alpha)" = "code-davinci-edit-001"),
          width="90%"),
        shiny::sliderInput(
          inputId = "temperature",
          label = "Model temperature, higher is more creative/random",
          min = 0,
          max = 1,
          value = .1,
          width="90%"),
        shiny::textAreaInput(inputId="question",
                             label="Editing Instruction for GPT:",
                             value="",
                             rows = 5,
                             width="90%")
      ),
      shiny::verbatimTextOutput(outputId = "response",
                                placeholder = T)
    )

  ))

server <- function(input, output, session) {
  shiny::observeEvent(input$button,{
    selection <- rstudioapi::selectionGet()

    interim <- openai::create_edit(
      model = input$model,
      input = selection$value,
      instruction = input$question,
      temperature = input$temperature
    )

    output$response <- shiny::renderText(interim$choices[1,1])

  })

  shiny::observeEvent(input$cancel, stopApp())
}

shiny::shinyApp(ui, server)
