test_that(".onLoad sets options appropriately", {
  .onLoad()
  expect_false(getOption("gptstudio.valid_api"))
  expect_null(getOption("gptstudio.openai_key"))
})
