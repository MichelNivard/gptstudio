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
