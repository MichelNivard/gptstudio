# Define a test for the 'make_chat_history' function
test_that("make_chat_history function returns expected output", {
  skip_if_not(rstudioapi::isAvailable())
  mockr::local_mock(
    create_rstheme_matching_colors = function(role) {
      # provided that the RStudio IDE theme is "Solarized Dark"
      list(
        bg_color = if(role == "user") "#003441FF" else "#003A49FF",
        fg_color = "#93A1A1"
      )
    }
  )

  # Generate sample chat history data
  sample_history <- list(
    list(role = "system", content = "Hello, I am a bot."),
    list(role = "user", content = "Hi there!"),
    list(role = "assistant", content = "How can I help you today?")
  )

  # Call the function with sample data
  chat_history <- make_chat_history(sample_history)

  # Define expected output
  expected_output <- list(
    chat_message(list(role = "user", content = "Hi there!")),
    chat_message(list(role = "assistant", content = "How can I help you today?"))
  )

  # Test that the function returns the expected output
  expect_equal(chat_history, expected_output)

})
