mod_settings_ui <- function(id, translator = create_translator()) {
  ns <- NS(id)

  api_services <- utils::methods("gptstudio_request_perform") %>%
    stringr::str_remove(pattern = "gptstudio_request_perform.gptstudio_request_") %>%
    purrr::discard(~ .x == "gptstudio_request_perform.default")

  read_docs_label <- tags$span(
    "Read R help pages",
    bslib::tooltip(
      shiny::icon("info-circle"),
      "Add help pages of 'package::object' matches for context.
      Potentially expensive.
      Save as default to effectively change"
    )
  )

  preferences <- bslib::accordion(
    open = FALSE,
    multiple = FALSE,
    bslib::accordion_panel(
      title = "Assistant behavior",
      icon = fontawesome::fa("robot"),
      selectInput(
        inputId = ns("task"),
        label = translator$t("Task"),
        choices = c("coding", "general", "advanced developer", "custom"),
        width = "100%",
        selected = getOption("gptstudio.task")
      ),
      selectInput(
        inputId = ns("style"),
        label = translator$t("Programming Style"),
        choices = c("tidyverse", "base", "no preference"),
        selected = getOption("gptstudio.style"),
        width = "100%"
      ),
      selectInput(
        inputId = ns("skill"),
        label = "Programming Skill", # TODO: update translator
        choices = c("beginner", "intermediate", "advanced", "genius"),
        selected = getOption("gptstudio.skill"),
        width = "100%"
      ),
      textAreaInput(
        inputId = ns("custom_prompt"),
        label = translator$t("Custom Prompt"),
        value = getOption("gptstudio.custom_prompt"),
        width = "100%"
      ),
      bslib::input_switch(
        id = ns("read_docs"),
        label = read_docs_label,
        value = getOption("gptstudio.read_docs"),
        width = "100%"
      )
    ),
    bslib::accordion_panel(
      title = "API service",
      icon = fontawesome::fa("server"),
      selectInput(
        inputId = ns("service"),
        label = translator$t("Select API Service"),
        choices = api_services,
        selected = getOption("gptstudio.service"),
        width = "100%"
      ),
      selectInput(
        inputId = ns("model"),
        label = translator$t("Chat Model"),
        choices = getOption("gptstudio.model"),
        width = "100%",
        selected = getOption("gptstudio.model")
      ),
      bslib::input_switch(
        id = ns("stream"),
        label = "Stream Response",
        value = as.logical(getOption("gptstudio.stream")),
        width = "100%"
      )
    ),
    bslib::accordion_panel(
      title = "UI options",
      icon = fontawesome::fa("sliders"),
      selectInput(
        inputId = ns("language"),
        # label = translator$t("Language"), # TODO: update translator
        label = "Language",
        choices = c("en", "es", "de"),
        width = "100%",
        selected = getOption("gptstudio.language")
      )
    )
  )

  btn_to_history <- actionButton(
    inputId = ns("to_history"),
    label = fontawesome::fa("arrow-left-long"),
    class = "mb-3"
  ) %>%
    bslib::tooltip("Back to history")

  btn_save_as_default <- actionButton(
    inputId = ns("save_default"),
    label = fontawesome::fa("floppy-disk"),
    class = "mb-3"
  ) %>%
    bslib::tooltip("Save as default")

  btn_save_in_session <- actionButton(
    inputId = ns("save_session"),
    label = fontawesome::fa("bookmark"),
    class = "mb-3"
  ) %>%
    bslib::tooltip("Save for this session")

  tagList(
    btn_to_history,
    btn_save_in_session,
    btn_save_as_default,
    preferences
  )
}

mod_settings_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues()
    rv$selected_history <- 0L
    rv$modify_session_settings <- 0L
    rv$create_new_chat <- 0L

    observe({
      msg <- glue::glue("Fetching models for {input$service} service...")
      showNotification(ui = msg, type = "message", duration = 3, session = session)
      cli::cli_alert_info(msg)
      models <- tryCatch(
        {
          get_available_models(input$service)
        },
        error = function(e) {
          showNotification(
            ui = cli::ansi_strip(e$message),
            duration = 3,
            type = "error",
            session = session
          )

          cli::cli_alert_danger(e$message)
          return(NULL)
        }
      )

      if (length(models) > 0) {
        showNotification(ui = "Got models!", duration = 3, type = "message", session = session)
        cli::cli_alert_success("Got models!")

        default_model <- getOption("gptstudio.model")

        updateSelectInput(
          session = session,
          inputId = "model",
          choices = models,
          selected = if (default_model %in% models) default_model else models[1]
        )
      } else {
        showNotification(
          ui = "No models available",
          duration = 3,
          type = "error",
          session = session
        )
        cli::cli_alert_danger("No models available")

        updateSelectInput(
          session = session,
          inputId = "model",
          choices = character(),
          selected = NULL
        )
      }
    }) %>%
      bindEvent(input$service)


    observe({
      rv$selected_history <- rv$selected_history + 1L
    }) %>%
      bindEvent(input$to_history)


    observe({
      showModal(modalDialog(
        tags$p("These settings will persist for all your future chat sessions."),
        tags$p("After changing the settings a new chat will be created."),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_default"), "Ok")
        )
      ))
    }) %>%
      bindEvent(input$save_default)


    observe({
      if (!isTruthy(input$confirm_default)) {
        return()
      }

      save_user_config(
        code_style = input$style,
        skill = input$skill,
        task = input$task,
        language = input$language,
        service = input$service,
        model = input$model,
        custom_prompt = input$custom_prompt,
        stream = input$stream,
        read_docs = input$read_docs
      )

      rv$modify_session_settings <- rv$modify_session_settings + 1L

      removeModal(session)

      showNotification("Defaults updated", duration = 3, type = "message", session = session)
    }) %>% bindEvent(input$confirm_default)


    observe({
      showModal(modalDialog(

        tags$p("After changing the settings a new chat will be created."),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("confirm_session"), "Ok")
        )
      ))
    }) %>%
      bindEvent(input$save_session)

    observe({
      if (!isTruthy(input$confirm_session)) {
        return()
      }

      rv$modify_session_settings <- rv$modify_session_settings + 1L
      removeModal(session)
    }) %>%
      bindEvent(input$confirm_session)


    observe({
      rv$task <- input$task %||% getOption("gptstudio.task")
      rv$skill <- input$skill %||% getOption("gptstudio.skill")
      rv$style <- input$style %||% getOption("gptstudio.code_style")
      rv$model <- input$model %||% getOption("gptstudio.model")
      rv$service <- input$service %||% getOption("gptstudio.service")
      rv$stream <- as.logical(input$stream %||% getOption("gptstudio.stream"))
      rv$custom_prompt <- input$custom_prompt %||% getOption("gptstudio.custom_prompt")

      rv$create_new_chat <- rv$create_new_chat + 1L
    }) %>%
      bindEvent(rv$modify_session_settings)


    ## Module output ----
    rv
  })
}
