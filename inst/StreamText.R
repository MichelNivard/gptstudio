StreamText <- R6::R6Class(
  classname = "StreamText",
  public = list(

    initialize = function() {
      private$value <- "" # this will hold the stream and mutate it with inner methods
      private$value_buffer <- private$value # this will hold previous and current value
      private$full_response <- private$value # this will hold the full response
      invisible(self)
    },

    handle_text_stream = function(text) {
      private$value <- paste0(private$value, text)
      private$full_response <- paste0(private$full_response, text)

      private$generate_chunk_list()

      invisible(self)
    },

    print = function() {
      print(private$value)
      invisible(self)
    },

    get_value = function() {
      private$value
    },

    get_full_response = function() {
      private$full_response
    },

    get_base_chunk = function() {
      private$base_chunk
    },

    get_chunk_list = function() {
      private$chunk_list
    },

    reset_chunk_setup = function() {
      private$value = NULL

      private$base_chunk <- list(
        choices = NULL,
        created = NULL,
        id = NULL,
        model = NULL,
        object = NULL
      )

      private$chunk_list <- NULL

      invisible(self)
    }

  ),

  private = list(
    value = NULL,
    value_buffer = NULL,
    full_response = NULL,

    base_chunk = list(
      choices = NULL,
      created = NULL,
      id = NULL,
      model = NULL,
      object = NULL
    ),

    chunk_list = NULL,

    handle_base_chunk_id = function() {
      is_set <- !is.null(private$base_chunk$id)

      if (is_set) return(NULL)

      # matches strings that start with the exact sequence: `{"id":"chatcmpl-` followed by one or more alphanumeric characters, and ending with a comma.
      if (stringr::str_detect(private$value, "^\\{\"id\":\"chatcmpl-[a-zA-Z0-9]+\",")) {

        private$base_chunk$id <- stringr::str_extract(private$value, "chatcmpl-[a-zA-Z0-9]+")

        private$value <- stringr::str_replace(private$value, "^(\\{)\"id\":\"chatcmpl-[a-zA-Z0-9]+\",", "\\1")
      }
    },

    handle_base_chunk_object = function() {
      is_set <- !is.null(private$base_chunk$object)

      if (is_set) return(NULL)

      # matches strings that start with the exact sequence: {"object":" followed by one or more word characters or dots, and ending with a comma.
      if (stringr::str_detect(private$value, "^\\{\"object\":\"[\\w\\.]+\",")) {

        # private$base_chunk$object <- stringr::str_replace(private$value, "^\\{\"object\":\"([\\w\\.]+).*", "\\1")
        private$base_chunk$object <- "chat.completion.chunk"

        private$value <- stringr::str_replace(private$value, "^(\\{)\"object\":\"[\\w\\.]+\",", "\\1")
      }
    },

    handle_base_chunk_created = function() {
      is_set <- !is.null(private$base_chunk$created)

      if (is_set) return(NULL)

      # matches strings that start with the exact sequence: {"created": followed by one or more digits, and ending with a comma.
      if (stringr::str_detect(private$value, "^\\{\"created\":[\\d]+,")) {

        private$base_chunk$created <- stringr::str_replace(private$value, "^\\{\"created\":([\\d]+).*", "\\1") |> as.integer()

        private$value <- stringr::str_replace(private$value, "^(\\{)\"created\":[\\d]+,", "\\1")
      }
    },

    handle_base_chunk_model = function() {
      is_set <- !is.null(private$base_chunk$model)

      if (is_set) return(NULL)

      # matches strings that start with the exact sequence: {"model":" followed by one or more word characters, digits, dots, or hyphens, and ending with a comma.
      if (stringr::str_detect(private$value, "^\\{\"model\":\"[\\w\\d\\.\\-]+\",")) {

        private$base_chunk$model <- stringr::str_replace(private$value, "^\\{\"model\":\"([\\w\\d\\.\\-]+).*", "\\1")

        private$value <- stringr::str_replace(private$value, "^(\\{)\"model\":\"[\\w\\d\\.\\-]+\",", "\\1")
      }

    },

    initialize_chunk_list = function() {
      base_chunk_tracks_choices <- !is.null(private$base_chunk$choices)

      if (base_chunk_tracks_choices) return(NULL)

      usage_regex <- "^\\{\"usage\":\\{\"prompt_tokens\":\\d+,\"completion_tokens\":\\d+,\"total_tokens\":\\d+\\},"
      choices_regex <- "\"choices\":\\[\\{\"message\":\\{\"role\":\"assistant\",\"content\":\""

      full_regex <- paste0(usage_regex, choices_regex)

      if (stringr::str_detect(private$value, full_regex)) {
        private$value <- stringr::str_replace(private$value, full_regex, "")

        private$base_chunk$choices <- list(
          list(
            delta = list(),
            finish_reason = NULL,
            index = 0L
          )
        )

        role_chunk <- private$generate_single_chunk(
          delta_name = "role",
          delta_value = "assistant"
        )

        private$chunk_list <- list(role_chunk)
      }

    },

    generate_chunk_list = function() {
      # never change this order unless the API itself changes
      private$handle_base_chunk_id()
      private$handle_base_chunk_object()
      private$handle_base_chunk_created()
      private$handle_base_chunk_model()

      private$initialize_chunk_list()

      private$append_new_chunk()
    },

    generate_single_chunk = function(delta_name, delta_value) {
      match.arg(delta_name, c("role", "content"))

      copied_chunk <- private$base_chunk

      delta_value_has_new_line <- stringr::str_detect(delta_value, "\\n") # basically detecs the last stream

      if (delta_value_has_new_line) {
        copied_chunk$choices[[1]]$finish_reason <- "stop"
        return(copied_chunk)
      }

      copied_chunk$choices[[1]]$delta[[delta_name]] <- delta_value

      copied_chunk

    },

    append_new_chunk = function() {
      chunk_list_is_null <- is.null(private$chunk_list)

      if (chunk_list_is_null) return(NULL)

      new_chunk <- private$generate_single_chunk(
        delta_name = "content",
        delta_value = private$value
      )

      private$chunk_list <- c(private$chunk_list, list(new_chunk))

      # reset value
      private$value <- ""
    }

  )
)

