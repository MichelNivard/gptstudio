#' Create a GPT Q&A File
#'
#' This function creates a GPT Q&A file for use with OpenAI's GPT models.
#'
#' @export
#'
create_gpt_chat <- function() {
  current_doc <- enc2utf8(rstudioapi::documentPath())
  if (is_true(getOption("gptstudio.chat_file") == current_doc)) {
    openai_chat()
  } else {
    setup_gpt_chat()
  }
}

#' Setup File for GPT Chat
#'
#' @param path The path of the file to be created. Defaults to "gpt_q_and_a.qmd"
setup_gpt_chat <- function(path = "gpt_q_and_a.qmd") {
  check_installed("quarto")
  if (is.null(quarto::quarto_path())) {
    cli::cli_warn(c(
      "x" = "Quarto is not installed.",
      "i" = "Visit {.url https://quarto.org/docs/get-started/} to install."
    ))
  }
  current_file <- enc2utf8(rstudioapi::documentPath())
  if (tolower(tools::file_ext(current_file) %in% c("qmd", "rmd"))) {
    use_current_file <-
      usethis::ui_yeah("Would you like to use {current_file} for your chat?")
    if (use_current_file) {
      options(
        gptstudio.chat_file = enc2utf8(rstudioapi::documentPath())
      )
    }
  } else {
    confirm_create <-
      usethis::ui_yeah("Would you like to create GPT Q&A file in {getwd()}?")
    if (confirm_create) {
      if (fs::file_exists(path)) {
        cli::cli_warn(c(
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
}

#' Generate an answer to a question using OpenAI
#'
#' @param model A string representing the name of the OpenAI model to use for
#'   generating the answer. Default is "text-davinci-003".
#' @param max_tokens An integer representing the maximum number of tokens to
#'   generate in the answer. Default is getOption("gptstudio.max_tokens").
#' @param temperature A numeric value between 0 and 1 representing the sampling
#'   temperature for the OpenAI model. Default is 0.5.
#' @param openai_api_key A string representing the OpenAI API key to use for
#'   making API calls. Default is the value of the environment variable
#'   "OPENAI_API_KEY".
#'
#' @export
#'
openai_chat <- function(model = "text-davinci-003",
                        max_tokens = getOption("gptstudio.max_tokens"),
                        temperature = 0.5,
                        openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
  active_doc <- rstudioapi::getSourceEditorContext()
  if (fs::path_ext(active_doc$path) != "qmd") {
    cli_abort(c(
      "i" = "Path: {active_doc$path}",
      "x" = "Quarto Q&A document is not selected. Please try again."
    ))
  }
  content <- readr::read_lines(active_doc$path)
  first_question <- which(stringr::str_starts(content, "Question"))[1]
  if (is_empty(first_question)) {
    cli_abort("First question not found.")
  } else {
    trimmed_content <- content[first_question:length(content)]
  }

  if (!rlang::is_empty(trimmed_content)) {
    cli_inform("Querying GPT for an answer...")
    response <-
      openai_create_completion(
        model = model,
        prompt = stringr::str_c(trimmed_content, collapse = "\n"),
        max_tokens = max_tokens,
        temperature = temperature,
        openai_api_key = openai_api_key
      )
    answer <- response$choice$text
  } else {
    cli_abort("Question no found in the document. Please try again.")
  }

  if (!is_empty(answer)) {
    cli_inform("Answer: {answer}")
    improved_text <- glue("{answer} \n\nQuestion: ")
    id <- active_doc$id
    rstudioapi::insertText(improved_text, id = id)
  } else {
    cli_abort("No answer returned or API query failed. Please try again.")
  }
}
