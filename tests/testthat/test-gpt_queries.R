
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
