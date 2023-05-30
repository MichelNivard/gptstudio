library(shinytest2)

test_that("mod_prompt works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  appdir <- system.file(package = "gptstudio", "mod_prompt")
  test_app(appdir)
})

test_that("chat_history_append() respects expected structure", {
  example_history <- list(
    list(role = "user", content = "hi")
  )

  expected_value <- list(
    list(role = "user", content = "hi"),
    list(role = "assistant", content = "assistant content")
  )

  chat_history_append(example_history, "assistant", "assistant content") %>%
    expect_equal(expected_value)
})
