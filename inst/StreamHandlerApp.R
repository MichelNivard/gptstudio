library(shiny)
library(gptstudio)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      textAreaInput(
        inputId = "text",
        label = "Input",
        value = "Give me two examples of ggplot2 code",
        height = "800px"
      ),
      actionButton("go", "Render"),
      tags$script(
        "Shiny.addCustomMessageHandler(
          type = 'render-stream', function(message) {
            $('#render-here').html($.parseHTML(message))

            console.log(message)
        });"
      )
    ),
    mainPanel(
      uiOutput("my_ui"),
      div(id = "render-here")
    )
  )
)

server <- function(input, output, session) {

  output$my_ui <- renderUI({

  }) %>%
    bindEvent(input$go)

  observe({
    stream_handler <- StreamHandler$new(session = session)
    stream_chat_completion(input$text, element_callback = stream_handler$handle_streamed_element)
  }) %>%
    bindEvent(input$go)
}

shinyApp(ui, server)
