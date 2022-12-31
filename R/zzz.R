.onLoad <- function(lib, pkg) {
  op <- options()
  op.gptstudio <- list(
    gptstudio.valid_api = FALSE,
    gptstudio.openai_key = NULL
  )

  toset <- !(names(op.gptstudio) %in% names(op))
  if (any(toset)) options(op.gptstudio[toset])


  invisible()
}

.onAttach <- function(lib, pkg) {
  packageStartupMessage(startup_message(), appendLF = FALSE)
}

globalVariables(".rs.invokeShinyPaneViewer")



startup_message <- function() {
  cli::cli_h1("Privacy Notice")
  cli::cli_h2("Please read this notice before using gptstudio")
  cli::cli_text("These functions work by taking the text or code you have highlighted/selected with the cursor, or your prompt if you use one of the built-in apps, and send these to OpenAI as part of a prompt; they fall under their privacy notice/rules/exceptions you agreed to with OpenAI when making an account. We can't tell you or guarantee how secure these prompts are when sent to OpenAI. We don’t know what OpenAI does with your prompts, but OpenAI is clear that they use prompts and results to improve their model (see their terms of use) unless you opt-out explicitly by contacting them. The code is designed to ONLY share the highlighted/selected text, or a prompt you build with the help of one of our apps and no other elements of your R environment. Make sure you are aware of what you send to OpenAI and do not accidentally share sensitive data with OpenAI.")
  cli::cli_text()
  cli::cli_text("{.strong DO NOT HIGHLIGHT AND THEREFORE UPLOAD DATA, CODE, OR TEXT THAT SHOULD REMAIN PRIVATE}")
}
