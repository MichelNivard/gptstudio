sample_key <- uuid::UUIDgenerate()

test_that("API checking fails with random API key", {
  expect_error(check_api("1234"))
  expect_error(check_api(sample_key))
})

test_that("API checking works with check_api()", {
  skip_if_offline()
  skip_on_ci()
  expect_message(check_api())
  expect_message(check_api())
  withr::local_envvar("OPENAI_API_KEY" = sample_key)
  print(Sys.getenv("OPENAI_API_KEY"))
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

