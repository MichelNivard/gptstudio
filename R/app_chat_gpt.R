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
      $("#chat_input").val("");
  }
});
'

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      title = "🤖 Chat GPT from gptstudio 🤖",
      left  = miniUI::miniTitleBarButton("cancel", "Close", primary = FALSE),
      right = NULL
    ),
    shiny::tags$script(shiny::HTML(js)),
    shiny::tags$head(
      shiny::tags$style("#all_chats_box{overflow-y: scroll; max-height: 100px;}")
    ),
    miniUI::miniContentPanel(
      shiny::uiOutput("current_prompt"),
      shiny::uiOutput("current_response"),
      shiny::br(),
      shiny::br(),
      shiny::fillRow(
        flex = c(1, 7, 2),
        height = "20%",
        shinyWidgets::dropdownButton(
          shiny::h4("Model Input Settings"),
          shiny::selectInput("model", "OpenAI Model",
                             choices = c("text-davinci-003", "code-davinci-002"),
                             width = "90%"),
          shiny::sliderInput("temperature", "Temperature",
                             min = 0, max = 1, value = 0.5,
                             width = "90%"),
          shiny::sliderInput("max_tokens", "Max Tokens",
                             min = 16, max = 1000, value = 200,
                             width = "90%"),

          circle = TRUE,
          size = "sm",
          status = "primary",
          icon = shiny::icon("gear"), width = "300px",
          tooltip = shinyWidgets::tooltipOptions(title = "Model Input Settings")
        ),
        shiny::textAreaInput(
          inputId = "chat_input",
          label = NULL,
          value = "",
          resize = "vertical",
          rows = 1,
          width = "100%"
        ),
        shiny::column(12,
                      shiny::actionButton(
                        inputId = "chat",
                        label =  "Chat",
                        style = "color: #fff;
                                 background-color: #337ab7;
                                 border-color: #2e6da4",
                        icon = shiny::icon("robot"),
                        width = "100%"), align = "right")
      ),
      shiny::hr(),
      shiny::h3("Chat History"),
      shiny::verbatimTextOutput("all_chats_box"),
      shiny::downloadButton("download", label = "Download Chat")

    )
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues()
    r$all_chats <- ""
    shiny::observe({
      cli_inform(c("i" = "Querying OpenAI's API..."))
      prompt <- glue(r$all_chats, input$chat_input)
      cli_rule("Prompt")
      cat_print(prompt)

      interim <- openai_create_completion(
        model = input$model,
        prompt = prompt,
        temperature = input$temperature,
        max_tokens = input$max_tokens
      )

      cli_inform(c("i" = "Response received. Providing output text."))

      new_response <- interim$choices[1, 1]

      r$combined_chat <- paste(input$chat_input, new_response)

      r$all_chats <- paste(r$all_chats, r$combined_chat)
      print(r$all_chats)

      output$all_chats_box    <- shiny::renderText(r$all_chats)
      output$current_prompt   <- shiny::renderUI(
        list(
          shiny::h4("Prompt"),
          shiny::renderText(input$chat_input)
        )
      )
      output$current_response <- shiny::renderUI(
        list(
          shiny::h4("Response"),
          shiny::renderText(new_response)
        )
      )
    }) %>%
      shiny::bindEvent(input$chat)

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)

}
