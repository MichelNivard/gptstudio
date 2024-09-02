withr::local_envvar(
  list(
    "OPENAI_API_KEY" = "a-fake-key",
    "ANTHROPIC_API_KEY" = "a-fake-key",
    "HF_API_KEY" = "a-fake-key",
    "GOOGLE_API_KEY" = "a-fake-key",
    "AZURE_OPENAI_API_KEY" = "a-fake-key",
    "PERPLEXITY_API_KEY" = "a-fake-key",
    "COHERE_API_KEY" = "a-fake-key"
  )
)

test_that("create skeletons works", {
  config <- yaml::read_yaml(system.file("rstudio/config.yml",
    package = "gptstudio"
  ))
  set_user_options(config)

  withr::with_envvar(
    new = c(
      "OPENAI_API_KEY" = "a-fake-key",
      "ANTHROPIC_API_KEY" = "a-fake-key",
      "HF_API_KEY" = "a-fake-key",
      "GOOGLE_API_KEY" = "a-fake-key",
      "AZURE_OPENAI_API_KEY" = "a-fake-key",
      "PERPLEXITY_API_KEY" = "a-fake-key",
      "COHERE_API_KEY" = "a-fake-key",
      "OLLAMA_HOST" = "JUST A PLACEHOLDER"
    ),
    {
      expect_snapshot(gptstudio_create_skeleton())
      expect_snapshot(gptstudio_create_skeleton(service = "anthropic"))
      expect_snapshot(gptstudio_create_skeleton(service = "cohere"))
      expect_snapshot(gptstudio_create_skeleton(service = "google"))
      expect_snapshot(gptstudio_create_skeleton(service = "huggingface"))
      expect_snapshot(gptstudio_create_skeleton(service = "ollama"))
      expect_snapshot(gptstudio_create_skeleton(service = "openai"))
      expect_snapshot(gptstudio_create_skeleton(service = "perplexity"))
      expect_snapshot(gptstudio_create_skeleton(service = "azure-openai"))
    }
  )
})


test_that("gptstudio_create_skeleton creates correct skeleton for OpenAI", {
  skeleton <- gptstudio_create_skeleton(
    service = "openai",
    prompt = "What is R?",
    model = "gpt-4-turbo-preview"
  )

  expect_s3_class(skeleton, "gptstudio_request_openai")
  expect_equal(skeleton$model, "gpt-4-turbo-preview")
  expect_equal(skeleton$prompt, "What is R?")
  expect_true(skeleton$stream)
})

test_that("gptstudio_create_skeleton creates correct skeleton for Hugging Face", {
  skeleton <- gptstudio_create_skeleton(
    service = "huggingface",
    prompt = "What is R?",
    model = "gpt2"
  )

  expect_s3_class(skeleton, "gptstudio_request_huggingface")
  expect_equal(skeleton$model, "gpt2")
  expect_equal(skeleton$prompt, "What is R?")
  expect_false(skeleton$stream)
})

test_that("gptstudio_create_skeleton creates correct skeleton for Anthropic", {
  skeleton <- gptstudio_create_skeleton(
    service = "anthropic",
    prompt = "What is R?",
    model = "claude-3-5-sonnet-20240620"
  )

  expect_s3_class(skeleton, "gptstudio_request_anthropic")
  expect_equal(skeleton$model, "claude-3-5-sonnet-20240620")
  expect_equal(skeleton$prompt, "What is R?")
  expect_true(skeleton$stream)
})

test_that("gptstudio_create_skeleton creates correct skeleton for Cohere", {
  skeleton <- gptstudio_create_skeleton(
    service = "cohere",
    prompt = "What is R?",
    model = "command"
  )

  expect_s3_class(skeleton, "gptstudio_request_cohere")
  expect_equal(skeleton$model, "command")
  expect_equal(skeleton$prompt, "What is R?")
  expect_false(skeleton$stream)
})

test_that("new_gptstudio_request_skeleton_openai creates correct structure", {
  expect_snapshot({
    skeleton <- new_gptstudio_request_skeleton_openai(
      url = "https://api.openai.com/v1/chat/completions",
      api_key = "test_key",
      model = "gpt-4-turbo-preview",
      prompt = "What is R?",
      history = list(list(role = "system", content = "You are an R assistant")),
      stream = TRUE,
      n = 1
    )
    str(skeleton)
  })
})

