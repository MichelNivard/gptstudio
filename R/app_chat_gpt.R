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
  # $("#chat_input").val("");

  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(version = 5),
    title = "Chat GPT from gptstudio",
    shiny::tags$script(shiny::HTML(js)),
    shiny::tags$head(
      shiny::tags$style("#all_chats_box{overflow-y: scroll;
                                        max-height: 200px;}")
    ),
    shiny::uiOutput("all_chats_box"),
    bslib::card(
      height = 175,
      bslib::card_header("Write Prompt"),
      bslib::card_body_fill(
        shiny::textAreaInput(
          inputId = "chat_input", label = NULL, value = "", resize = "vertical",
          rows = 1, width = "100%"
        ),
        shiny::column(
          width = 12, align = "right",
          shiny::actionButton(
            inputId = "chat", label =  "Chat",
            icon = shiny::icon("robot"), class = "btn-primary")
        )
      )
    ),
    shiny::column(
      width = 12, align = "right",
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
        circle = FALSE,
        status = "info",
        icon = shiny::icon("gear"), width = "400px",
        tooltip = shinyWidgets::tooltipOptions(title = "Model Input Settings")
      )
    )
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues()
    r$all_chats <- ""
    r$all_chats_formatted <- NULL
    shiny::observe({
      cli_inform(c("i" = "Querying OpenAI's API..."))
      new_prompt <- input$chat_input
      prompt <- glue(r$all_chats, new_prompt)
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
          height = 400,
          bslib::card_header(
            "Chat History"
          ),
          bslib::card_body(
            fill = TRUE,
            r$all_chats_formatted
          )
        )
      )
      updateTextAreaInput(session, "chat_input", value = "")
    }) %>%
      shiny::bindEvent(input$chat)

    # output$all_chats_box    <-
    #   shiny::renderUI(
    #     list(
    #       make_chat_history(NULL, "asdfasdfa", "asdfasdfasdghawro"),
    #       make_chat_history(NULL, "dgfeaghwagoadfj", "hgtefwaoighaohdg")
    #     )
    #   )

    shiny::observeEvent(input$cancel, shiny::stopApp())
  }

  shiny::shinyApp(ui, server)

}


make_chat_history <- function(history, new_prompt, new_response) {
  new_response <-
    list(shiny::strong("Question"),
         shiny::p(new_prompt),
         shiny::strong("Response"),
         shiny::p(new_response))
  if (is_null(history)) {
    new_response
  } else {
    c(history, new_response)
  }
}
