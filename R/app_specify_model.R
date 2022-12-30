#' Specify Model Addin
#'
#' This function launches the GPT Specify Model Addin.
#'
#' @export
specify_model_addin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  run_specify_model()
}

#' Run a Shiny App to Specify a Model with GPT
#'
#' @export
run_specify_model <- function() {
  available_data <- collect_dataframes()

  ui <- miniUI::miniPage(

    miniUI::gadgetTitleBar("Specify a model with gptstudio"),
    miniUI::miniContentPanel(
      shiny::fillCol(
        flex = c(1,1),
        shiny::fillRow(
          flex = c(1,1),
          shiny::fillCol(
            flex = c(1,1,1,1,2,2,2,1),
            shiny::fillRow(
              shiny::selectInput(
                inputId = "dataframes",
                label   = "What data do you want to model?",
                choices = available_data,
                width   = "90%"),
              shiny::selectInput(
                inputId = "outcome",
                label   = "What outcome do you want to model?",
                choices = NULL,
                width   = "90%")),
            shiny::helpText("Only dataframes in the global environment are shown."),
            shiny::selectInput(
              inputId = "sum_method",
              label = "What method should be used to summarize data?",
              choices = c("skimr", "skimr_lite", "column_types", "summary"),
              width = "90%"
            ),
            shiny::helpText("Different summary methods may produce different models."),
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
                label = "Maximum tokens to spend.",
                min = 12,
                max = 1000,
                value = 100,
                width="90%"
              )),
            shiny::helpText("Temperature is a parameter for controlling the randomness of the GPT model's output. Tokens refers to the cost of a model query. One token refers to about 4 letters. If your reponse is cutoff, you can increase the number of tokens (at increase cost!)."),
            shiny::textAreaInput(inputId = "instructions",
                                 label = "Model Instructions",
                                 width = "90%"),
            shiny::fillRow(
              shiny::actionButton(inputId = "update_prompt",
                                  label = "Update Prompt",
                                  icon = shiny::icon("rotate-right"),
                                  width = "90%"),
              shiny::actionButton(inputId = "query_gpt",
                                  label = "Specify Model",
                                  icon = shiny::icon("wand-magic-sparkles"),
                                  width = "90%")
            )
          ),
          shiny::column(
            width = 12,
            shiny::h3("Model Response"),
            shiny::verbatimTextOutput(outputId = "response",
                                      placeholder = TRUE),
            shiny::h3("Full Prompt"),
            shiny::verbatimTextOutput(outputId    = "prompt",
                                      placeholder = TRUE)
          )
        )
      )
    )
  )

  server <- function(input, output, session) {
    current_dataframe <- shiny::reactive({
      shiny::req(nchar(input$dataframes) > 0)
      get(rlang::sym(input$dataframes))
    })

    shiny::observe(
      shiny::updateSelectInput(session = session,
                               inputId = "outcome",
                               choices = names(current_dataframe()))
    )

    prepped_prompt <- shiny::reactive(
      prep_data_prompt(
        current_dataframe(),
        method = input$sum_method,
        prompt = input$instructions
      )) |>
      shiny::bindEvent(input$update_prompt)

    shiny::observe({
      cli::cli_alert_info("Updating prompt")
      output$prompt <- shiny::renderText(prepped_prompt())
    }) |>
      shiny::bindEvent(input$update_prompt)

    shiny::observe({
      cli::cli_alert_info("Querying GPT")
      interim <- openai_create_completion(
        model = "text-davinci-003",
        prompt = input$prompt,
        temperature = input$temperature,
        max_tokens = input$max_tokens,
        openai_api_key = Sys.getenv("OPENAI_API_KEY"),
        openai_organization = NULL
      )
      cli::cli_alert_info("Query complete. Providing output text.")

      output$response <- shiny::renderText(interim$choices[1,1])
    }) |>
      shiny::bindEvent(input$query_gpt)

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)
}
