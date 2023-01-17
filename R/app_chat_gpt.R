#' Run Chat GPT
#' Run the Chat GPT Shiny App
#' @param None
#' @export
#'
chat_gpt_addin <- function() {
  check_api()
  withr::local_options(shiny.launch.browser = .rs.invokeShinyPaneViewer)
  run_chat_gpt()
}


run_chat_gpt <- function() {
  js <- '
        $(document).keyup(function(event) {
  if ($("#chat_input").is(":focus") && (event.keyCode == 13)) {
      $("#chat").click();
  }
});
'
  chat_card <- bslib::card(
    height = "225px",
    bslib::card_header("Write Prompt", class = "bg-primary"),
    bslib::card_body(
      shiny::textAreaInput(
        inputId = "chat_input", label = NULL,
        value = "", resize = "vertical",
        rows = 3, width = "100%"
      ),
      shiny::actionButton(width = "100%",
        inputId = "chat", label =  "Chat",
        icon = shiny::icon("robot"), class = "btn-primary")
    )
  )

  model_settings_card <- bslib::card(
    bslib::card_header("Model Input Settings", class = "bg-secondary"),
    bslib::card_body(
      shiny::selectInput(
        "model", "OpenAI Model",
        choices = c("text-davinci-003", "code-davinci-002"),
        width = "90%"),
      fluidRow(
      shiny::numericInput("temperature", "Temperature",
                         min = 0, max = 1, value = 0.5, step = 0.1,
                         width = "50%"),
      shiny::numericInput("max_tokens", "Max Tokens",
                         min = 16, max = 10000, value = 200, step = 1,
                         width = "50%")
      ),
      class = "bg-light",
    )
  )

  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(version = 5),
    title = "Chat GPT from gptstudio",
    shiny::tags$script(shiny::HTML(js)),
    bslib::layout_column_wrap(
      width = 1/2,
      height = 600,
      bslib::layout_column_wrap(
        width = 1,
        heights_equal = "row",
        chat_card, model_settings_card),
      shiny::uiOutput("all_chats_box")
    )
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues()
    r$all_chats <- ""
    r$all_chats_formatted <- NULL
    shiny::observe({
      cli_inform(c("i" = "Querying OpenAI's API..."))
      new_prompt <- input$chat_input
      prompt <- glue(r$all_chats, new_prompt, .sep = " ")
      cli_rule("Prompt")
      cat_print(prompt)
      interim <- openai_create_completion(
        model = input$model,
        prompt = prompt,
        temperature = input$temperature,
        max_tokens = input$max_tokens
      )
      cli_inform(c("i" = "Response received."))

      new_response <- interim$choices[1, 1]
      cli_rule("Response")
      cat_print(new_response)
      r$all_chats <- glue(r$all_chats, new_prompt, new_response)
      cat_print(r$all_chats)
      r$all_chats_formatted <-
        make_chat_history(r$all_chats_formatted, input$chat_input, new_response)
      output$all_chats_box  <- shiny::renderUI(
        bslib::card(
          bslib::card_header("Chat History", class = "bg-"),
          bslib::card_body(
            fill = TRUE,
            r$all_chats_formatted
          )
        )
      )
      shiny::updateTextAreaInput(session, "chat_input", value = "")
    }) %>%
      shiny::bindEvent(input$chat)

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)

}


make_chat_history <- function(history, new_prompt, new_response) {
  new_response <-
    list(shiny::strong("Question"),
         shiny::markdown(new_prompt),
         shiny::strong("Response"),
         shiny::markdown(new_response))
  if (is_null(history)) {
    new_response
  } else {
    c(history, new_response)
  }
}
