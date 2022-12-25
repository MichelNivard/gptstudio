#' Freeform GPT editor
#'
#' Call this function as a Rstudio addin to open a GPT shiny app.
#'
#' @export
gptAddin <- function() {

  # Our ui will be a simple gadget page
  ui <- miniPage(

    gadgetTitleBar("GPTstudio Freeform Editor",left = miniTitleBarButton("buttom", "Run GPT", primary = TRUE), right = miniTitleBarCancelButton()),
    miniContentPanel(
      textAreaInput(inputId="question", label="Editing Instruction for GPT:", value="",rows = 3,width = "100%"),
    ),
    miniContentPanel(
      verbatimTextOutput(outputId = "response",placeholder = F)
    )

  )

  server <- function(input, output, session) {
    observeEvent(input$button,{
    selection <- selectionGet()

   interim <- create_edit(
     model = "text-davinci-edit-001",
     input = selection$value,
     instruction = input$question,
     temperature = 0.05
   )

   output$response <- renderText(interim$choices[1,1])

   })
  }


  # We'll use a pane viewer
  viewer <- paneViewer(100)
  runGadget(ui, server, viewer = viewer)

}



