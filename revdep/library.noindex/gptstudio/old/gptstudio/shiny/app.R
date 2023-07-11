rlang::check_installed("waiter")
rlang::check_installed("bslib", version = "0.4.2")
library(gptstudio)
library(waiter)

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
    shiny::actionButton(
      width = "100%",
      inputId = "chat", label = "Chat",
      icon = shiny::icon("robot"), class = "btn-primary"
    ),
    shiny::br(), shiny::br(),
    shiny::fluidRow(
      shiny::selectInput(
        "style", "Programming Style",
        choices = c("tidyverse", "base", "no preference"),
        width = "50%"
      ),
      shiny::selectInput(
        "skill", "Programming Proficiency",
        choices = c("beginner", "intermediate", "advanced", "genius"),
        width = "50%"
      )
    ),
    shiny::actionButton(
      width = "100%",
      inputId = "clear_history", label = "Clear History",
      icon = shiny::icon("eraser")
    ),
  )
)


ui <- shiny::fluidPage(
  useWaiter(),
  theme = bslib::bs_theme(bootswatch = "morph", version = 5),
  title = "ChatGPT from gptstudio",
  shiny::br(),
  bslib::layout_column_wrap(
    width = 1 / 2,
    fill = FALSE,
    chat_card, shiny::uiOutput("all_chats_box")
  )
)

server <- function(input, output, session) {
  r <- shiny::reactiveValues()
  r$all_chats_formatted <- NULL
  r$all_chats <- NULL

  shiny::observe({
    waiter::waiter_show(
      html = shiny::tagList(spin_flower(), shiny::h3("Asking ChatGPT...")),
      color = waiter::transparent(0.5)
    )
    interim <- gpt_chat(
      query = input$chat_input,
      history = r$all_chats,
      style = input$style,
      skill = input$skill
    )
    new_response <- interim[[2]]$choices
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
    waiter::waiter_hide()
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
  shiny::observe(r$all_chats <- NULL) %>%
    shiny::bindEvent(input$clear_history)
}

shiny::shinyApp(ui, server)
