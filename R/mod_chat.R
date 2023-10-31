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
          streamingMessageOutput(ns("streaming")),
          # uiOutput(ns("streaming"))
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
  # This is where changes will focus
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    rv <- reactiveValues()

    settings <- mod_settings_server("settings")

    onStop(function() delete_skeleton())


    observe({

      rv$skeleton <-
        gptstudio_create_skeleton(service = settings$service,
                                  prompt  = input$chat_input,
                                  model   = settings$model,
                                  stream  = as.logical(settings$stream),
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

    reactive_stream <- reactiveFileReader(intervalMillis = 30,
                                          session = session,
                                          filePath = streaming_file(),
                                          readFunc = app_server_file_stream)
    reactive_skeleton <- reactiveFileReader(intervalMillis = 30,
                                            session = session,
                                            filePath = skeleton_file(),
                                            readFunc = get_skeleton)


    output$streaming <- renderStreamingMessage({
      # This has display: none by default. It is inly shown when receiving an stream
      # After the stream is completed it will reset.
      streamingMessage(ide_colors)
    }) %>%
      bindEvent(rv$stream_ended)




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
      gptstudio_submit_job(
        skeleton = rv$skeleton,
        skill = settings$skill,
        style = settings$style,
        task = settings$task,
        custom_prompt = settings$custom_prompt
      )
    }) %>%
      bindEvent(input$chat)

    observe({
      showModal(
        modalDialog(
          title = "Settings",
          easyClose = TRUE,
          footer = modalButton("Save"),
          size = "l",

          mod_settings_ui(ns("settings"))

        ))
    }) %>% bindEvent(input$settings)

  })
}


app_server_file_stream <- function(path) {
  if (file.exists(path)) {
    Sys.sleep(0.03)
    readRDS(path)
  } else {
    "No stream file found"
  }
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
  if (file.exists(skeleton_file())) file.remove(skeleton_file())
}

get_skeleton <- function(path = skeleton_file()) {
  if (!file.exists(path))  NULL else {
    Sys.sleep(0.03)
    readRDS(path)
  }
}

get_current_history <- function() {
  history <- get_skeleton() %>% purrr::pluck("history")
  gptstudio_env$current_history <- history
}