test_that("new_gptstudio_request_skeleton_huggingface creates correct structure", {
  expect_snapshot({
    skeleton <- new_gptstudio_request_skeleton_huggingface(
      url = "https://api-inference.huggingface.co/models",
      api_key = "test_key",
      model = "gpt2",
      prompt = "What is R?",
      history = list(list(role = "system", content = "You are an R assistant")),
      stream = FALSE
    )
    str(skeleton)
  })
})


library(testthat)
library(gptstudio)

# Tests for new_gpstudio_request_skeleton
test_that("new_gpstudio_request_skeleton creates correct structure with valid inputs", {
  result <- new_gpstudio_request_skeleton(
    url = "https://api.example.com",
    api_key = "valid_key",
    model = "test_model",
    prompt = "What is R?",
    history = list(list(role = "system", content = "You are an R assistant")),
    stream = TRUE,
    extra_param = "value"
  )

  expect_s3_class(result, "gptstudio_request_skeleton")
  expect_equal(result$url, "https://api.example.com")
  expect_equal(result$api_key, "valid_key")
  expect_equal(result$model, "test_model")
  expect_equal(result$prompt, "What is R?")
  expect_equal(result$history, list(list(role = "system", content = "You are an R assistant")))
  expect_true(result$stream)
  expect_equal(result$extras, list(extra_param = "value"))
})

test_that("new_gpstudio_request_skeleton handles NULL history", {
  result <- new_gpstudio_request_skeleton(
    url = "https://api.example.com",
    api_key = "valid_key",
    model = "test_model",
    prompt = "What is R?",
    history = NULL,
    stream = FALSE
  )

  expect_null(result$history)
})

test_that("new_gpstudio_request_skeleton adds custom class", {
  result <- new_gpstudio_request_skeleton(
    url = "https://api.example.com",
    api_key = "valid_key",
    model = "test_model",
    prompt = "What is R?",
    history = list(),
    stream = TRUE,
    class = "custom_class"
  )

  expect_s3_class(result, c("custom_class", "gptstudio_request_skeleton"))
})

# Tests for validate_skeleton
test_that("validate_skeleton passes with valid inputs", {
  expect_silent(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "test_model",
      prompt = "What is R?",
      history = list(list(role = "system", content = "You are an R assistant")),
      stream = TRUE
    )
  )
})

test_that("validate_skeleton handles NULL history", {
  expect_silent(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "test_model",
      prompt = "What is R?",
      history = NULL,
      stream = TRUE
    )
  )
})

test_that("validate_skeleton throws error for invalid URL", {
  expect_snapshot(
    validate_skeleton(
      url = 123,
      api_key = "valid_key",
      model = "test_model",
      prompt = "What is R?",
      history = list(),
      stream = TRUE
    ),
    error = TRUE
  )
})

test_that("validate_skeleton throws error for empty API key", {
  expect_snapshot(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "",
      model = "test_model",
      prompt = "What is R?",
      history = list(),
      stream = TRUE
    ),
    error = TRUE
  )
})

test_that("validate_skeleton throws error for empty model", {
  expect_snapshot(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "",
      prompt = "What is R?",
      history = list(),
      stream = TRUE
    ),
    error = TRUE
  )
})

test_that("validate_skeleton throws error for non-character prompt", {
  expect_snapshot(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "test_model",
      prompt = list("not a string"),
      history = list(),
      stream = TRUE
    ),
    error = TRUE
  )
})

test_that("validate_skeleton throws error for invalid history", {
  expect_snapshot(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "test_model",
      prompt = "What is R?",
      history = "not a list",
      stream = TRUE
    ),
    error = TRUE
  )
})

test_that("validate_skeleton throws error for non-boolean stream", {
  expect_snapshot(
    validate_skeleton(
      url = "https://api.example.com",
      api_key = "valid_key",
      model = "test_model",
      prompt = "What is R?",
      history = list(),
      stream = "not a boolean"
    ),
    error = TRUE
  )
})
