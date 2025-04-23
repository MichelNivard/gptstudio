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
  skip_on_cran()
  skip_on_ci()
  service <- "openai"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for huggingface", {
  skip_on_cran()
  skip_on_ci()
  service <- "huggingface"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for anthropic", {
  skip_on_cran()
  skip_on_ci()
  service <- "anthropic"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for azure_openai", {
  skip_on_cran()
  skip_on_ci()
  service <- "azure_openai"
  models <- get_available_models(service)
  expect_equal(models, "Using ENV variables")
})

test_that("get_available_models works for perplexity", {
  skip_on_cran()
  skip_on_ci()
  service <- "perplexity"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for ollama", {
  skip_on_cran()
  skip_on_ci()
  skip_if_not(ollama_is_available())

  service <- "ollama"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for cohere", {
  skip_on_cran()
  skip_on_ci()
  service <- "cohere"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("get_available_models works for google", {
  skip_on_cran()
  skip_on_ci()
  service <- "google"
  models <- get_available_models(service)
  expect_type(models, "character")
})

test_that("set_allowed_models works", {
  skip_on_cran()
  skip_on_ci()

  service <- "openai"
  old_models <- get_allowed_models(service)
  new_models <- c("gpt-4")

  set_allowed_models(service, new_models)
  expect_equal(get_allowed_models(service), new_models)

  # Reset to old models
  set_allowed_models(service, old_models)
})
