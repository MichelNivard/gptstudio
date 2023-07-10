#' Generate text using Azure OpenAI's API
#'
#' @description Use this function to generate text completions using OpenAI's
#'   API.
#'
#' @param prompt a list to use as the prompt for generating
#'   completions
#' @param task a character string for the API task. Defaults to the Azure OpenAI
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
#' @examples
#' \dontrun{
#' create_completion_azure_openai(
#'   prompt = list(list(role = "user", content = "Hello world!"
#' )
#' }
#'
#' @export
create_completion_azure_openai <- function(prompt,
                                           task = Sys.getenv("AZURE_OPENAI_TASK"),
                                           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
                                           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
                                           token = Sys.getenv("AZURE_OPENAI_KEY"),
                                           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION"))
{
  query_api_azure_openai(task, prompt, base_url, deployment_name, token, api_version)
}

request_base_azure_openai <-
  function(task = Sys.getenv("AZURE_OPENAI_TASK"),
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           token = Sys.getenv("AZURE_OPENAI_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")
  ) {
    httr2::request(base_url) %>%
      httr2::req_url_path_append("openai/deployments") %>%
      httr2::req_url_path_append(deployment_name) %>%
      httr2::req_url_path_append(task) %>%
      httr2::req_url_path_append(api_version) %>%
      httr2::req_headers("api-key" = token,
                         "Content-Type" = "application/json") %>%
      httr2::req_method("POST")
  }

query_api_azure_openai <- function(task = Sys.getenv("AZURE_OPENAI_TASK"),
                                   request_body,
                                   base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
                                   deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
                                   token = Sys.getenv("AZURE_OPENAI_KEY"),
                                   api_version = Sys.getenv("AZURE_OPENAI_API_VERSION"))
{
  response <-
    request_base_azure_openai(task, base_url, deployment_name, token, api_version) %>%
    httr2::req_body_json(request_body) %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_error(is_error = function(resp) FALSE) %>%
    httr2::req_perform()

  # error handling
  if (httr2::resp_is_error(response)) {
    status <- httr2::resp_status(response)
    description <- httr2::resp_status_desc(response)
    cli_abort(message = c(
      "x" = "Azure OpenAI API request failed. Error {status} - {description}",
      "i" = "Visit the {.href [Azure OpenAi Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details",
      "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
    ))
  }
  response %>%
    httr2::resp_body_json()
}
