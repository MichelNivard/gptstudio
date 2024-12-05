test_that("create_completion_azure_openai formats request correctly", {
  mock_query_api <- function(task, request_body, base_url, deployment_name,
                             api_key, api_version) {
    list(choices = list(list(message = list(content = "Mocked response"))))
  }

  withr::with_envvar(
    new = c(
      AZURE_OPENAI_TASK = "env_task",
      AZURE_OPENAI_ENDPOINT = "https://env.openai.azure.com",
      AZURE_OPENAI_DEPLOYMENT_NAME = "env_deployment",
      AZURE_OPENAI_API_KEY = "env_token",
      AZURE_OPENAI_API_VERSION = "env_version"
    ),
    {
      local_mocked_bindings(
        query_api_azure_openai = mock_query_api
      )

      result <- create_completion_azure_openai("Test prompt")

      expect_type(result, "list")
      expect_equal(result$choices[[1]]$message$content, "Mocked response")
    }
  )
})

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

test_that("query_api_azure_openai handles successful response", {
  mock_request_base <- function(...) {
    structure(list(url = "https://test.openai.azure.com", headers = list()),
      class = "httr2_request"
    )
  }

  mock_req_perform <- function(req) {
    structure(list(status_code = 200, body = '{"result": "success"}'),
      class = "httr2_response"
    )
  }

  mock_resp_body_json <- function(resp) list(result = "success")

  local_mocked_bindings(
    request_base_azure_openai = mock_request_base,
    req_body_json = function(req, body) req,
    req_retry = function(req, max_tries) req,
    req_error = function(req, is_error) req,
    req_perform = mock_req_perform,
    resp_is_error = function(resp) FALSE,
    resp_body_json = mock_resp_body_json
  )

  result <- query_api_azure_openai(
    task = "test_task",
    request_body = list(list(role = "user", content = "Test prompt")),
    base_url = "https://test.openai.azure.com",
    deployment_name = "test_deployment",
    api_key = "test_token",
    api_version = "test_version"
  )

  expect_type(result, "list")
  expect_equal(result$result, "success")
})

test_that("query_api_azure_openai handles error response", {
  mock_request_base <- function(...) {
    structure(list(url = "https://test.openai.azure.com", headers = list()),
      class = "httr2_request"
    )
  }

  mock_req_perform <- function(req) {
    structure(list(status_code = 400, body = '{"error": "Bad Request"}'),
      class = "httr2_response"
    )
  }

  local_mocked_bindings(
    request_base_azure_openai = mock_request_base,
    req_body_json = function(req, body) req,
    req_retry = function(req, max_tries) req,
    req_error = function(req, is_error) req,
    req_perform = mock_req_perform,
    resp_is_error = function(resp) TRUE,
    resp_status = function(resp) 400,
    resp_status_desc = function(resp) "Bad Request"
  )

  expect_error(
    query_api_azure_openai(
      task = "test_task",
      request_body = list(list(role = "user", content = "Test prompt")),
      base_url = "https://test.openai.azure.com",
      deployment_name = "test_deployment",
      api_key = "test_token",
      api_version = "test_version"
    ),
    "Azure OpenAI API request failed. Error 400 - Bad Request"
  )
})

# Test token retrieval --------------------------------------------------------

test_that("retrieve_azure_token successfully gets existing token", {
  local_mocked_bindings(
    get_graph_login = function(...) {
      list(credentials = list(access_token = "existing_token"))
    },
    create_graph_login = function(...) stop("Should not be called"),
    .package = "AzureGraph"
  )

  token <- retrieve_azure_token()

  expect_equal(token, "existing_token")
})

test_that("retrieve_azure_token creates new token when get_graph_login fails", {
  local_mocked_bindings(
    get_graph_login = function(...) stop("Error"),
    create_graph_login = function(...) {
      list(credentials = list(access_token = "new_token"))
    },
    .package = "AzureGraph"
  )

  token <- retrieve_azure_token()

  expect_equal(token, "new_token")
})


test_that("retrieve_azure_token uses correct environment variables", {
  mock_get_graph_login <- function(tenant, app, scopes, refresh) {
    expect_equal(tenant, "test_tenant")
    expect_equal(app, "test_client")
    expect_equal(scopes, NULL)
    expect_equal(refresh, FALSE)
    stop("Error")
  }

  mock_create_graph_login <- function(tenant, app, host, scopes, auth_type, password) {
    expect_equal(tenant, "test_tenant")
    expect_equal(app, "test_client")
    expect_equal(host, "https://cognitiveservices.azure.com/.default")
    expect_equal(scopes, NULL)
    expect_equal(auth_type, "client_credentials")
    expect_equal(password, "test_secret")
    list(credentials = list(access_token = "new_token"))
  }

  local_mocked_bindings(
    get_graph_login = mock_get_graph_login,
    create_graph_login = mock_create_graph_login,
    .package = "AzureGraph"
  )

  withr::local_envvar(
    AZURE_OPENAI_TENANT_ID = "test_tenant",
    AZURE_OPENAI_CLIENT_ID = "test_client",
    AZURE_OPENAI_CLIENT_SECRET = "test_secret",
    AZURE_OPENAI_SCOPE = "https://cognitiveservices.azure.com/.default"
  )

  expect_no_error(retrieve_azure_token())
})




test_that("retrieve_azure_token checks for AzureGraph installation", {
  mock_check_installed <- function(pkg) {
    expect_equal(pkg, "AzureGraph")
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
