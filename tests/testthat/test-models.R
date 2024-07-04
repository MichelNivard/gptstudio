library(testthat)

# Define the mock functions for ollama
mock_ollama_is_available <- function() TRUE
mock_ollama_list <- function() list(models = list(
  list(name = "ollama-3.5"),
  list(name = "ollama-3"),
  list(name = "ollama-2")
))

# Create test cases
test_that("get_available_models works for openai", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "openai"
  models <- get_available_models(service)
  expect_equal(models, c(
    "gpt-3.5-turbo", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-1106",
    "gpt-3.5-turbo-16k", "gpt-4", "gpt-4-0125-preview", "gpt-4-0613",
    "gpt-4-1106-preview", "gpt-4-turbo", "gpt-4-turbo-2024-04-09",
    "gpt-4-turbo-preview", "gpt-4o", "gpt-4o-2024-05-13"
  ))
})

test_that("get_available_models works for huggingface", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "huggingface"
  models <- get_available_models(service)
  expect_equal(models, c("gpt2", "tiiuae/falcon-7b-instruct", "bigcode/starcoderplus"))
})

test_that("get_available_models works for anthropic", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "anthropic"
  models <- get_available_models(service)
  expect_equal(models, c(
    "claude-3-5-sonnet-20240620", "claude-3-opus-20240229", "claude-3-sonnet-20240229",
    "claude-3-haiku-20240307", "claude-2.1", "claude-instant-1.2"
  ))
})

test_that("get_available_models works for azure_openai", {
  service <- "azure_openai"
  models <- get_available_models(service)
  expect_equal(models, "Using ENV variables")
})

test_that("get_available_models works for perplexity", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "perplexity"
  models <- get_available_models(service)
  expect_equal(models, c(
    "llama-3-sonar-small-32k-chat", "llama-3-sonar-small-32k-online",
    "llama-3-sonar-large-32k-chat", "llama-3-sonar-large-32k-online",
    "llama-3-8b-instruct", "llama-3-70b-instruct", "mixtral-8x7b-instruct"
  ))
})

test_that("get_available_models works for ollama", {
  with_mocked_bindings(
    `ollama_is_available` = mock_ollama_is_available,
    `ollama_list` = mock_ollama_list, {
      service <- "ollama"
      models <- get_available_models(service)
      expect_equal(models, c("ollama-3.5", "ollama-3", "ollama-2"))
    }
  )
})

test_that("get_available_models works for cohere", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "cohere"
  models <- get_available_models(service)
  expect_equal(models, c(
    "command-r", "command-nightly", "command-r-plus", "c4ai-aya-23",
    "command-light-nightly", "command", "command-light"
  ))
})

test_that("get_available_models works for google", {
<<<<<<< HEAD
=======
  skip_if_offline()
>>>>>>> dd7d2e2 (add tests for getting models)
  service <- "google"
  models <- get_available_models(service)
  expect_equal(models, c(
    "chat-bison-001", "text-bison-001", "embedding-gecko-001",
    "gemini-1.0-pro", "gemini-1.0-pro-001", "gemini-1.0-pro-latest",
    "gemini-1.0-pro-vision-latest", "gemini-1.5-flash", "gemini-1.5-flash-001",
    "gemini-1.5-flash-latest", "gemini-1.5-pro", "gemini-1.5-pro-001",
    "gemini-1.5-pro-latest", "gemini-pro", "gemini-pro-vision",
    "embedding-001", "text-embedding-004", "aqa"
  ))
})
