StreamText <- R6::R6Class(
  classname = "StreamText",
  public = list(
    value = NULL,
    initialize = function(value = "") {
      self$value <- value
      invisible(self)
    },
    append_text = function(text) {
      self$value <- paste0(self$value, text)
      invisible(self)
    },
    print = function() {
      print(self$value)
      invisible(self)
    },
    get_value = function() {
      self$value
    }
  )
)

tempchar <- StreamText$new()

handle_stream <- function(x, char) {
  parsed <- rawToChar(x)

  char$append_text(parsed)
  cat(char$get_value())

  return(TRUE)
}

request_base("chat/completions") |>
  httr2::req_body_json(data = list(
    model = "gpt-3.5-turbo",
    messages = list(
      list(
        role = "user",
        content = "Count from 1 to 20"
      )
    )
  )) |>
  httr2::req_stream(callback = \(x) handle_stream(x, tempchar), buffer_kb = 0.010)
