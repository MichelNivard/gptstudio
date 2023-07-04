library(shinytest2)

test_that("{shinytest2} recording: mod_app", {
  app <- AppDriver$new(name = "mod_app",
                       seed = 123,
                       height = 929,
                       width = 1619)
  app$expect_values()
  input_text <-
    "return to me just the 'random' in plain text. make no comments about it."
  app$set_inputs(`app-chat-prompt-chat_input` = input_text)
  app$expect_values()
  app$click("app-chat-prompt-chat")
  app$click("app-chat-prompt-clear_history")
  app$expect_values()
  app$set_inputs(`app-chat-prompt-style` = "no preference")
  app$expect_values()
  app$set_inputs(`app-chat-prompt-skill` = "advanced")
  app$expect_values()
})
