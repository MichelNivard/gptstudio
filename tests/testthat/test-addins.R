test_that("Spelling and grammer editing works", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    get_selection = function() "Do something",
    insert_text = function(x) x
  )
  gptstudio_spelling_grammar() |>
    expect_type("character") |>
    expect_length(1L)
})

test_that("Commenting code works", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    get_selection = function() "Do something",
    insert_text = function(x) x
  )
  gptstudio_comment_code() |>
    expect_type("character") |>
    expect_length(1L)
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
  gptstudio_chat_in_source_addin() |>
    expect_type("character") |>
    expect_length(2L)
})
