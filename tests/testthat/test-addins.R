test_that("Spelling and grammer editing works", {
  mockr::local_mock(
    gpt_edit = function(model = "a-model",
                        instruction = "some instructions",
                        temperature = .05) {
      list("text" = "new text")
    }
  )
  expect_type(sandgAddin(), "list")
})

test_that("Commenting code works", {
  mockr::local_mock(
    gpt_edit = function(model = "code-davinci-edit-001",
                        instruction = "some instructions",
                        temperature = 0.1) {
      list("text" = "new text")
    }
  )
  expect_type(comAddin(), "list")
})

test_that("Writing code / text works", {
  mockr::local_mock(
    gpt_create = function(model = "text-davinci-003",
                          max_tokens = 500,
                          temperature = 0.1) {
      list("text" = "new text")
    }
  )
  expect_type(wpAddin(), "list")
})

test_that("Active voice works", {
  mockr::local_mock(
    gpt_edit = function(model = "text-davinci-edit-001",
                        instruction = "rewrite text in the active voice",
                        temperature = 0.1) {
      list("text" = "new text")
    }
  )
  expect_type(avAddin(), "list")
})
