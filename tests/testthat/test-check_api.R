sample_key <- "38a5603f-85b0-4d2e-ae43-3d0778272d60"
sample_key2 <- "4a0eafd5-bcfc-426b-a1fa-5193b161d7d3"

test_that("API checking fails with missing, inactive, or badly formatted key", {
  withr::local_options(gptstudio.valid_api = FALSE)
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  expect_snapshot(check_api())
  withr::local_envvar("OPENAI_API_KEY" = "")
  expect_snapshot(check_api())
  withr::local_envvar("OPENAI_API_KEY" = "1234")
  expect_snapshot(check_api())
})

test_that("API checking works on CI", {
  mockr::local_mock(simple_api_check = function(api_check) 200)
  withr::local_options(gptstudio.valid_api = FALSE)
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  expect_snapshot(check_api())
  expect_snapshot(check_api())
  withr::local_envvar("OPENAI_API_KEY" = sample_key2)
  expect_snapshot(check_api())
})

test_that("API checking works, assumes OPENAI_API_KEY is set", {
  skip_if_offline()
  skip_on_ci()
  withr::local_options(gptstudio.valid_api = FALSE)
  expect_snapshot(check_api())
  # make sure skipping check works if first check works
  expect_snapshot(check_api())
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  expect_snapshot(check_api())
})

test_that("API key validation works", {
  expect_snapshot(check_api_key(sample_key))
  expect_snapshot(check_api_key("1234"))
  expect_snapshot(check_api_key(""))
})

test_that("API connection checking works", {
  expect_snapshot(check_api_connection(sample_key))
  expect_snapshot(check_api_connection(""))
})

test_that("API connection can return true", {
  skip_if_offline()
  skip_on_ci()
  withr::local_options(gptstudio.valid_api = FALSE)
  expect_snapshot(check_api_connection(Sys.getenv("OPENAI_API_KEY")))
})

# From GPT-4

test_that("obscure_key correctly obscures API keys", {
  expect_equal(obscure_key(sample_key), "38a5****************************2d60")
  expect_equal(obscure_key("12345678"), "<hidden> (too short to obscure)")
  expect_equal(obscure_key(""), "no key provided")
  expect_equal(obscure_key("1234"), "<hidden> (too short to obscure)")
})

test_that("set_openai_api_key handles valid and invalid API keys", {
  # Test for valid API key
  mockr::local_mock(readline_wrapper = function(prompt) sample_key)
  mockr::local_mock(simple_api_check = function(api_key) 200)
  expect_snapshot(set_openai_api_key())

  # Test for invalid API key
  withr::local_options(gptstudio.valid_api = FALSE)
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  mockr::local_mock(simple_api_check = function(api_key) 403)
  mockr::local_mock(ui_yeah_wrapper = function(prompt) FALSE)
  expect_snapshot(set_openai_api_key())
})

test_that("ask_to_set_api handles different user responses", {
  # Test when user wants to set API key and provides a valid key
  mockr::local_mock(ui_yeah_wrapper = function(prompt) TRUE)
  mockr::local_mock(readline_wrapper = function(prompt) sample_key)
  mockr::local_mock(simple_api_check = function(api_key) 200)
  expect_snapshot(ask_to_set_api())

  # Test when user wants to set API key but provides an invalid key
  expect_snapshot(ask_to_set_api())

  # Test when user doesn't want to set API key
  expect_snapshot(ask_to_set_api())
})
