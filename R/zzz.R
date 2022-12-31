.onLoad <- function(lib, pkg) {
  op <- options()
  op_gptstudio <- list(
    gptstudio.valid_api  = FALSE,
    gptstudio.openai_key = NULL,
    gptstudio.max_tokens = 500
  )

  toset <- !(names(op_gptstudio) %in% names(op))
  if (any(toset)) options(op_gptstudio[toset])


  invisible()
}

globalVariables(".rs.invokeShinyPaneViewer")


.onAttach <- function(lib, pkg) {
  packageStartupMessage(startup_message(), appendLF = FALSE)
}

startup_message <- function() {
  cli::cli_h1("Privacy Notice for gptstudio")
  cli::cli_text(
    "These functions work by taking the text or code you have highlighted or
    selected with the cursor, or your prompt if you use one of the built-in
    apps, and send these to OpenAI as part of a prompt. Prompts fall under the
    privacy notice, rules, or exceptions you agreed to when making an OpenAI
    account. We cannot tell you or guarantee how secure these prompts are when
    sent to OpenAI. We do not know what OpenAI does with your prompts, but
    OpenAI is clear that they use prompts and results to improve their model
    unless you opt out explicitly by contacting them."
  )
  cli::cli_text()
  cli::cli_text(
    "The code is designed to ONLY share the highlighted or selected text, or a
    prompt you build with the help of one of our apps and no other elements of
    your R environment. Make sure you are aware of what you send to OpenAI and
    do not accidentally share sensitive data with OpenAI.\n"
  )
  cli::cli_text()
  cli::cli_text(
    cli::col_red(
      "{.strong DO NOT HIGHLIGHT AND THEREFORE UPLOAD DATA, CODE, OR TEXT THAT
      SHOULD REMAIN PRIVATE}"
    )
  )
  cli::cli_text()
  cli::cli_text("See OpenAI's Terms of Use at {.url https://openai.com/terms}.")
}
