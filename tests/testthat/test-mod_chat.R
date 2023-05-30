test_that("get_ide_theme_info() returns expected output", {
  ide_colors <- get_ide_theme_info()

  ide_colors %>%
    expect_type("list") %>%
    expect_length(3) %>%
    expect_named(c("is_dark", "bg", "fg"))
})

test_that("create_ide_matching_colors() returns default outside of rstudio", {
  user_colors <- create_ide_matching_colors("user")
  assistant_colors <- create_ide_matching_colors("assistant")

  user_colors %>%
    expect_type("list") %>%
    expect_length(2) %>%
    expect_named(c("bg_color", "fg_color"))

  assistant_colors %>%
    expect_type("list") %>%
    expect_length(2) %>%
    expect_named(c("bg_color", "fg_color"))
})

test_that("creat_ide_matching_colors() fails when role is not permitted", {
  expect_error(create_ide_matching_colors("system"))
})

test_that("style_chat_message() returns HTML element", {
  user_message <- list(
    role = "user",
    content = "Hello, how can I help you?"
  ) %>%
    style_chat_message()

  assistant_message <- list(
    role = "assistant",
    content = "Hello, how can I help you?"
  ) %>%
    style_chat_message()

  user_message %>%
    expect_s3_class("shiny.tag")

  assistant_message %>%
    expect_s3_class("shiny.tag")
})

test_that("style_chat_message() fails when role is not permitted", {
  expect_error(style_chat_message(list(
    role = "system",
    message = "some message"
  )))
})

test_that("style_chat_history() returns expected output", {
  history <- list(
    list(role = "system", content = "some message"),
    list(role = "user", content = "some message"),
    list(role = "assistant", content = "some message"),
    list(role = "user", content = "some message"),
    list(role = "assistant", content = "some message")
  ) %>%
    style_chat_history()

  history %>%
    expect_type("list") %>%
    expect_s3_class(NA) %>%
    expect_length(4)
})

library(shinytest2)

test_that("mod_chat works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  appdir <- system.file(package = "gptstudio", "mod_chat")
  test_app(appdir)
})
