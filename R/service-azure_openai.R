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
#' @param token a character string for the API key. It will default to the Azure
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
           token = Sys.getenv("AZURE_OPENAI_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")) {
    request_body <- list(list(role = "user", content = prompt))
    query_api_azure_openai(
      task,
      request_body,
      base_url,
      deployment_name,
      token,
      api_version
    )
  }

request_base_azure_openai <-
  function(task = Sys.getenv("AZURE_OPENAI_TASK"),
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           token = Sys.getenv("AZURE_OPENAI_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION"),
           use_token = Sys.getenv("AZURE_OPENAI_USE_TOKEN")) {
    response <-
      request(base_url) %>%
      req_url_path_append("openai/deployments") %>%
      req_url_path_append(deployment_name) %>%
      req_url_path_append(task) %>%
      req_url_query("api-version" = api_version) %>%
      req_headers(
        "api-key" = token,
        "Content-Type" = "application/json"
      )

    if (is_true(as.logical(use_token))) {
      token <- retrieve_azure_token()
      response %>% req_auth_bearer_token(token = token)
    } else {
      response
    }
  }

query_api_azure_openai <-
  function(task = Sys.getenv("AZURE_OPENAI_TASK"),
           request_body,
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           token = Sys.getenv("AZURE_OPENAI_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")) {
    response <-
      request_base_azure_openai(
        task,
        base_url,
        deployment_name,
        token,
        api_version
      ) %>%
      req_body_json(list(messages = request_body)) %>%
      req_retry(max_tries = 3) %>%
      req_error(is_error = function(resp) FALSE) %>%
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
    response %>%
      resp_body_json()
  }

retrieve_azure_token <- function() {
  rlang::check_installed("AzureRMR")
  token <- AzureRMR::create_azure_login(
    tenant = Sys.getenv("AZURE_OPENAI_TENANT_ID"),
    app = Sys.getenv("AZURE_OPENAI_CLIENT_ID"),
    password = Sys.getenv("AZURE_OPENAI_CLIENT_SECRET"),
    host = "https://cognitiveservices.azure.com/",
    scopes = ".default"
  )
  invisible(token$token$credentials$access_token)
}
