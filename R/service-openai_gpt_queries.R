gptstudio_chat_in_source <- function(task = NULL) {
  selection <- get_selection()

  if (is.null(task)) {
    gptstudio_chat_in_source_file_ext <- character(1L)

    tryCatch(expr = {
      doc_path <- rstudioapi::documentPath()
      gptstudio_chat_in_source_file_ext <- tools::file_ext(doc_path)
    }, error = function(e) {
      cli::cli_alert_info("Current document is not saved.
                          Assuming .R file extension")
      gptstudio_chat_in_source_file_ext <- "R"
    })

    task <- glue::glue(
      "You are an expert on following instructions without making conversation.",
      "Do the task specified after the colon,",
      "formatting your response to go directly into a .{gptstudio_chat_in_source_file_ext} file without any post processing", # nolint
      .sep = " "
    )
  }

  instructions <- glue::glue("{task}: {selection$value}")

  cli::cli_inform("{instructions}")

  cli::cli_progress_step("Sending query to ChatGPT...",
    msg_done = "ChatGPT responded",
    spinner = TRUE
  )

  cli::cli_progress_update()

  response <-
    gptstudio_create_skeleton(
      service = getOption("gptstudio.service"),
      prompt  = instructions,
      history = list(),
      stream  = FALSE,
      model   = getOption("gptstudio.model")
    ) %>%
    gptstudio_request_perform()

  text_to_insert <- as.character(response$response)
  insert_text(c(selection$value, text_to_insert))
}
