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
    abort(c(
      "x" = "Quarto is not installed.",
      "i" = "Visit {.url https://quarto.org/docs/get-started/} to install."
    ))
  }

  confirm_create <-
    usethis::ui_yeah("Would you like to create the GPT Q&A file in {getwd()}?")

  if (confirm_create) {
    if (fs::file_exists(path)) {
      warn(c(
        "x" = "File already exists at {path}.",
        "i" = "Opening that file instead."
      ))
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
    abort(c(
      "i" = "Path: {active_doc$path}",
      "x" = "Quarto Q&A document is not selected. Please try again."
    ))
  }
  content <- readr::read_lines(active_doc$path)
  first_question <- which(stringr::str_starts(content, "Q"))[1]
  if (is_empty(first_question)) {
    abort("First question not found.")
  } else {
    trimmed_content <- content[first_question:length(content)]
  }

  if (!rlang::is_empty(trimmed_content)) {
    inform("Querying GPT for an answer...")
    response <-
      openai_create_completion(
        model = "text-davinci-003",
        prompt = stringr::str_c(trimmed_content, collapse = "\n"),
        max_tokens = 500,
        temperature = 0.5,
        openai_api_key = Sys.getenv("OPENAI_API_KEY")
      )
    answer <- response$choice$text
  } else {
    abort("Question no found in the document. Please try again.")
  }

  if (!is_empty(answer)) {
    inform("Answer: {answer}")
    improved_text <- stringr::str_c(answer, "\n\nQuestion: ", collapse = "")
    id <- active_doc$id
    rstudioapi::insertText(improved_text, id = id)
  } else {
    abort("No answer returned or API query failed. Please try again.")
  }
}
