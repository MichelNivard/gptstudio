sample_key <- uuid::UUIDgenerate()

test_that("API checking fails with random API key", {
  expect_error(check_api("1234"))
  expect_error(check_api(sample_key))
})

test_that("API checking works on CI", {
  mockr::local_mock(simple_api_check = function(api_check) 200)
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  expect_no_warning(check_api())
  expect_no_warning(check_api())
  withr::local_envvar("OPENAI_API_KEY" = uuid::UUIDgenerate())
  expect_message(check_api())
})

test_that("API checking works with check_api(), assumes OPENAI_API_KEY is set", {
  skip_if_offline()
  skip_on_ci()
  expect_message(check_api())
  # make sure skipping check works if first check works
  expect_message(check_api())
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  expect_error(check_api())
})
test_that("API key validation works", {
  expect_message(check_api_key(sample_key))
  expect_error(check_api_key("1234"))
  expect_error(check_api_key(""))
})

test_that("API connection checking works", {
  expect_error(check_api_connection(sample_key))
  expect_error(check_api_connection(""))
})

test_that("API connection can return true", {
  skip_if_offline()
  skip_on_ci()
  expect_message(check_api_connection())
})