full_stream <- "{\"id\":\"chatcmpl-7F2EGwP25x19nSqqewmxKHzbsNCeQ\",\"object\":\"chat.completion\",\"created\":1683817844,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":15,\"completion_tokens\":59,\"total_tokens\":74},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n"

full_stream |>
  stringr::str_replace("^(\\{)\"id\":\"chatcmpl-[a-zA-Z0-9]+\",", "\\1") |>
  stringr::str_replace("^(\\{)\"object\":\"[\\w\\.]+\",", "\\1") |>
  stringr::str_replace("^(\\{)\"created\":[\\d]+,", "\\1") |>
  stringr::str_replace("^(\\{)\"model\":\"[\\w\\d\\.\\-]+\",", "\\1") |>
  stringr::str_replace(full_regex, "")

tempchar <- character()

handle_stream <- function(x, char) {
  parsed <- rawToChar(x)

  # print(parsed)

  # char$handle_text_stream(parsed)

  tempchar <<- c(tempchar, parsed)

  return(TRUE)
}

request_base("chat/completions") |>
  httr2::req_body_json(data = list(
    model = "gpt-3.5-turbo",
    messages = list(
      list(
        role = "user",
        content = "Generate a JSON text to store customer data. return a single object for 3 customers."
      )
    )
  )) |>
  httr2::req_stream(callback = \(x) handle_stream(x, tempchar), buffer_kb = 10/1024)

