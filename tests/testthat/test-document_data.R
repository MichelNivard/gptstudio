test_that("Summarize mtcars works", {
  expect_snapshot(summarize_data(mtcars, method = "skimr"))
  expect_snapshot(summarize_data(mtcars, method = "skimr_lite"))
  expect_snapshot(summarize_data(mtcars, method = "column_types"))
  expect_snapshot(summarize_data(mtcars, method = "summary"))
})

test_that("Summarize airquality works", {
  expect_snapshot(summarize_data(airquality, method = "skimr"))
  expect_snapshot(summarize_data(airquality, method = "skimr_lite"))
  expect_snapshot(summarize_data(airquality, method = "column_types"))
  expect_snapshot(summarize_data(airquality, method = "summary"))
})

test_that("Collect dataframes works", {
  data(mtcars)
  expect_snapshot(collect_dataframes() %>% as.character())
  expect_snapshot(collect_column_types(mtcars))
})


test_that("Prep data prompt works", {
  data(mtcars)
  expect_snapshot(prep_data_prompt(mtcars, "skimr", prompt = "test"))
  expect_snapshot(prep_data_prompt(mtcars, "skimr_lite", prompt = "test"))
  expect_snapshot(prep_data_prompt(mtcars, "column_types", prompt = "test"))
  expect_snapshot(prep_data_prompt(mtcars, "summary", prompt = "test"))
})
