library(shinytest2)

test_that("mod_app works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()
  skip("Need to fix")

  appdir <- system.file(package = "gptstudio", "mod_app")
  test_app(appdir)
})

test_that("rgb_str_to_hex() works as expected", {
  expect_equal(rgb_str_to_hex("rgb(147, 161, 161)"), "#93A1A1")
  expect_equal(rgb_str_to_hex("rgb(0, 43, 54)"), "#002B36")
  expect_equal(rgb_str_to_hex("rgba(0, 0, 0, 255)"), "#000000")
})

test_that("create_translator() fails when language is not supported", {
  create_translator("latin") %>%
    expect_error()
})
