mod_settings_ui <- function(id, translator = create_translator()) {
  ns <- NS(id)

  api_services <- utils::methods("gptstudio_request_perform") %>%
    stringr::str_remove(pattern = "gptstudio_request_perform.gptstudio_request_") %>%
    purrr::discard(~ .x == "gptstudio_request_perform.default")

  tagList(
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
  )
}

mod_settings_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    api_services <- utils::methods("gptstudio_request_perform") %>%
      stringr::str_remove(pattern = "gptstudio_request_perform.gptstudio_request_") %>%
      purrr::discard(~ .x == "gptstudio_request_perform.default")

    observe({
      models <- get_available_models(input$service)

      updateSelectInput(
        session = session,
        inputId = "model",
        choices = models,
        selected = getOption("gptstudio.model")
      )
    }) %>%
      bindEvent(input$service)

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

    ## Module output ----

    module_output <- reactiveValues()

    observe({
      module_output$task <- input$task %||% getOption("gptstudio.task")
      module_output$skill <- input$skill %||% getOption("gptstudio.skill")
      module_output$style <- input$style %||% getOption("gptstudio.code_style")
      module_output$model <- input$model %||% getOption("gptstudio.model")
      module_output$service <- input$service %||% getOption("gptstudio.service")
      module_output$stream <- as.logical(input$stream %||% getOption("gptstudio.stream"))
      module_output$custom_prompt <- input$custom_prompt %||% getOption("gptstudio.custom_prompt")
    }) %>%
      bindEvent(input$task, input$skill, input$style, input$model,
                input$service, input$stream, input$custom_prompt, ignoreNULL = FALSE)


    module_output

  })
}
