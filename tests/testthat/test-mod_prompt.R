library(shinytest2)

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
