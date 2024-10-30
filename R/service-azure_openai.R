#' Generate text using Azure OpenAI's API
#'
#' @description Use this function to generate text completions using OpenAI's
#'   API.
#'
#' @param prompt a list to use as the prompt for generating
#'   completions
#' @param task a character string for the API task (e.g. "completions").
#' Defaults to the Azure OpenAI
#'   task from environment variables if not specified.
#' @param base_url a character string for the base url. It defaults to the Azure
#'   OpenAI endpoint from environment variables if not specified.
#' @param deployment_name a character string for the deployment name. It will
#'   default to the Azure OpenAI deployment name from environment variables if
#'   not specified.
#' @param api_key a character string for the API key. It will default to the Azure
#'   OpenAI API key from your environment variables if not specified.
#' @param api_version a character string for the API version. It will default to
#'   the Azure OpenAI API version from your environment variables if not
#'   specified.
#' @return a list with the generated completions and other information returned
#'   by the API
#'
#' @export
create_completion_azure_openai <-
  function(prompt,
           task = Sys.getenv("AZURE_OPENAI_TASK"),
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")) {
    request_body <- list(list(role = "user", content = prompt))
    query_api_azure_openai(
      task,
      request_body,
      base_url,
      deployment_name,
      api_key,
      api_version
    )
  }

request_base_azure_openai <-
  function(task = Sys.getenv("AZURE_OPENAI_TASK"),
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION"),
           use_token = Sys.getenv("AZURE_OPENAI_USE_TOKEN")) {
    response <-
      request(base_url) |>
      req_url_path_append("openai/deployments") |>
      req_url_path_append(deployment_name) |>
      req_url_path_append(task) |>
      req_url_query("api-version" = api_version)

    if (is_true(as.logical(use_token))) {
      token <- retrieve_azure_token()
      response |>
        req_headers(
          "api-key" = api_key,
          "Content-Type" = "application/json"
        ) |>
        req_auth_bearer_token(token = token)
    } else {
      response |>
        req_headers(
          "api-key" = api_key,
          "Content-Type" = "application/json"
        )
    }
  }

query_api_azure_openai <-
  function(task = Sys.getenv("AZURE_OPENAI_TASK"),
           request_body,
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")) {
    response <-
      request_base_azure_openai(
        task,
        base_url,
        deployment_name,
        api_key,
        api_version
      ) |>
      req_body_json(list(messages = request_body)) |>
      req_retry(max_tries = 3) |>
      req_error(is_error = function(resp) FALSE) |>
      req_perform()

    # error handling
    if (resp_is_error(response)) {
      # nolint start
      status <- resp_status(response)
      description <- resp_status_desc(response)
      cli_abort(message = c(
        "x" = "Azure OpenAI API request failed. Error {status} - {description}",
        "i" = "Visit the {.href [Azure OpenAi Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details",
        "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
      ))
      # nolint end
    }
    response |>
      resp_body_json()
  }

retrieve_azure_token <- function() {
  rlang::check_installed("AzureRMR")

  token <- retrieve_azure_token_object() %>% suppressMessages()

  invisible(token$credentials$access_token)
}


retrieve_azure_token_object <- function() {
  ## Set this so that do_login properly caches
  azure_data_env = Sys.getenv("R_AZURE_DATA_DIR")
  Sys.setenv("R_AZURE_DATA_DIR" = gptstudio_cache_directory())

  client <- Microsoft365R:::do_login(tenant = Sys.getenv("AZURE_OPENAI_TENANT_ID"),
                                     app = Sys.getenv("AZURE_OPENAI_CLIENT_ID"),
                                     host = Sys.getenv("AZURE_OPENAI_SCOPE"),
                                     scopes = NULL,
                                     auth_type = "client_credentials",
                                     password = Sys.getenv("AZURE_OPENAI_CLIENT_SECRET"),
                                     token = NULL)
  ## Set this so that do_login properly caches
  Sys.setenv("R_AZURE_DATA_DIR" = azure_data_env)

  invisible(client$token)
}




stream_azure_openai <- function(messages = list(list(role = "user", content = "hi there")),
                                element_callback = cat) {
  body <- list(
    messages = messages,
    stream = TRUE
  )

  response <-
    request_base_azure_openai() |>
    req_body_json(data = body) |>
    req_retry(max_tries = 3) |>
    req_error(is_error = function(resp) FALSE) |>
    req_perform_stream(
      callback = \(x) {
        element <- rawToChar(x)
        element_callback(element)
        TRUE
      },
      round = "line"
    )

  invisible(response)
}


