#' gptstudio's internal API server
#'
#' Start a non blocking API for gptstudio's functionality
#'
run_text_inserter <- function() {
  rlang::check_installed("plumber2")
  plumber2::api() |>
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
      description = "Insert text into Rstudio's cursor position",
      doc = list(
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
    plumber2::api_run(silent = TRUE)
}
