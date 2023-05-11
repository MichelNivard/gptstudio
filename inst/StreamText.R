StreamText <- R6::R6Class(
  classname = "StreamText",
  public = list(

    initialize = function() {
      private$value <- ""
      invisible(self)
    },

    append_text = function(text) {
      private$value <- paste0(private$value, text)

      # never change this order unless the API itself changes
      private$handle_chunk_id()
      private$handle_chunk_object()
      private$handle_chunk_created()
      private$handle_chunk_model()

      invisible(self)
    },

    print = function() {
      print(private$value)
      invisible(self)
    },

    get_value = function() {
      private$value
    },

    get_chunk_base = function() {
      private$chunk
    }

  ),

  private = list(
    value = NULL,
    chunk = list(
      choices = NULL,
      created = NULL,
      id = NULL,
      model = NULL,
      object = NULL
    ),

    handle_chunk_id = function() {
      is_set <- !is.null(private$chunk$id)

      if (is_set) return(NULL)

      if (stringr::str_detect(private$value, "^\\{\"id\":\"chatcmpl-[a-zA-Z0-9]+\",")) {

        private$chunk$id <- stringr::str_extract(private$value, "chatcmpl-[a-zA-Z0-9]+")

        private$value <- stringr::str_replace(private$value, "^(\\{)\"id\":\"chatcmpl-[a-zA-Z0-9]+\",", "\\1")
      }
    },

    handle_chunk_object = function() {
      is_set <- !is.null(private$chunk$object)

      if (is_set) return(NULL)

      if (stringr::str_detect(private$value, "^\\{\"object\":\"[\\w\\.]+\",")) {

        # private$chunk$object <- stringr::str_replace(private$value, "^\\{\"object\":\"([\\w\\.]+).*", "\\1")
        private$chunk$object <- "chat.completion.chunk"

        private$value <- stringr::str_replace(private$value, "^(\\{)\"object\":\"[\\w\\.]+\",", "\\1")
      }
    },

    handle_chunk_created = function() {
      is_set <- !is.null(private$chunk$created)

      if (is_set) return(NULL)

      if (stringr::str_detect(private$value, "^\\{\"created\":[\\d]+,")) {

        private$chunk$created <- stringr::str_replace(private$value, "^\\{\"created\":([\\d]+).*", "\\1") |> as.integer()

        private$value <- stringr::str_replace(private$value, "^(\\{)\"created\":[\\d]+,", "\\1")
      }
    },

    handle_chunk_model = function() {
      is_set <- !is.null(private$chunk$model)

      if (is_set) return(NULL)

      if (stringr::str_detect(private$value, "^\\{\"model\":\"[\\w\\d\\.\\-]+\",")) {

        private$chunk$model <- stringr::str_replace(private$value, "^\\{\"model\":\"([\\w\\d\\.\\-]+).*", "\\1")

        private$value <- stringr::str_replace(private$value, "^(\\{)\"model\":\"[\\w\\d\\.\\-]+\",", "\\1")
      }

    }
  )
)

full_stream <- "{\"id\":\"chatcmpl-7F2EGwP25x19nSqqewmxKHzbsNCeQ\",\"object\":\"chat.completion\",\"created\":1683817844,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":15,\"completion_tokens\":59,\"total_tokens\":74},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n"

full_stream |>
  stringr::str_replace("^(\\{)\"id\":\"chatcmpl-[a-zA-Z0-9]+\",", "\\1") |>
  stringr::str_replace("^(\\{)\"object\":\"[\\w\\.]+\",", "\\1") |>
  stringr::str_replace("^(\\{)\"created\":[\\d]+,", "\\1") |>
  stringr::str_replace("^(\\{)\"model\":\"[\\w\\d\\.\\-]+\",", "\\1")

# tempchar <- StreamText$new()
#
# handle_stream <- function(x, char) {
#   parsed <- rawToChar(x)
#
#   # print(parsed)
#
#   char$append_text(parsed)
#
#   return(TRUE)
# }
#
# request_base("chat/completions") |>
#   httr2::req_body_json(data = list(
#     model = "gpt-3.5-turbo",
#     messages = list(
#       list(
#         role = "user",
#         content = "Count from 1 to 20"
#       )
#     )
#   )) |>
#   httr2::req_stream(callback = \(x) handle_stream(x, tempchar), buffer_kb = 10/1024)



example_stream <- c(
  "{\"id\":\"cha",
  "tcmpl-7F2E",
  "GwP25x19nS",
  "qqewmxKHzb",
  "sNCeQ\",\"ob",
  "ject\":\"cha",
  "t.completi",
  "on\",\"creat",
  "ed\":168381",
  "7844,\"mode",
  "l\":\"gpt-3.",
  "5-turbo-03",
  "01\",\"usage",
  "\":{\"prompt",
  "_tokens\":1",
  "5,\"complet",
  "ion_tokens",
  "\":59,\"tota",
  "l_tokens\":",
  "74},\"choic",
  "es\":[{\"mes",
  "sage\":{\"ro",
  "le\":\"assis",
  "tant\",\"con",
  "tent\":\"1, ",
  "2, 3, 4, 5",
  ", 6, 7, 8,",
  " 9, 10, 11",
  ", 12, 13, ",
  "14, 15, 16",
  ", 17, 18, ",
  "19, 20.\"},",
  "\"finish_re",
  "ason\":\"sto",
  "p\",\"index\"",
  ":0}]}\n"
)


tempchar_example <- StreamText$new()

example_stream |>
  purrr::walk(\(x) tempchar_example$append_text(x))

tempchar_example$get_chunk_base()
tempchar_example$get_value()
