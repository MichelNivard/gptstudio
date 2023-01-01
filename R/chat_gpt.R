#' Create a GPT Q&A File
#'
#' This function creates a GPT Q&A file for use with OpenAI's GPT models.
#'
#' @param path The path of the file to be created. Defaults to "gpt_q_and_a.qmd"
#'
#' @export
#'
create_gpt_chat <- function(path = "gpt_q_and_a.qmd") {
  rlang::check_installed("quarto")
  if (is.null(quarto::quarto_path())) {
    cli::cli_abort(c(
      "x" = "Quarto is not installed.",
      "i" = "Visit {.url https://quarto.org/docs/get-started/} to install."
    ))
  }

  confirm_create <-
    usethis::ui_yeah("Would you like to create the GPT Q&A file in {getwd()}?")

  if (confirm_create) {
    if (fs::file_exists(path)) {
      cli::cli_alert_warning("File already exists at {path}.")
      cli::cli_alert_info("Opening that file instead.")
    } else {
      qna_file <- system.file("templates/gpt_q_and_a.qmd",
        package = "gptstudio"
      )
      fs::file_copy(qna_file, new_path = fs::path(getwd(), path))
    }
    usethis::edit_file(path)
  }
}



#' Generate an answer to a question using OpenAI
#'
#' @export
#'
openai_chat <- function() {
  active_doc <- rstudioapi::getSourceEditorContext()
  if (fs::path_ext(active_doc$path) != "qmd") {
    cli::cli_inform("Path: {active_doc$path}")
    cli::cli_abort("Quarto Q&A document is not selected. Please try again.")
  }
  content <- readr::read_lines(active_doc$path)
  first_question <- which(stringr::str_starts(content, "Q"))[1]
  if (rlang::is_empty(first_question)) {
    cli::cli_abort("First question not found.")
  } else {
    trimmed_content <- content[first_question:length(content)]
  }

  if (!rlang::is_empty(trimmed_content)) {
    cli::cli_alert_info("Querying GPT for an answer...")
    response <-
      openai_create_completion(
        model = "text-davinci-003",
        prompt = stringr::str_c(trimmed_content, collapse = "\n"),
        max_tokens = 500,
        temperature = 0.5,
        openai_api_key = Sys.getenv("OPENAI_API_KEY"),
        openai_organization = NULL
      )
    answer <- response$choice$text
  } else {
    cli::cli_abort("Question no found in the document. Please try again.")
  }

  if (!rlang::is_empty(answer)) {
    cli::cli_inform("Answer: {answer}")
    improved_text <- stringr::str_c(answer, "\n\nQuestion: ", collapse = "")
    id <- active_doc$id
    rstudioapi::insertText(improved_text, id = id)
  } else {
    cli::cli_abort("No answer returned or API query failed. Please try again.")
  }
}
