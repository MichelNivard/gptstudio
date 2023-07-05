#' Chat UI
#'
#' @param id id of the module
#' @param translator A Translator from `shiny.i18n::Translator`
#'
mod_chat_ui <- function(id, translator = create_translator()) {
  ns <- NS(id)

  bslib::card(
    class = "h-100",
    bslib::card_body(
      class = "py-2 h-100",
      div(
        class = "d-flex flex-column h-100",
        div(
          class = "p-2 mh-100 overflow-auto",
          welcomeMessageOutput(ns("welcome")),
          uiOutput(ns("history")),
          uiOutput(ns("streaming"))
        ),
        div(
          class = "mt-auto",
          htmltools::div(
            class = "d-flex p-3",
            div(
              class = "flex-grow-1 pe-3",
              text_area_input_wrapper(
                inputId = ns("chat_input"),
                label = NULL,
                width = "100%",
                placeholder = translator$t("Write your prompt here"),
                value = "",
                resize = "vertical",
                rows = 5,
                textarea_class = "chat-prompt"
              )
            ),
            div(
              style = htmltools::css(width = "50px"),
              actionButton(
                inputId = ns("chat"),
                label = icon("fas fa-paper-plane"),
                class = "w-100 btn-primary p-1 chat-send-btn"
              ),
              actionButton(
                inputId = ns("clear_history"),
                label = icon("eraser"),
                class = "w-100 btn-primary mt-2 p-1"
              ),
              # bs_dropdown(
              actionButton(
                inputId = ns("settings"),
                label = icon("gear"),
                class = "w-100 btn-primary mt-2 p-1")
            )
          )
        )
      )
    )
  )
}

#' Chat server
#'
#' @param id id of the module
#' @param translator Translator from `shiny.i18n::Translator`
#' @inheritParams run_chatgpt_app
#'
mod_chat_server <- function(id,
                            ide_colors = get_ide_theme_info(),
                            translator = create_translator()) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    rv <- reactiveValues()

    api_services <- utils::methods("gptstudio_request_perform") %>%
      stringr::str_remove(pattern = "gptstudio_request_perform.gptstudio_request_") %>%
      purrr::discard(~ .x == "gptstudio_request_perform.default")

    onStop(function() delete_skeleton())

    chat_models <- reactive({
      req(!is.null(input$service))
      get_available_models(input$service)
    })

    observe(updateSelectInput(session,
                              inputId = "chat_model",
                              choices = chat_models()))

    observe({
      rv$skeleton <-
        gptstudio_create_skeleton(service = input$service,
                                  prompt  = input$chat_input,
                                  model   = input$chat_model,
                                  stream  = as.logical(input$stream),
                                  history = rv$chat_history)

      rv$chat_history <- chat_history_append(history = rv$chat_history,
                                             role = "user",
                                             content = input$chat_input)

      updateTextAreaInput(session, "chat_input", value = "")
    }) %>%
      bindEvent(input$chat)


    observe({
      rv$chat_history <- list()
      output$welcome <- renderWelcomeMessage({
        welcomeMessage(ide_colors)
      })
    }) %>%
      bindEvent(input$clear_history, ignoreNULL = FALSE)

    auto_invalidate <- reactiveTimer(10)

    output$streaming <- renderUI({
      auto_invalidate()
      if (file.exists(streaming_file())) {
        app_server_file_stream()
        list(
          list(
            role = "assistant",
            content = gptstudio_env$current_stream
          )
        ) %>%
          style_chat_history(ide_colors = ide_colors)
      }
    })

    observe({
      auto_invalidate()
      if (file.exists(skeleton_file())) {
        Sys.sleep(0.01)
        rv$skeleton <- get_skeleton()
        rv$chat_history <- rv$skeleton$history
        file.remove(skeleton_file())
      }
    })

    output$history <- renderUI({
      req(!is.null(rv$chat_history))
      rv$chat_history %>% style_chat_history(ide_colors = ide_colors)
    })

    observe({
      cli_inform("Submitting job.")
      skill <-
        ifelse(is.null(input$skill), getOption("gptstudio.skill"), input$skill)
      style <-
        ifelse(is.null(input$style), getOption("gptstudio.code_style"), input$style)
      task <-
        ifelse(is.null(input$task), getOption("gptstudio.task"), input$task)
      custom_prompt <- input$custom_prompt
      gptstudio_submit_job(rv$skeleton, skill, style, task, custom_prompt)
    }) %>%
      bindEvent(input$chat)

    output$about_you_ui <- renderUI({
      req(input$task == "coding")
      list(
        fluidRow(
          selectInput(
            inputId = ns("style"),
            label = translator$t("Programming Style"),
            choices = c("tidyverse", "base", "no preference"),
            selected = getOption("gptstudio.style"),
            width = "200px"
          ),
          selectInput(
            inputId = ns("skill"),
            label = translator$t("Programming Skill"),
            choices = c("beginner", "intermediate", "advanced", "genius"),
            selected = getOption("gptstudio.skill"),
            width = "200px"
          )
        )
      )
    })

    output$custom_prompt <- renderUI({
      req(input$task == "custom")
      textAreaInput(ns("custom_prompt"), "Custom Prompt",
                    value = getOption("gptstudio.custom_prompt"))
    })
    observe({
      showModal(
        modalDialog(
          title = "Settings",
          easyClose = TRUE,
          footer = modalButton("Save"),
          size = "l",
          fluidRow(
            selectInput(
              inputId = ns("task"),
              label = translator$t("Task"),
              choices = c("coding", "general", "advanced developer", "custom"),
              width = "200px",
            ),
            uiOutput(ns("about_you_ui")),
            uiOutput(ns("custom_prompt")),
            selectInput(
              inputId = ns("service"),
              label = "Select API Service",
              choices = api_services,
              selected = "openai",
              width = "200px",
            ),
            selectInput(
              inputId = ns("chat_model"),
              label = translator$t("Chat Model"),
              choices = NULL,
              width = "200px",
            ),
            radioButtons(
              inputId = ns("stream"),
              label = "Stream Response",
              choiceNames = c("Yes", "No"),
              choiceValues = c(TRUE, FALSE),
              inline = TRUE
            )
          )
        ))
    }) |> bindEvent(input$settings)
  })
}


