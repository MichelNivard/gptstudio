library(shinytest2)

test_that("mod_prompt works", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  appdir <- system.file(package = "gptstudio", "mod_prompt")
  test_app(appdir)
})
