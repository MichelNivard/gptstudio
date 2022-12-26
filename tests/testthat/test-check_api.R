test_that("API key validation works", {
  sample_key <- uuid::UUIDgenerate()
  expect_message(check_api_key(sample_key))
  expect_error(check_api_key("1234"))
  expect_error(check_api_key(""))
})

test_that("API connection checking works", {
  skip_if_offline()
  sample_key <- uuid::UUIDgenerate()
  expect_error(check_api_connection(sample_key))
})

test_that("API connection can return true", {
  skip_if_offline()
  expect_message(check_api_connection())
})
