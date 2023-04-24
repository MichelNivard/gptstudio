test_that("bs_dropdown() generates shiny.tag", {
  expect_s3_class(bs_dropdown("test", "id"), "shiny.tag")
})
