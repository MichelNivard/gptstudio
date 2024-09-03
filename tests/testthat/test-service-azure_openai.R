test_that("request_base_azure_openai constructs correct request", {
  mock_request <- function(url) {
    structure(list(url = url, headers = list()), class = "httr2_request")
  }

  mock_req_url_path_append <- function(req, path) {
    req$url <- paste0(req$url, "/", path)
    req
  }

  mock_req_url_query <- function(req, ...) {
    req$url <- paste0(req$url, "?api-version=test_version")
    req
  }

  mock_req_headers <- function(req, ...) {
    req$headers <- list(
      "api-key" = "test_token",
      "Content-Type" = "application/json"
    )
    req
  }

  withr::with_envvar(
    new = c(AZURE_OPENAI_USE_TOKEN = "false"),
    {
      local_mocked_bindings(
        request = mock_request,
        req_url_path_append = mock_req_url_path_append,
        req_url_query = mock_req_url_query,
        req_headers = mock_req_headers
      )

      result <- request_base_azure_openai(
        task = "test_task",
        base_url = "https://test.openai.azure.com",
        deployment_name = "test_deployment",
        api_key = "test_token",
        api_version = "test_version"
      )

      expect_equal(result$url, "https://test.openai.azure.com/openai/deployments/test_deployment/test_task?api-version=test_version") # nolint
      expect_equal(result$headers, list(
        "api-key" = "test_token",
        "Content-Type" = "application/json"
      ))
    }
  )
})

# Test token retrieval --------------------------------------------------------

test_that("retrieve_azure_token successfully gets existing token", {
  local_mocked_bindings(
    get_azure_login = function(...) {
      list(token = list(credentials = list(access_token = "existing_token")))
    },
    create_azure_login = function(...) stop("Should not be called"),
    .package = "AzureRMR"
  )

  token <- retrieve_azure_token()

  expect_equal(token, "existing_token")
})

test_that("retrieve_azure_token creates new token when get_azure_login fails", {
  local_mocked_bindings(
    get_azure_login = function(...) stop("Error"),
    create_azure_login = function(...) {
      list(token = list(credentials = list(access_token = "new_token")))
    },
    .package = "AzureRMR"
  )

  token <- retrieve_azure_token()

  expect_equal(token, "new_token")
})

test_that("retrieve_azure_token uses correct environment variables", {
  mock_get_azure_login <- function(tenant, app, scopes) {
    expect_equal(tenant, "test_tenant")
    expect_equal(app, "test_client")
    expect_equal(scopes, ".default")
    stop("Error")
  }

  mock_create_azure_login <- function(tenant, app, password, host, scopes) {
    expect_equal(tenant, "test_tenant")
    expect_equal(app, "test_client")
    expect_equal(password, "test_secret")
    expect_equal(host, "https://cognitiveservices.azure.com/")
    expect_equal(scopes, ".default")
    list(token = list(credentials = list(access_token = "new_token")))
  }

  local_mocked_bindings(
    get_azure_login = mock_get_azure_login,
    create_azure_login = mock_create_azure_login,
    .package = "AzureRMR"
  )

  withr::local_envvar(
    AZURE_OPENAI_TENANT_ID = "test_tenant",
    AZURE_OPENAI_CLIENT_ID = "test_client",
    AZURE_OPENAI_CLIENT_SECRET = "test_secret"
  )

  expect_no_error(retrieve_azure_token())
})

test_that("retrieve_azure_token checks for AzureRMR installation", {
  mock_check_installed <- function(pkg) {
    expect_equal(pkg, "AzureRMR")
  }

  local_mocked_bindings(
    check_installed = mock_check_installed,
    .package = "rlang"
  )

  expect_no_error(tryCatch(
    retrieve_azure_token(),
    error = function(e) {}
  ))
})
