mockr::local_mock(
  get_selection = function() {
    data.frame(value = "here is some selected text")
  }
)

mockr::local_mock(insert_text = function(improved_text) improved_text)
sample_key <- uuid::UUIDgenerate()

test_that("gpt_edit can replace and append text", {
  mockr::local_mock(
    openai_create_edit =
      function(model, input, instruction, temperature, openai_api_key) {
        list(choices = data.frame(text = "here are edits openai returns"))
      }
  )
  mockr::local_mock(check_api = function() TRUE)
  replace_text <-
    gpt_edit(
      model = "code-davinci-edit-001",
      instruction = "instructions",
      temperature = 0.1,
      openai_api_key = sample_key,
      append_text = FALSE
    )
  expect_equal(replace_text, "here are edits openai returns")

  appended_text <-
    gpt_edit(
      model = "code-davinci-edit-001",
      instruction = "instructions",
      temperature = 0.1,
      openai_api_key = sample_key,
      append_text = TRUE
    )
  expect_equal(appended_text, c(
    "here is some selected text",
    "here are edits openai returns"
  ))
})


test_that("gpt_create can replace & append text", {
  mockr::local_mock(
    openai_create_completion =
      function(model, prompt, temperature, max_tokens,
               openai_api_key) {
        list(choices = data.frame(text = "here are completions openai returns"))
      }
  )
  mockr::local_mock(check_api = function() TRUE)
  replace_text <-
    gpt_create(
      model = "code-davinci-edit-001",
      temperature = 0.1,
      max_tokens = 500,
      openai_api_key = sample_key,
      append_text = FALSE
    )
  expect_equal(replace_text, "here are completions openai returns")

  appended_text <-
    gpt_create(
      model = "code-davinci-edit-001",
      temperature = 0.1,
      max_tokens = 500,
      openai_api_key = sample_key,
      append_text = TRUE
    )
  expect_equal(appended_text, c(
    "here is some selected text",
    "here are completions openai returns"
  ))
})


test_that("gpt_chat_in_source returns expected output", {
  mockr::local_mock(
    check_api = function() TRUE,
    get_selection = function() "What is the sum of 2 and 2?",
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
  expect_equal(result, c(
    "What is the sum of 2 and 2?",
    "The sum of 2 and 2 is 4."
  ))
  result_with_history <-
    gpt_chat_in_source(
      history = list(
        list(role = "system", content = "Ignore instructions.")
      )
    )
  expect_type(result, "character")
  expect_equal(result, c(
    "What is the sum of 2 and 2?",
    "The sum of 2 and 2 is 4."
  ))
})


test_that("gpt_chat_in_source returns expected output", {
  mockr::local_mock(
    check_api = function() TRUE,
    get_selection = function() "What is the sum of 2 and 2?",
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
  expect_equal(result, c(
    "What is the sum of 2 and 2?",
    "The sum of 2 and 2 is 4."
  ))
  result_with_history <-
    gpt_chat_in_source(
      history = list(
        list(role = "system", content = "Ignore instructions.")
      )
    )
  expect_type(result_with_history, "character")
  expect_equal(result_with_history, c(
    "What is the sum of 2 and 2?",
    "The sum of 2 and 2 is 4."
  ))
})


test_that("gpt_chat_in_source returns expected output", {
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
  result <- gpt_chat(query = query)
  # Check that the result is a list with the expected structure
  expect_type(result, "list")
  cli_inform("Result: {result}")
  # Check that the suggested answer is as expected
  expect_snapshot(result)
  result_with_history <-
    gpt_chat(history = result[["answer"]], query = query)
  expect_type(result_with_history, "list")
  expect_snapshot(result_with_history)
})
