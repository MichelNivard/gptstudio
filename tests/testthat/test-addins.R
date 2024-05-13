test_that("Spelling and grammer editing works", {
  mockr::local_mock(
    gptstudio_chat_in_source = function(
        task = "Add comments to explain this code. Your output will go directly into
    a source (.R) file. Comment the code line by line") {
      list("text" = "new text")
    }
  )
  expect_type(gptstudio_spelling_grammar(), "character")
})

test_that("Commenting code works", {
  mockr::local_mock(
    gptstudio_chat_in_source = function(task = "Add comments to explain this code.
      Your output will go directly into a source (.R) file. Comment the code line by line") {
      list("text" = "new text")
    }
  )
  expect_type(gptstudio_comment_code(), "character")
})

test_that("chatgpt_addin runs", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    check_api = function() {
      TRUE
    }
  )
  expect_type(gptstudio_chat(), "list")
})

test_that("chatgpt_addin_in_source runs", {
  mockr::local_mock(
    gptstudio_chat_in_source = function() {
      list("text" = "here is some text")
    }
  )
  expect_type(gptstudio_chat_in_source_addin(), "character")
})
