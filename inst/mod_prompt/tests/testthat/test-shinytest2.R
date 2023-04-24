library(shinytest2)

test_that("{shinytest2} recording: mod_prompt", {
  app <- AppDriver$new(name = "mod_prompt",
                       seed = 123,
                       height = 929,
                       width = 1619)
  app$expect_values()
  input_text <-
    "return to me just the 'random' in plain text. make no comments about it."
  app$set_inputs(`prompt-chat_input` = input_text)
  app$click("prompt-chat")
  app$expect_values()
  app$click("prompt-clear_history")
  app$expect_values()
  app$set_inputs(`prompt-style` = "base")
  app$expect_values()
  app$set_inputs(`prompt-skill` = "advanced")
  app$expect_values()
})