app_server_file_stream <- function() {
  current_stream <- streaming_file() %>% readRDS() %>% try(silent = TRUE)
  if (!inherits(current_stream, "try-error")) {
    gptstudio_env$current_stream <- current_stream
  }
  invisible()
}

gptstudio_submit_job <- function(skeleton,
                                 skill,
                                 style,
                                 task,
                                 custom_prompt) {
  rs <- r_session_start()
  if (rs$get_state() != "idle") {
    cli_inform("Background session status: {rs$read()}")
    rs$finalize()
  }
  rs$call(
    function(skeleton, skill, style, task, custom_prompt) {
      gptstudio:::gptstudio_job(skeleton, skill, style, task, custom_prompt)
    },
    args = list(
      custom_prompt = custom_prompt,
      skeleton      = skeleton,
      skill         = skill,
      style         = style,
      task          = task
    )
  )
  rs$read_output()
}

gptstudio_job <- function(skeleton = gptstudio_create_skeleton(),
                          skill = "beginner",
                          style = "tidyverse",
                          task = "custom",
                          custom_prompt = "Respond in French") {
  delete_skeleton()
  gptstudio_skeleton_build(skeleton, skill, style, task, custom_prompt) %>%
    gptstudio_request_perform() %>%
    gptstudio_response_process() %>%
    save_skeleton()
}

r_session_start <- function() {
  if (is.null(gptstudio_env$r_session)) {
    gptstudio_env$r_session <- callr::r_session$new()
  }
  gptstudio_env$r_session
}

skeleton_file <- function() {
  dir <- tools::R_user_dir(package = "gptstudio", which = "data")
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
  file.path(dir, "chat_skeleton.RDS")
}

save_skeleton <- function(skeleton) {
  saveRDS(skeleton, skeleton_file())
}

delete_skeleton <- function() {
  cli_inform("Deleting chat history from this session.")
  if (file.exists(skeleton_file())) file.remove(skeleton_file())
}

get_skeleton <- function() {
  if (!file.exists(skeleton_file())) {
    cli_inform("Not chat history found.")
  } else {
    readRDS(skeleton_file())
  }
}

get_current_history <- function() {
  history <- get_skeleton() %>% purrr::pluck("history")
  gptstudio_env$current_history <- history
}
