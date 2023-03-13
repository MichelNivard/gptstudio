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

test_that("Active voice works", {
  mockr::local_mock(
    gpt_edit = function(model = "text-davinci-edit-001",
                        instruction = "rewrite text in the active voice",
                        temperature = 0.1) {
      list("text" = "new text")
    }
  )
  expect_type(addin_active_voice(), "list")
})
