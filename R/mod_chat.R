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
    api_services <-
      utils::methods("gptstudio_request_perform") %>%
      stringr::str_remove(pattern = "gptstudio_request_perform.gptstudio_request_") %>%
      purrr::discard(~ .x == "gptstudio_request_perform.default")

    onStop(function() delete_skeleton())

    models <- reactive({
      req(!is.null(input$service))
      get_available_models(input$service)
    })

    observe(updateSelectInput(session,
                              inputId = "model",
                              choices = models(),
                              selected = getOption("gptstudio.model")))

    observe({
      model   <- input$model
      service <- input$service
      stream  <- input$stream
      if (is.null(model)) model <- getOption("gptstudio.model")
      if (is.null(service)) service <- getOption("gptstudio.service")
      if (is.null(stream)) stream <- getOption("gptstudio.stream")
      rv$skeleton <-
        gptstudio_create_skeleton(service = service,
                                  prompt  = input$chat_input,
                                  model   = model,
                                  stream  = as.logical(stream),
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

    reactive_stream <- reactiveFileReader(intervalMillis = 10,
                                          session = session,
                                          filePath = streaming_file(),
                                          readFunc = app_server_file_stream)
    reactive_skeleton <- reactiveFileReader(intervalMillis = 10,
                                            session = session,
                                            filePath = skeleton_file(),
                                            readFunc = get_skeleton)

    output$streaming <- renderUI({
      if (reactive_stream() != "No stream file found") {
        list(
          list(
            role = "assistant",
            content = reactive_stream()
          )
        ) %>%
          style_chat_history(ide_colors = ide_colors)
      }
    })

    observe({
      req(!is.null(reactive_skeleton()))
      rv$skeleton <- reactive_skeleton()
      rv$chat_history <- rv$skeleton$history
      file.remove(skeleton_file())
    })

    output$history <- renderUI({
      req(!is.null(rv$chat_history))
      rv$chat_history %>% style_chat_history(ide_colors = ide_colors)
    })

    observe({
      skill         <- input$skill
      style         <- input$style
      task          <- input$task
      custom_prompt <- input$custom_prompt
      if (is.null(skill)) skill <- getOption("gptstudio.skill")
      if (is.null(style)) style <- getOption("gptstudio.code_style")
      if (is.null(task))  task  <- getOption("gptstudio.task")
      if (is.null(custom_prompt)) {
        custom_prompt  <- getOption("gptstudio.custom_prompt")
      }
      gptstudio_submit_job(rv$skeleton, skill, style, task, custom_prompt)
    }) %>%
      bindEvent(input$chat)

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
              selected = getOption("gptstudio.task")
            ),
            selectInput(
              inputId = ns("language"),
              label = translator$t("Language"),
              choices = c("en", "es", "de"),
              width = "200px",
              selected = getOption("gptstudio.language")
            ),
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
            ),
            selectInput(
              inputId = ns("service"),
              label = translator$t("Select API Service"),
              choices = api_services,
              selected = getOption("gptstudio.service"),
              width = "200px"
            ),
            selectInput(
              inputId = ns("model"),
              label = translator$t("Chat Model"),
              choices = NULL,
              width = "200px",
              selected = getOption("gptstudio.model")
            ),
            radioButtons(
              inputId = ns("stream"),
              label = "Stream Response",
              choiceNames = c("Yes", "No"),
              choiceValues = c(TRUE, FALSE),
              inline = TRUE,
              width = "200px",
            ),
            textAreaInput(
              inputId = ns("custom_prompt"),
              label = translator$t("Custom Prompt"),
              value = getOption("gptstudio.custom_prompt"))
          ),
          column(width = 12, align = "right",
                 actionButton(ns("save_default"), "Save as Default",
                              icon = icon("save"),
                              width = "200px")
          )
        ))
    }) %>% bindEvent(input$settings)

    observe({
      save_user_config(
        code_style = input$style,
        skill = input$skill,
        task = input$task,
        language = input$language,
        service = input$service,
        model = input$model,
        custom_prompt = input$custom_prompt,
        stream = input$stream
      )
    }) %>% bindEvent(input$save_default)
  })
}


app_server_file_stream <- function(path) {
  ifelse(file.exists(path), readRDS(path), "No stream file found")
}

gptstudio_submit_job <- function(skeleton,
                                 skill,
                                 style,
                                 task,
                                 custom_prompt) {
  if (rlang::is_true(skeleton$stream)) {
    rs <- r_session_start()
    if (rs$get_state() != "idle") {
      cli_inform("Background session status: {rs$read()}")
      rs$finalize()
    }
    rs$call(
      function(skeleton, skill, style, task, custom_prompt) {
        gptstudio::gptstudio_job(skeleton, skill, style, task, custom_prompt)
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
  } else {
    waiter::waiter_show(
      html = tagList(waiter::spin_pong(),
                     br(), br(),
                     h4(glue("Busy chatting with {skeleton$model}"))))
    gptstudio_job(skeleton, skill, style, task, custom_prompt)
    waiter::waiter_hide()
  }
}

#' Perform Job
#'
#' Combined job to build the skeleton, perform the api request, and process
#' the response
#'
#' @param skeleton A GPT Studio request skeleton object.
#' @param style The style of code to use. Applicable styles can be retrieved
#'   from the "gptstudio.code_style" option. Default is the
#'   "gptstudio.code_style" option. Options are "base", "tidyverse", or "no
#'   preference".
#' @param skill The skill level of the user for the chat conversation. This can
#'   be set through the "gptstudio.skill" option. Default is the
#'   "gptstudio.skill" option. Options are "beginner", "intermediate",
#'   "advanced", and "genius".
#' @param task Specifies the task that the assistant will help with. Default is
#'   "coding". Others are "general", "advanced developer", and "custom".
#' @param custom_prompt This is a custom prompt that may be used to guide the AI
#'   in its responses. Default is NULL. It will be the only content provided to
#'   the system prompt.
#'
#' @export
gptstudio_job <- function(skeleton      = gptstudio_create_skeleton(),
                          skill         = getOption("gptstudio.skill"),
                          style         = getOption("gptstudio.code_style"),
                          task          = getOption("gptstudio.task"),
                          custom_prompt = getOption("gptstudio.custom_prompt"))
{
  delete_skeleton()
  gptstudio_skeleton_build(skeleton, skill, style, task, custom_prompt) %>%
    gptstudio_request_perform() %>%
    gptstudio_response_process() %>%
    save_skeleton()
  file.remove(streaming_file())
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

get_skeleton <- function(path = skeleton_file()) {
  if (!file.exists(path)) {
    cli_inform("Not chat history found.")
    NULL
  } else {
    readRDS(path)
  }
}

get_current_history <- function() {
  history <- get_skeleton() %>% purrr::pluck("history")
  gptstudio_env$current_history <- history
}