example_stream2 <-
  c(
    "{\"id\":\"cha",
    "tcmpl-7F7B",
    "sNWFht4pWw",
    "rPPSE3vJAu",
    "B9efW\",\"ob",
    "ject\":\"cha",
    "t.completi",
    "on\",\"creat",
    "ed\":168383",
    "6916,\"mode",
    "l\":\"gpt-3.",
    "5-turbo-03",
    "01\",\"usage",
    "\":{\"prompt",
    "_tokens\":2",
    "6,\"complet",
    "ion_tokens",
    "\":251,\"tot",
    "al_tokens\"",
    ":277},\"cho",
    "ices\":[{\"m",
    "essage\":{\"",
    "role\":\"ass",
    "istant\",\"c",
    "ontent\":\"{",
    "\\n  \\\"cust",
    "omers\\\": [",
    "\\n    {\\n ",
    "     \\\"fir",
    "stName\\\": ",
    "\\\"John\\\",\\",
    "n      \\\"l",
    "astName\\\":",
    " \\\"Doe\\\",\\",
    "n      \\\"e",
    "mail\\\": \\\"",
    "johndoe@ex",
    "ample.com\\",
    "\",\\n      ",
    "\\\"phone\\\":",
    " \\\"555-555",
    "-5555\\\",\\n",
    "      \\\"ad",
    "dress\\\": {",
    "\\n        ",
    "\\\"street\\\"",
    ": \\\"123 Ma",
    "in St\\\",\\n",
    "        \\\"",
    "city\\\": \\\"",
    "Anytown\\\",",
    "\\n        ",
    "\\\"state\\\":",
    " \\\"CA\\\",\\n",
    "        \\\"",
    "zip\\\": \\\"1",
    "2345\\\"\\n  ",
    "    }\\n   ",
    " },\\n    {",
    "\\n      \\\"",
    "firstName\\",
    "\": \\\"Jane\\",
    "\",\\n      ",
    "\\\"lastName",
    "\\\": \\\"Doe\\",
    "\",\\n      ",
    "\\\"email\\\":",
    " \\\"janedoe",
    "@example.c",
    "om\\\",\\n   ",
    "   \\\"phone",
    "\\\": \\\"555-",
    "555-5555\\\"",
    ",\\n      \\",
    "\"address\\\"",
    ": {\\n     ",
    "   \\\"stree",
    "t\\\": \\\"456",
    " Elm St\\\",",
    "\\n        ",
    "\\\"city\\\": ",
    "\\\"Anytown\\",
    "\",\\n      ",
    "  \\\"state\\",
    "\": \\\"CA\\\",",
    "\\n        ",
    "\\\"zip\\\": \\",
    "\"12345\\\"\\n",
    "      }\\n ",
    "   },\\n   ",
    " {\\n      ",
    "\\\"firstNam",
    "e\\\": \\\"Bob",
    "\\\",\\n     ",
    " \\\"lastNam",
    "e\\\": \\\"Smi",
    "th\\\",\\n   ",
    "   \\\"email",
    "\\\": \\\"bobs",
    "mith@examp",
    "le.com\\\",\\",
    "n      \\\"p",
    "hone\\\": \\\"",
    "555-555-55",
    "55\\\",\\n   ",
    "   \\\"addre",
    "ss\\\": {\\n ",
    "       \\\"s",
    "treet\\\": \\",
    "\"789 Oak S",
    "t\\\",\\n    ",
    "    \\\"city",
    "\\\": \\\"Anyt",
    "own\\\",\\n  ",
    "      \\\"st",
    "ate\\\": \\\"C",
    "A\\\",\\n    ",
    "    \\\"zip\\",
    "\": \\\"12345",
    "\\\"\\n      ",
    "}\\n    }\\n",
    "  ]\\n}\"},\"",
    "finish_rea",
    "son\":\"stop",
    "\",\"index\":",
    "0}]}\n"
  )



example_stream1 <- c(
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

example_stream2 |>
  purrr::walk(\(x) tempchar_example$handle_text_stream(x))

tempchar_example$get_base_chunk()
tempchar_example$get_value()
tempchar_example$get_full_response()
tempchar_example$get_chunk_list()
