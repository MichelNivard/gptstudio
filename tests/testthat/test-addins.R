test_that("Spelling and grammer editing works", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    get_selection = function() "Do something",
    insert_text = function(x) x
  )
  expect_type(gptstudio_spelling_grammar(), "character")
})

test_that("Commenting code works", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    get_selection = function() "Do something",
    insert_text = function(x) x
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
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    get_selection = function() "Do something",
    insert_text = function(x) x
  )
  expect_type(gptstudio_chat_in_source_addin(), "character")
})
