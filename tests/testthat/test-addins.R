test_that("Spelling and grammer editing works", {
  mockr::local_mock(
    gpt_edit = function(model = "a-model",
                        instruction = "some instructions",
                        temperature = .05) {
      list("text" = "new text")
    }
  )
  expect_type(addin_spelling_grammar(), "list")
})

test_that("Commenting code works", {
  mockr::local_mock(
    gpt_edit = function(model = "code-davinci-edit-001",
                        instruction = "some instructions",
                        temperature = 0.1) {
      list("text" = "new text")
    }
  )
  expect_type(addin_comment_code(), "list")
})

test_that("chatgpt_addin runs", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    check_api = function() {
      TRUE
    }
  )
  expect_type(addin_chatgpt(), "list")
})

test_that("chatgpt_addin_in_source runs", {
  mockr::local_mock(
    gpt_chat_in_source = function(style = "tidyverse", skill = "beginner") {
      list("text" = "here is some text")
    }
  )
  expect_type(addin_chatgpt_in_source(), "list")
})
