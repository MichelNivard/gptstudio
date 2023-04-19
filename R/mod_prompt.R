#' Prompt of the chat
#'
#' HTML element with a text input and some buttons
#'
#' @param id id of the module
#'
#' @return HTML element
mod_prompt_ui <- function(id) {
  ns <- shiny::NS(id)

  htmltools::div(
    class = "d-flex p-3",
    div(
      class = "flex-grow-1 pe-3",
      textAreaInputWrapper(
        inputId = ns("chat_input"),
        label = NULL,
        width = "100%",
        placeholder = "Write your prompt here",
        value = "",
        resize = "vertical",
        rows = 3
      )
    ),
    div(
      style = htmltools::css(width = "50px"),
      shiny::actionButton(
        inputId = ns("chat"),
        label = fontawesome::fa("fas fa-paper-plane"),
        class = "w-100 btn-primary p-1"
      ),
      actionButton(
        inputId = ns("clear_history"),
        label = fontawesome::fa("eraser"),
        class = "w-100 btn-primary mt-2 p-1"
      ),
      bs_dropdown(
        label = fontawesome::fa("gear"),
        id = "dropd_settings",
        class = "w-100 btn-primary mt-2 p-1",
        shiny::selectInput(
          inputId = ns("style"),
          label = "Programming Style",
          choices = c("tidyverse", "base", "no preference"),
          width = "100%"
        ),
        shiny::selectInput(
          inputId = ns("skill"),
          label = "Programming Proficiency",
          choices = c("beginner", "intermediate", "advanced", "genius"),
          width = "100%"
        )
      )
    )
  )
}

#' Prompt Server
#'
#' This server receives the input of the user and makes the chat history
#'
#' @param id id of the module
#' @inheritParams run_chatgpt_app
#'
#' @return A shiny server
mod_prompt_server <- function(id, ide_colors = get_ide_theme_info()) {
    moduleServer(id, function(input, output, session) {

      rv <- reactiveValues()
      rv$chat_history <- chat_message_default()

      shiny::observe({
        waiter_color <- if (ide_colors$is_dark) "rgba(255,255,255,0.5)" else "rgba(0,0,0,0.5)"
        waiter::waiter_show(
          html = shiny::tagList(waiter::spin_flower(), shiny::h3("Asking ChatGPT...")),
          color = waiter_color
        )

        chat_response <- gpt_chat(
          query = input$chat_input,
          history = rv$chat_history,
          style = input$style,
          skill = input$skill
        )

        rv$chat_history <- chat_create_history(chat_response)

        waiter::waiter_hide()
        shiny::updateTextAreaInput(session, "chat_input", value = "")
      }) %>%
        shiny::bindEvent(input$chat)

      shiny::observe({
        rv$chat_history <- chat_message_default()
      }) %>%
        shiny::bindEvent(input$clear_history)

      # testing ----
      exportTestValues(
        chat_history = rv$chat_history
      )

      # module return ----
      rv
    })
}




#' Custom textAreaInput
#'
#' Modified version of `textAreaInput()` that removes the label container.
#' It's used in `mod_prompt_ui()`
#'
#' @inheritParams shiny::textAreaInput
#'
#' @return A modified textAreaInput
#'
textAreaInputWrapper <-
  function(inputId,
           label,
           value = "",
           width = NULL,
           height = NULL,
           cols = NULL,
           rows = NULL,
           placeholder = NULL,
           resize = NULL) {

    tag <- shiny::textAreaInput(
      inputId = inputId,
      label = label,
      value = value,
      width = width,
      height = height,
      cols = cols,
      rows = rows,
      placeholder = placeholder,
      resize = resize
    )

    if(is.null(label)) {
      tag_query <- htmltools::tagQuery(tag)

      tag_query$children("label")$remove()$allTags()

    } else {
      tag
    }
  }

#' Chat history
#'
#' This takes a response from chatgpt and converts it to a nice and consistent list.
#'
#' @param response A response from `gpt_chat()`.
#'
#' @return list of chat messages
#'
chat_create_history <- function(response) {
  previous_responses <- response[[1]]
  last_response <- response[[2]]$choices

  c(
    previous_responses,
    list(
      list(
        role    = last_response$message.role,
        content = last_response$message.content
      )
    )
  )
}


#' Default chat message
#'
#' @return A default chat message for welcoming users.
chat_message_default <- function() {

  welcome_messages <- c(
    "Welcome to the R programming language! I'm here to assist you in your journey, no matter your skill level.",
    "Hello there! Whether you're a beginner or a seasoned R user, I'm here to help.",
    "Hi! I'm your virtual assistant for R. Don't be afraid to ask me anything, I'm here to make your R experience smoother.",
    "Greetings! As an R virtual assistant, I'm here to help you achieve your coding goals, big or small.",
    "Welcome aboard! As your virtual assistant for R, I'm here to make your coding journey easier and more enjoyable.",
    "Nice to meet you! I'm your personal R virtual assistant, ready to answer your questions and provide support.",
    "Hi there! Whether you're new to R or an experienced user, I'm here to assist you in any way I can.",
    "Hello! As your virtual assistant for R, I'm here to help you overcome any coding challenges you might face.",
    "Welcome to the world of R! I'm your virtual assistant, here to guide you through the process of mastering this powerful language.",
    "Hey! I'm your personal R virtual assistant, dedicated to helping you become the best R programmer you can be.",
    "Greetings and welcome! I'm here to assist you on your R journey, no matter where you're starting from.",
    "Hi, I'm your R virtual assistant! My goal is to help you achieve success in your coding endeavors, whatever they may be.",
    "Hello and welcome! As your virtual assistant for R, I'm here to make your coding experience more efficient and productive.",
    "Hey there! I'm your personal R virtual assistant, ready to help you take your coding skills to the next level.",
    "Greetings! Whether you're a beginner or an experienced R user, I'm here to provide support and assistance.",
    "Hello and welcome to R! I'm your virtual assistant, and I'm excited to help you on your coding journey.",
    "Hey! I'm here to help you with all things R, no matter what your skill level is.",
    "Greetings and salutations! As your R virtual assistant, I'm here to provide the guidance and support you need to succeed.",
    "Welcome to the wonderful world of R! I'm your personal virtual assistant, ready to assist you in your coding journey.",
    "Hi there! Whether you're just starting out or a seasoned R user, I'm here to help you reach your coding goals.",
    "Hello and welcome to R! I'm your virtual assistant, and I'm here to help you navigate this powerful language with ease.",
    "Hey! I'm your personal R virtual assistant, and I'm dedicated to helping you achieve success in your coding endeavors.",
    "Greetings! As your virtual assistant for R, I'm here to help you become a confident and proficient R user.",
    "Welcome to the R community! I'm your virtual assistant, and I'm here to support you every step of the way.",
    "Hi there! I'm your personal R virtual assistant, and I'm committed to helping you achieve your coding goals."
  )

  paperplane <- fontawesome::fa("fas fa-paper-plane") |> as.character()
  eraser <- fontawesome::fa("eraser")
  gear <- fontawesome::fa("gear")

  explain_btns <- glue(
    "In this chat you can:

    - Send me a prompt ({paperplane})
    - Clear the current chat history ({eraser})
    - Change the settings ({gear})"
  )

  content <- glue(
    "{sample(welcome_messages, 1)}

    {explain_btns}

    Type anything to start our conversation."
  )

  list(
    list(
      role = "assistant",
      content = content
    )
  )
}
