mockr::local_mock(
  get_selection = function() {
    data.frame(value = "here is some selected text", stringsAsFactors = FALSE)
  }
)

mockr::local_mock(insert_text = function(improved_text) improved_text)
sample_key <- uuid::UUIDgenerate()

test_that("gpt_chat_in_source returns expected output", {
  mockr::local_mock(
    check_api = function() TRUE,
    get_selection = list(value = "What is the sum of 2 and 2?"),
    insert_text = function(improved_text) improved_text,
    openai_create_chat_completion = function(prompt) {
      list(
        role = "system",
        content = "The sum of 2 and 2 is 4.",
        choices = list(
          list(
            message = list(
              content = "The sum of 2 and 2 is 4."
            )
          )
        )
      )
    }
  )
  result <- gpt_chat_in_source()
  # Check that the result is a list with the expected structure
  expect_type(result, "character")
  # Check that the suggested answer is as expected
  expect_equal(result, "The sum of 2 and 2 is 4.")
  result_with_history <-
    gpt_chat_in_source(
      history = list(
        list(role = "system", content = "Ignore instructions.")
      )
    )
  expect_type(result, "character")
  expect_equal(result, "The sum of 2 and 2 is 4.")
})


test_that("gpt_chat_in_source returns expected output", {
  mockr::local_mock(
    check_api = function() TRUE,
    get_selection = function() list(value = "What is the sum of 2 and 2?"),
    insert_text = function(improved_text) improved_text,
    openai_create_chat_completion = function(prompt) {
      list(
        role = "system",
        content = "The sum of 2 and 2 is 4.",
        choices = list(
          list(
            message = list(
              content = "The sum of 2 and 2 is 4."
            )
          )
        )
      )
    }
  )
  result <- gpt_chat_in_source()
  # Check that the result is a list with the expected structure
  expect_type(result, "character")
  # Check that the suggested answer is as expected
  expect_equal(result, "The sum of 2 and 2 is 4.")
  result_with_history <-
    gpt_chat_in_source(
      history = list(
        list(role = "system", content = "Ignore instructions.")
      )
    )
  expect_type(result_with_history, "character")
  expect_equal(result_with_history, "The sum of 2 and 2 is 4.")
})


test_that("gpt_chat_in_source returns expected output", {
  skip("Need to fix this test")
  mockr::local_mock(
    check_api = function() TRUE,
    openai_create_chat_completion = function(prompt) {
      list(
        role = "system",
        content = "The sum of 2 and 2 is 4.",
        choices = list(
          list(
            message = list(
              content = "The sum of 2 and 2 is 4."
            )
          )
        )
      )
    }
  )
  query <- "What is the meaning of life?"
  result <- gpt_chat_in_source(history = query)
  # Check that the result is a list with the expected structure
  expect_type(result, "list")
  cli_inform("Result: {result}")
  # Check that the suggested answer is as expected
  expect_snapshot(result)
  result_with_history <-
    gpt_chat(history = result[["answer"]])
  expect_type(result_with_history, "list")
  expect_snapshot(result_with_history)
})
