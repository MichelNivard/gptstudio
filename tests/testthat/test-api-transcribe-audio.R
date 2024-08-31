test_that("parse_data_uri correctly parses valid data URIs", {
  # Test case 1: Simple data URI
  uri1 <- "data:text/plain;base64,SGVsbG8gV29ybGQ="
  result1 <- parse_data_uri(uri1)
  expect_equal(result1$mime_type, "text/plain")
  expect_equal(result1$data, charToRaw("Hello World"))

  # Test case 2: Data URI with padding
  uri2 <- "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==" # nolint
  result2 <- parse_data_uri(uri2)
  expect_equal(result2$mime_type, "image/png")
  expect_true(length(result2$data) > 0)

  # Test case 3: Data URI without padding
  uri3 <- "data:audio/mp3;base64,AAAAHGZ0eXBNNEEgAAAAAE00QSBtcDQyaXNvbQ"
  result3 <- parse_data_uri(uri3)
  expect_equal(result3$mime_type, "audio/mp3")
  expect_true(length(result3$data) > 0)
})

test_that("parse_data_uri handles invalid inputs correctly", {
  # Test case 4: Invalid data URI format
  expect_error(parse_data_uri("not a data uri"), "Invalid data URI format")

  # Test case 5: Empty string
  expect_error(parse_data_uri(""), "Invalid data URI format")

  # Test case 6: NULL input
  expect_error(parse_data_uri(NULL), "Invalid input: data_uri must be a single character string")

  # Test case 7: Non-character input
  expect_error(parse_data_uri(123), "Invalid input: data_uri must be a single character string")

  # Test case 8: Character vector with length > 1
  expect_error(
    parse_data_uri(c(
      "data:text/plain;base64,SGVsbG8=",
      "data:text/plain;base64,V29ybGQ="
    )),
    "Invalid input: data_uri must be a single character string"
  )
})

test_that("parse_data_uri handles edge cases", {
  # Test case 9: Data URI with empty data
  uri9 <- "data:text/plain;base64,"
  result9 <- parse_data_uri(uri9)
  expect_equal(result9$mime_type, "text/plain")
  expect_equal(result9$data, raw(0))

  # Test case 10: Data URI with special characters in MIME type
  uri10 <- "data:application/x-custom+xml;base64,PGhlbGxvPndvcmxkPC9oZWxsbz4="
  result10 <- parse_data_uri(uri10)
  expect_equal(result10$mime_type, "application/x-custom+xml")
  expect_equal(result10$data, charToRaw("<hello>world</hello>"))
})
