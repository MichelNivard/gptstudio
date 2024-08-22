library(testthat)

# Define the mock functions for ollama
mock_ollama_is_available <- function() TRUE
mock_ollama_list <- function() {
  list(models = list(
    list(name = "ollama-3.5"),
    list(name = "ollama-3"),
    list(name = "ollama-2")
  ))
}

# Create test cases
test_that("get_available_models works for openai", {
  skip_on_ci()
  service <- "openai"
  models <- get_available_models(service)
  expect_snapshot(models)
})

test_that("get_available_models works for huggingface", {
  skip_on_ci()
  service <- "huggingface"
  models <- get_available_models(service)
  expect_equal(models, c("gpt2", "tiiuae/falcon-7b-instruct", "bigcode/starcoderplus"))
})

test_that("get_available_models works for anthropic", {
  skip_on_ci()
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
  skip_on_ci()
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
  skip_on_ci()
  service <- "cohere"
  models <- get_available_models(service)
  expect_snapshot(models)
})

test_that("get_available_models works for google", {
  skip_on_ci()
  service <- "google"
  models <- get_available_models(service)
  expect_snapshot(models)
})
