#' gptstudio's internal API server
#'
#' Start a non blocking API for gptstudio's functionality
#'
run_text_inserter <- function() {
  rlang::check_installed(c("plumber2", "httpuv"))

  plumber2::api(port = httpuv::randomPort()) |>
    plumber2::api_doc_add(
      doc = list(
        info = list(
          title = "gptstudio's internal API",
          description = "This is a minimal API for gptstudio's functionality"
        )
      )
    ) |>
    plumber2::api_post(
      path = "/insert",
      handler = function(request, res, body) {
        rstudioapi::insertText(text = body$text)
        list(
          message = "Completed"
        )
      },
      parsers = plumber2::get_parsers("json"),
      serializers = plumber2::get_serializers("unboxedJSON"),
      doc = list(
        description = "Insert text into Rstudio's cursor position",
        requestBody = list(
          content = list(
            "application/json" = list(
              schema = list(
                type = "object",
                properties = list(
                  text = list(
                    type = "string"
                  )
                )
              )
            )
          )
        )
      )
    ) |>
    plumber2::api_on("end", function() {
      cli::cli_alert_info("gptstudio is no longer sharing your session")
    }) |>
    plumber2::api_run(silent = TRUE)
}

.internal_api_state <- new.env(parent = emptyenv())

set_internal_api <- function(api) {
  .internal_api_state$api <- api
}

get_internal_api <- function() {
  .internal_api_state$api
}

is_internal_api_running <- function() {
  api <- get_internal_api()
  !is.null(api) && inherits(api, "Fire") && api$is_running()
}

start_internal_api <- function() {
  if (is_internal_api_running()) {
    message("Internal api is already running.")
    return(invisible(get_internal_api()))
  }

  api <- run_text_inserter()

  set_internal_api(api)
  invisible(api)
}
