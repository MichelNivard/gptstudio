#' Freeform GPT editor
#'
#' Call this function as a Rstudio addin to open a GPT shiny app.
#'
#' @export
gptAddin <- function() {
  check_api_connection()
  # Our ui will be a simple gadget page
  ui <- miniUI::miniPage(

    miniUI::gadgetTitleBar(
      "GPTstudio Freeform Editor",
      left = miniUI::miniTitleBarButton("button", "Run GPT", primary = TRUE),
      right = miniUI::miniTitleBarCancelButton()),
    miniUI::miniContentPanel(
      shiny::textAreaInput(
        inputId="question",
        label="Editing Instruction for GPT:",
        value="",
        rows = 3,
        width = "100%"),
    ),
    miniUI::miniContentPanel(
      shiny::verbatimTextOutput(outputId = "response",placeholder = F)
    )

  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$button,{
    selection <- rstudioapi::selectionGet()

   interim <- openai::create_edit(
     model = "text-davinci-edit-001",
     input = selection$value,
     instruction = input$question,
     temperature = 0.05
   )

   output$response <- shiny::renderText(interim$choices[1,1])

   })
  }


  # We'll use a pane viewer
  viewer <- shiny::paneViewer(100)
  shiny::runGadget(ui, server, viewer = viewer)

}



