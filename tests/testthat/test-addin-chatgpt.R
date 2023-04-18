test_that("random_port() works", {
  set.seed(123)

  random_port() %>%
    expect_equal(5466)
})

test_that("create_tmp_job_script() returns string", {
  create_tmp_job_script(
    appDir = system.file("shiny", package = "gptstudio"),
    host = "127.0.0.1",
    port = 3838
  ) %>%
    expect_type("character")
})
