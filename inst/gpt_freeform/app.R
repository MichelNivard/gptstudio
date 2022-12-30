library(gptstudio)
ui <- miniUI::miniPage(

  miniUI::gadgetTitleBar("Specify a model with gptstudio"),
  miniUI::miniContentPanel(
    shiny::fillCol(
      flex = c(1,1),
      shiny::fillRow(
        flex = c(1,1),
        shiny::fillCol(flex = c(1,1,1,1,2,2,2),
                       shiny::fillRow(
                         shiny::selectInput(
                           inputId = "dataframes",
                           label   = "What data do you want to model?",
                           choices = NULL,
                           width   = "90%"),
                         shiny::selectInput(
                           inputId = "outcome",
                           label   = "What outcome do you want to model?",
                           choices = NULL,
                           width   = "90%")),
                       helpText("Only dataframes in the global environment are shown."),
                       shiny::selectInput(
                         inputId = "sum_method",
                         label = "What method should be used to summarize data?",
                         choices = c("skimr", "skimr_lite", "column_types", "summary"),
                         width = "90%"
                       ),
                       helpText("Different summary methods may produce different models."),
                       shiny::fillRow(
                         shiny::sliderInput(
                           inputId = "temperature",
                           label = "Model temperature",
                           min = 0,
                           max = 1,
                           value = .7,
                           width="90%"
                         ),
                         shiny::sliderInput(
                           inputId = "max_tokens",
                           label = "Maximum number of tokens to spend.",
                           min = 12,
                           max = 1000,
                           value = 100,
                           width="90%"
                         )),
                       helpText("Temperature is a parameter for controlling the randomness of the GPT model's output. Tokens refers to the cost of a model query. One token refers to about 4 letters. If your reponse is cutoff, you can increase the number of tokens (at increase cost!)."),
                       shiny::fillRow(
                         shiny::actionButton(inputId = "update_prompt",
                                             label = "Update Prompt",
                                             icon = icon("rotate-right"),
                                             width = "90%"),
                         shiny::actionButton(inputId = "query_gpt",
                                             label = "Document Data",
                                             icon = icon("wand-magic-sparkles"),
                                             width = "90%")
                       )
        ),
        column(width = 12,
          shiny::textAreaInput(inputId="prompt",
                               label="Prompt for the model to use to document your data",
                               value="",
                               rows = 5,
                               width="90%"),
          h2("Model Response"),
          shiny::verbatimTextOutput(outputId = "response",
                                    placeholder = T))
      )
    ),
  ))

server <- function(input, output, session) {
  dataframes <- reactive(collect_dataframes())
  current_dataframe <- reactive({
    req(stringr::str_length(input$dataframes) > 0)
    get(rlang::sym(input$dataframes))
  })
  prepped_prompt <- reactive({
    prep_data_prompt(
      current_dataframe(),
      method = input$sum_method,
      prompt = glue::glue("Model the outcome variable {input$outcome} using other variables in the {input$dataframes} data with R code. (Optionally include interaction terms or mixed effects):\n\n")
      )
  })
  observe({
    updateSelectInput(session = session,
                      inputId = "dataframes",
                      choices = dataframes())
    updateSelectInput(session = session,
                      inputId = "outcome",
                      choices = names(current_dataframe()))
  })
  shiny::observeEvent(input$update_prompt, {
    cli::cli_alert_info("Updating prompt")
    updateTextAreaInput(
      session = session,
      inputId = "prompt",
      value = prepped_prompt())
  })
  shiny::observeEvent(input$query_gpt,{
    cli::cli_alert_info("Querying GPT")
    interim <- gpttools:::openai_create_completion(
      model = "text-davinci-003",
      prompt = input$prompt,
      temperature = input$temperature,
      max_tokens = input$max_tokens,
      openai_api_key = Sys.getenv("OPENAI_API_KEY"),
      openai_organization = NULL
    )
    cli::cli_alert_info("Query complete. Providing output text.")

    interim$choices

    output$response <- shiny::renderText(interim$choices[1,1])

  })

  shiny::observeEvent(input$cancel, stopApp())
}

shiny::shinyApp(ui, server)
