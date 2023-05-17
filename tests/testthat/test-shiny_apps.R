# Define a test for the 'style_chat_history' function
test_that("style_chat_history function returns expected output", {
  # Generate sample chat history data
  sample_history <- list(
    list(role = "system", content = "Hello, I am a bot."),
    list(role = "user", content = "Hi there!"),
    list(role = "assistant", content = "How can I help you today?")
  )

  # Call the function with sample data
  chat_history <- style_chat_history(sample_history)

  # Define expected output
  expected_output <- list(
    style_chat_message(
      list(role = "user", content = "Hi there!")
    ),
    style_chat_message(
      list(role = "assistant", content = "How can I help you today?")
    )
  )

  # Test that the function returns the expected output
  expect_equal(chat_history, expected_output)
})
