rlang::check_installed("waiter")
rlang::check_installed("bslib", version = "0.4.2")
library(gptstudio)
library(waiter)
library(shiny)


ui <- shiny::fluidPage(
  useWaiter(),
  theme = bslib::bs_theme(bootswatch = "morph", version = 5),
  title = "ChatGPT from gptstudio",
  class = "vh-100 p-3",

  div(
    class = "row justify-content-center h-100",
    div(
      class = "col h-100",
      style = htmltools::css(`max-width` = "800px"),
      gptstudio::mod_chat_ui("chat")
    )
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

    r$all_chats_formatted
  })

  shiny::observe(r$all_chats <- NULL) %>%
    shiny::bindEvent(input$clear_history)
}

shiny::shinyApp(ui, server)
