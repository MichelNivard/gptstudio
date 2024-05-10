test_that("OpenaiStreamParser works with different kinds of data values", {

  openai_parser <- function(sse) {
    parser <- OpenaiStreamParser$new()
    parser$parse_sse(sse)

    parser$events
  }

  event1 <- "data: []"
  event2 <- paste0("data: ", jsonlite::toJSON(chat_message_default()))
  event3 <- "message: data is empty here"
  event4 <- "data : [DONE]"

  expect_type(openai_parser(event1), "list")
  expect_type(openai_parser(event2), "list")
  expect_type(openai_parser(event3), "list")
  expect_type(openai_parser(event4), "list")

})
