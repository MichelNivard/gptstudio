test_that("shiny apps run", {
  chatgpt <- run_chat_gpt()
  expect_equal(class(chatgpt), "shiny.appobj")
})
