library(shinytest2)

test_that("mod_prompt works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  appdir <- system.file(package = "gptstudio", "mod_prompt")
  test_app(appdir)
})

test_that("chat_create_history() respects expected structure", {
  example_response <-
    list(
      list(
        list(
          role = "system",
          content = structure(
            "You are a helpful chat bot that answers questions for an R programmer working in the RStudio IDE. They consider themselves to be a beginner R programmer. Provide answers with their skill level in mind.  ",
            class = c("glue",
                      "character")
          )
        ),
        list(
          role = "user",
          content = structure("Count from 1 to 5", class = c("glue",
                                                             "character"))
        )
      ),
      list(
        id = "chatcmpl-7GT59y6mYejSdcHzDaD5kAfVkHseY",
        object = "chat.completion",
        created = 1684159395L,
        model = "gpt-3.5-turbo-0301",
        usage = list(
          prompt_tokens = 60L,
          completion_tokens = 56L,
          total_tokens = 116L
        ),
        choices = list(list(
          message = list(role = "assistant", content = "Sure, here's how you can count from 1 to 5 in R:\n\n```\nfor(i in 1:5){\n  print(i)\n}\n```\n\nThis will create a loop that prints the numbers from 1 to 5, each on a new line."),
          finish_reason = "stop",
          index = 0L
        ))
      )
    )

  expected_value <-
    list(
      list(
        role = "system",
        content = structure(
          "You are a helpful chat bot that answers questions for an R programmer working in the RStudio IDE. They consider themselves to be a beginner R programmer. Provide answers with their skill level in mind.  ",
          class = c("glue",
                    "character")
        )
      ),
      list(
        role = "user",
        content = structure("Count from 1 to 5", class = c("glue",
                                                           "character"))
      ),
      list(role = "assistant", content = "Sure, here's how you can count from 1 to 5 in R:\n\n```\nfor(i in 1:5){\n  print(i)\n}\n```\n\nThis will create a loop that prints the numbers from 1 to 5, each on a new line.")
    )

  chat_create_history(chat_response) |>
    expect_equal(expected_value)

})
