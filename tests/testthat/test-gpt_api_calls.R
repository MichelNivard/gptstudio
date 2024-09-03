sample_key <- "4f9bb533-c0ac-4fef-9f7a-9eabe1afcc24"

test_that("OpenAI create completion fails with bad key", {
  expect_error(openai_create_completion(
    model = "text-davinci-003",
    prompt = "a test prompt",
    openai_api_key = sample_key
  ))
})

test_that("OpenAI create edit fails with bad key", {
  expect_error(openai_create_edit(
    model = "text-davinci-edit-001",
    input = "I is a human.",
    temperature = 1,
    instruction = "fix the grammar",
    openai_api_key = sample_key
  ))

  expect_error(openai_create_edit(
    model = "text-davinci-edit-001",
    input = "I is a human.",
    temperature = 1,
    instruction = "fix the grammar",
    top_p = 1,
    openai_api_key = sample_key
  ))
})

test_that("OpenAI create chat completion fails with bad key", {
  expect_error(
    create_chat_openai(
      prompt = "What is your name?",
      openai_api_key = sample_key
    )
  )
})
