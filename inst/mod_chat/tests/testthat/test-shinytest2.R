library(shinytest2)

test_that("{shinytest2} recording: mod_chat", {
  app <- AppDriver$new(name = "mod_chat",
                       seed = 123,
                       height = 929,
                       width = 1619)
  app$expect_values()
  input_text <-
    "return to me just the 'random' in plain text. make no comments about it."
  app$set_inputs(`chat-prompt-chat_input` = input_text)
  app$expect_values()
  app$click("chat-prompt-chat")
  app$expect_values()
  app$click("chat-prompt-clear_history")
  app$expect_values()
})
