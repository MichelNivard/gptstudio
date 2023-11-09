mod_sidebar_ui <- function(id, translator = create_translator()) {
  ns <- NS(id)
  tagList(
    bslib::navset_hidden(
      id = ns("panel"),
      selected = "history",

      bslib::nav_panel_hidden(
        value = "history",
        class = "px-0 py-2",
        mod_history_ui(id = ns("history"))

      ),
      bslib::nav_panel_hidden(
        value = "settings",
        class = "px-0 py-2",
        mod_settings_ui(id = ns("settings"), translator = translator)
      )
    )
  )
}

mod_sidebar_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      settings <- mod_settings_server("settings")
      history <- mod_history_server("history", settings)

      observe({
        bslib::nav_select("panel", selected = "settings", session = session)
      }) %>%
        bindEvent(history$selected_settings, ignoreInit = TRUE)

      observe({
        bslib::nav_select("panel", selected = "history", session = session)
      }) %>%
        bindEvent(settings$selected_history, ignoreInit = TRUE)

      list(
        settings = settings,
        history = history
      )
    }
  )
}
