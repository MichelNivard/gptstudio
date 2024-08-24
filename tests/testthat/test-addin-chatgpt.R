test_that("find_available_port returns a valid port", {
  port <- find_available_port()
  expect_true(port >= 3000 && port <= 8000)
  expect_false(port %in% c(3659, 4045, 5060, 5061, 6000, 6566, 6665:6669, 6697))
})

test_that("create_temp_app_file creates a valid R script", {
  mock_get_ide_theme_info <- function() {
    list(
      editor_theme = "textmate",
      editor_theme_is_dark = FALSE
    )
  }

  local_mocked_bindings(
    get_ide_theme_info = mock_get_ide_theme_info,
    .package = "gptstudio"  # Specify the package explicitly
  )

  temp_file <- create_temp_app_file()

  expect_true(file.exists(temp_file))
  expect_true(grepl("\\.R$", temp_file))

  content <- readLines(temp_file)
  expect_snapshot(content)
})

test_that("run_app_background creates a job", {
  mock_job_run_script <- function(...) NULL
  mock_cli_alert_success <- function(...) NULL

  with_mocked_bindings(
    jobRunScript = mock_job_run_script,
    .package = "rstudioapi",
    {
      with_mocked_bindings(
        cli_alert_success = mock_cli_alert_success,
        .package = "cli",
        {
          expect_no_error(run_app_background("test_dir", "test_job", "127.0.0.1", 3000))
        }
      )
    }
  )
})

test_that("open_app_in_viewer opens the app correctly", {
  mock_translate_local_url <- function(...) "http://translated.url"
  mock_viewer <- function(...) NULL
  mock_cli_inform <- function(...) NULL
  mock_cli_alert_info <- function(...) NULL
  mock_wait_for_bg_app <- function(...) NULL

  with_mocked_bindings(
    translateLocalUrl = mock_translate_local_url,
    viewer = mock_viewer,
    .package = "rstudioapi",
    {
      with_mocked_bindings(
        cli_inform = mock_cli_inform,
        cli_alert_info = mock_cli_alert_info,
        .package = "cli",
        {
          local_mocked_bindings(
            wait_for_bg_app = mock_wait_for_bg_app
          )

          # Test for localhost
          expect_no_error(open_app_in_viewer("127.0.0.1", 3000))

          # Test for non-localhost
          expect_no_error(open_app_in_viewer("192.168.1.100", 3000))
        }
      )
    }
  )
})

test_that("wait_for_bg_app retries the request", {
  mock_request <- function(...) structure(list(), class = "httr2_request")
  mock_req_retry <- function(...) structure(list(), class = "httr2_request")
  mock_req_perform <- function(...) NULL

  with_mocked_bindings(
    request = mock_request,
    req_retry = mock_req_retry,
    req_perform = mock_req_perform,
    .package = "httr2",
    {
      expect_no_error(wait_for_bg_app("http://example.com"))
    }
  )
})

test_that("gptstudio_chat runs the app correctly", {
  mock_verify_available <- function() NULL
  mock_find_available_port <- function() 3000
  mock_create_temp_app_dir <- function() "test_dir"
  mock_run_app_background <- function(...) NULL
  mock_open_app_in_viewer <- function(...) NULL

  with_mocked_bindings(
    verifyAvailable = mock_verify_available,
    .package = "rstudioapi",
    {
      local_mocked_bindings(
        find_available_port = mock_find_available_port,
        create_temp_app_dir = mock_create_temp_app_dir,
        run_app_background = mock_run_app_background,
        open_app_in_viewer = mock_open_app_in_viewer
      )

      expect_no_error(gptstudio_chat())

      # Test with custom host
      expect_no_error(gptstudio_chat(host = "192.168.1.100"))
    }
  )
})
