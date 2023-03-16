.onLoad <- function(lib, pkg) {
  op <- options()
  op_gptstudio <- list(
    gptstudio.valid_api  = FALSE,
    gptstudio.openai_key = NULL,
    gptstudio.max_tokens = 500,
    gptstudio.code_style = "no preference",
    gptstudio.skill      = "beginner"
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
  cli_h1("Privacy Notice for gptstudio")
  cli_text("This privacy notice is applicable to the R package that utilizes the GPT-3 and GPT-3.5 API provided by OpenAI. By using this package, you agree to adhere to the privacy terms and conditions set by OpenAI.")
  cli_h2("Data Sharing with OpenAI")
  cli_text("When using this R package, the text or code that you highlight/select with your cursor, or the prompt you enter within the built-in applications, will be sent to OpenAI as part of an API request. This data sharing is governed by the privacy notice, rules, and exceptions that you agreed to with OpenAI when creating an account.")
  cli_h2("Security and Data Usage by OpenAI")
  cli_text("We cannot guarantee the security of the data you send to OpenAI via the API, nor can we provide details on how OpenAI processes or uses your data. However, OpenAI has stated that they utilize prompts and results to enhance their AI models, as outlined in their terms of use. You can opt-out of this data usage by contacting OpenAI directly and making an explicit request.")
  cli_h2("Limiting Data Sharing")
  cli_text("The R package is designed to share only the text or code that you specifically highlight/select or include in a prompt through our built-in applications. No other elements of your R environment will be shared. It is your responsibility to ensure that you do not accidentally share sensitive data with OpenAI.")
  cli_text("IMPORTANT: To maintain the privacy of your data, do not highlight, include in a prompt, or otherwise upload any sensitive data, code, or text that should remain confidential.")
  cli_h2("OpenAI's Terms of Use")
  cli_text("See OpenAI's Terms of Use at {.url https://openai.com/terms}.")
}
