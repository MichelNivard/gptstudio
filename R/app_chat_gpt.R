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
    height = "550px",
    bslib::card_header("Write Prompt", class = "bg-primary"),
    bslib::card_body(
      fill = TRUE,
      shiny::textAreaInput(
        inputId = "chat_input", label = NULL,
        value = "", resize = "vertical",
        rows = 3, width = "100%"
      ),
      shiny::actionButton(width = "100%",
                          inputId = "chat", label =  "Chat",
                          icon = shiny::icon("robot"), class = "btn-primary"),
      shiny::br(), shiny::br(),
      shiny::fluidRow(
        shiny::selectInput(
          "style", "Programming Style",
          choices = c("tidyverse", "base", "no preference"),
          width = "50%"),
        shiny::selectInput(
          "skill", "Programming Proficiency",
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "50%")
      )
    )
  )

  ui <- shiny::fluidPage(
    theme = bslib::bs_theme(bootswatch = "morph", version = 5),
    title = "ChatGPT from gptstudio",
    shiny::tags$script(shiny::HTML(js)),
    shiny::br(),
    bslib::layout_column_wrap(
      width = 1/2,
      fill = FALSE,
      chat_card, shiny::uiOutput("all_chats_box")
    )
  )

  server <- function(input, output, session) {
    r <- shiny::reactiveValues()
    r$all_chats_formatted <- NULL
    r$all_chats <- NULL

    shiny::observe({
      cli_inform(c("i" = "Querying OpenAI's API..."))
      cli_rule("Prompt")
      cat_print(input$chat_input)
      cli_rule("All chats")
      cat_print(r$all_chats)

      response <- openai_create_chat_completion()

      interim <- gpt_chat(query = input$chat_input,
                          history = r$all_chats,
                          style = input$style,
                          skill = input$skill)
      cli_inform(c("i" = "Response received."))
      new_response <- interim[[2]]$choices
      cli_rule("Response")
      cli_inform(interim[[2]]$choices$message.content)
      r$all_chats <-
        c(
          interim[[1]],
          list(
            list(
              role    = new_response$message.role,
              content = new_response$message.content
            )
          )
        )
      r$all_chats_formatted <- make_chat_history(r$all_chats)
      shiny::updateTextAreaInput(session, "chat_input", value = "")
    }) %>%
      shiny::bindEvent(input$chat)

    output$all_chats_box <- shiny::renderUI({
      shiny::req(length(r$all_chats) > 0)
      bslib::card(
        bslib::card_header("Chat History", class = "bg-primary"),
        bslib::card_body(
          fill = TRUE,
          r$all_chats_formatted
        )
      )
    })
    shiny::observe(shiny::stopApp()) %>% shiny::bindEvent(input$cancel)
  }

  shiny::shinyApp(ui, server)

}

make_chat_history <- function(history) {
  cli_inform("Making history...")
  history <-
    purrr::map(history, ~{if (.x$role == "system") NULL else .x}) %>%
    purrr::compact()

  purrr::map(history, ~{
    list(
      shiny::strong(toupper(.x$role)),
      shiny::markdown(.x$content)
    )
  })
}
