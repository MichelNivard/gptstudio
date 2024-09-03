#' Generate text using Azure OpenAI's API
#'
#' @description Use this function to generate text completions using Azure OpenAI's API.
#'
#' @param prompt A list of messages to use as the prompt for generating completions.
#'   Each message should be a list with 'role' and 'content' elements.
#' @param model A character string for the model to use. Defaults to the Azure OpenAI
#'   deployment name from environment variables if not specified.
#' @param api_key A character string for the API key. It will default to the Azure
#'   OpenAI API key from your environment variables if not specified.
#' @param task A character string for the API task. Defaults to "chat/completions".
#' @param stream Whether to stream the response, defaults to FALSE.
#' @param shiny_session A Shiny session object to send messages to the client
#' @param user_prompt A user prompt to send to the client
#' @param base_url A character string for the base url. It defaults to the Azure
#'   OpenAI endpoint from environment variables if not specified.
#' @param api_version A character string for the API version. It defaults to
#'   the Azure OpenAI API version from your environment variables if not specified.
#'
#' @return A list with the generated completions and other information returned
#'   by the API
#'
#' @export
create_chat_azure_openai <- function(prompt = list(list(role = "user", content = "Hello")),
                                     model = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
                                     api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
                                     task = "chat/completions",
                                     stream = FALSE,
                                     shiny_session = NULL,
                                     user_prompt = NULL,
                                     base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
                                     api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")) {
  request_body <- list(
    messages = prompt,
    model = model,
    stream = stream
  ) |> purrr::compact()

  query_api_azure_openai(
    task = task,
    request_body = request_body,
    base_url = base_url,
    deployment_name = model,
    api_key = api_key,
    api_version = api_version,
    stream = stream,
    shiny_session = shiny_session,
    user_prompt = user_prompt
  )
}

request_base_azure_openai <-
  function(task,
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
  function(task,
           request_body,
           base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
           deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
           api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
           api_version = Sys.getenv("AZURE_OPENAI_API_VERSION"),
           stream = FALSE,
           shiny_session = NULL,
           user_prompt = NULL) {
    req <- request_base_azure_openai(
      task,
      base_url,
      deployment_name,
      api_key,
      api_version
    ) |>
      req_body_json(data = request_body) |>
      req_retry(max_tries = 3) |>
      req_error(is_error = function(resp) FALSE)

    if (is_true(stream)) {
      resp <- req |> req_perform_connection(mode = "text")
      on.exit(close(resp))
      results <- list()
      repeat({
        event <- resp_stream_sse(resp)
        if (is.null(event) || event$data == "[DONE]") {
          break
        }
        json <- jsonlite::parse_json(event$data)
        results <- merge_dicts(results, json)
        if (!is.null(shiny_session)) {
          shiny_session$sendCustomMessage(
            type = "render-stream",
            message = list(
              user = user_prompt,
              assistant = shiny::markdown(results$choices[[1]]$delta$content)
            )
          )
        } else {
          cat(json$choices[[1]]$delta$content)
        }
      })
      invisible(results$choices[[1]]$delta$content)
    } else {
      resp <- req |> req_perform()
      if (resp_is_error(resp)) {
        status <- resp_status(resp)
        description <- resp_status_desc(resp)
        cli::cli_abort(c(
          "x" = "Azure OpenAI API request failed. Error {status} - {description}",
          "i" = "Visit the {.href [Azure OpenAI Error code guidance](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/reference#error-codes)} for more details" # nolint
        ))
      }
      results <- resp |> resp_body_json()
      results$choices[[1]]$message$content
    }
  }

retrieve_azure_token <- function() {
  rlang::check_installed("AzureRMR")

  token <- tryCatch(
    {
      AzureRMR::get_azure_login(
        tenant = Sys.getenv("AZURE_OPENAI_TENANT_ID"),
        app = Sys.getenv("AZURE_OPENAI_CLIENT_ID"),
        scopes = ".default"
      )
    },
    error = function(e) NULL
  )

  if (is.null(token)) {
    token <- AzureRMR::create_azure_login(
      tenant = Sys.getenv("AZURE_OPENAI_TENANT_ID"),
      app = Sys.getenv("AZURE_OPENAI_CLIENT_ID"),
      password = Sys.getenv("AZURE_OPENAI_CLIENT_SECRET"),
      host = "https://cognitiveservices.azure.com/",
      scopes = ".default"
    )
  }

  invisible(token$token$credentials$access_token)
}
