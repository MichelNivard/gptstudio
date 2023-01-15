chat_gpt_addin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  run_gpt_freeform()
}

run_chat_gpt <- function() {
  js <- '
$(document).keyup(function(event) {
  if ($("#chat_input").is(":focus") && (event.keyCode == 13)) {
      $("#chat").click();
  }
});
'

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      title = "🤖 Chat GPT from gptstudio 🤖",
      left  = miniUI::miniTitleBarButton("cancel", "Close", primary = FALSE),
      right = miniUI::miniTitleBarButton("chat", "Chat", primary = TRUE)
    ),
    shiny::tags$script(shiny::HTML(js)),
    miniUI::miniContentPanel(
      shiny::fillRow(
        flex = c(1, 1), height = "20%",
        shiny::selectInput("model", "OpenAI Model",
                           choices = c("text-davinci-003", "code-davinci-002"),
                           width = "90%"),
        shiny::sliderInput("temperature", "Temperature",
                           min = 0, max = 1, value = 0.5,
                           width = "90%"),
        # helpText("Higher temperature produce more creative resonses but may reduce accuracy.")
      ),
      shiny::hr(),
      shiny::verbatimTextOutput("all_chats_box"),
      shiny::br(),
      shiny::fillRow(
        flex = c(8, 2),
        height = "30%",
        shiny::textAreaInput(
          inputId = "chat_input",
          label = NULL,
          value = "",
          resize = "vertical",
          rows = 1,
          width = "100%"
        ),
        shiny::actionButton(inputId = "chat2",
                            label =  "Chat",
                            icon = shiny::icon("robot"),
                            width = "100%")
      ),
      shiny::hr(),
      shiny::downloadButton("download", label = "Download Chat")

    )
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues()
    r$all_chats <- ""
    shiny::observe({
      cli_inform(c("i" = "Querying OpenAI's API..."))
      prompt <- glue(r$all_chats, input$chat_input)
      cli_inform(prompt)

      # interim <- openai_create_completion(
      #   model = input$model,
      #   prompt = prompt,
      #   temperature = input$temperature
      # )

      interim <- list(choices = data.frame(edit = "Hello there."))

      cli_inform(c("i" = "Response received. Providing output text."))

      new_response <- interim$choices[1, 1]

      r$combined_chat <- paste(input$chat_input, new_response, sep = "\n")

      r$all_chats <- paste(r$all_chats, r$combined_chat, sep = "\n")
      print(r$all_chats)

      output$all_chats_box <-
        shiny::renderText({
          cli_inform("there")
          r$all_chats
        })
    }) %>%
      shiny::bindEvent(input$chat)

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)

}
