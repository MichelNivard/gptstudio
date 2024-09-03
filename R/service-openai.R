#' Generate text completions using OpenAI's API for Chat
#'
#' @param model The model to use for generating text
#' @param prompt The prompt for generating completions
#' @param api_key The API key for accessing OpenAI's API. By default, the
#'   function will try to use the `OPENAI_API_KEY` environment variable.
#' @param task The task that specifies the API url to use, defaults to
#' "completions" and "chat/completions" is required for ChatGPT model.
#' @param stream Whether to stream the response, defaults to FALSE.
#' @param shiny_session A Shiny session object to send messages to the client
#' @param user_prompt A user prompt to send to the client
#'
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' openai_create_completion(
#'   model = "gpt-4o",
#'   prompt = "Hello world!"
#' )
#' }
#' @export
create_chat_openai <- function(prompt = list(list(role = "user", content = "Hello")),
                               model = "gpt-4o",
                               api_key = Sys.getenv("OPENAI_API_KEY"),
                               task = "chat/completions",
                               stream = FALSE,
                               shiny_session = NULL,
                               user_prompt = NULL) {
  request_body <- list(
    messages = prompt,
    model = model,
    stream = stream
  ) |> purrr::compact()

  query_api_openai(task = task,
                   request_body = request_body,
                   api_key = api_key,
                   stream = stream,
                   shiny_session = shiny_session,
                   user_prompt = user_prompt)
}


request_base_openai <- function(task, api_key = Sys.getenv("OPENAI_API_KEY")) {
  if (!task %in% get_available_endpoints()) {
    cli::cli_abort(message = c(
      "{.var task} must be a supported endpoint",
      "i" = "Run {.run gptstudio::get_available_endpoints()} to get a list of supported endpoints"
    ))
  }
  request(getOption("gptstudio.openai_url")) |>
    req_url_path_append(task) |>
    req_auth_bearer_token(token = api_key)
}

query_api_openai <- function(task,
                             request_body,
                             api_key = Sys.getenv("OPENAI_API_KEY"),
                             stream = FALSE,
                             shiny_session = NULL,
                             user_prompt = NULL) {
  req <- request_base_openai(task, api_key = api_key) |>
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
        # any communication with JS should be handled here!!
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

      # nolint start
      cli::cli_abort(c(
        "x" = "OpenAI API request failed. Error {status} - {description}",
        "i" = "Visit the {.href [OpenAi Error code guidance](https://help.openai.com/en/articles/6891839-api-error-code-guidance)} for more details",
        "i" = "You can also visit the {.href [API documentation](https://platform.openai.com/docs/guides/error-codes/api-errors)}"
      ))
      # nolint end
    }
    results <- resp |> resp_body_json()
    results$choices[[1]]$message$content
  }
}

#' List supported endpoints
#'
#' Get a list of the endpoints supported by gptstudio.
#'
#' @return A character vector
#' @export
#'
#' @examples
#' get_available_endpoints()
get_available_endpoints <- function() {
  c("completions", "chat/completions", "edits", "embeddings", "models")
}

encode_image <- function(image_path) {
  image_file <- file(image_path, "rb")
  image_data <- readBin(image_file, "raw", file.info(image_path)$size)
  close(image_file)
  base64_image <- jsonlite::base64_enc(image_data)
  paste0("data:image/jpeg;base64,", base64_image)
}

create_image_chat_openai <- function(image_path,
                                     prompt = "What is this image?",
                                     model = getOption("gptstudio.model"),
                                     api_key = Sys.getenv("OPENAI_API_KEY"),
                                     task = "chat/completions") {
  image_data <- encode_image(image_path)
  body <- list(
    model = model,
    messages =
      list(
        list(
          role = "user",
          content = list(
            list(
              type = "text",
              text = prompt
            ),
            list(
              type = "image_url",
              image_url = list(url = image_data)
            )
          )
        )
      )
  )
  query_api_openai(
    task = task,
    request_body = body,
    api_key = api_key
  )
}
