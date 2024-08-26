#' Parse a Data URI
#'
#' This function parses a data URI and returns the MIME type and decoded data.
#'
#' @param data_uri A string. The data URI to parse.
#'
#' @return A list with two elements: 'mime_type' and 'data'.
#'
parse_data_uri <- function(data_uri) {
  if (is.null(data_uri) || !is.character(data_uri) || length(data_uri) != 1) {
    cli::cli_abort("Invalid input: data_uri must be a single character string")
  }

  match <- regexec("^data:(.+);base64,(.*)$", data_uri)
  if (match[[1]][1] == -1) {
    cli::cli_abort("Invalid data URI format")
  }
  groups <- regmatches(data_uri, match)[[1]]
  mime_type <- groups[2]
  b64data <- groups[3]
  # Add padding if necessary
  padding <- nchar(b64data) %% 4
  if (padding > 0) {
    b64data <- paste0(b64data, strrep("=", 4 - padding))
  }
  list(mime_type = mime_type, data = jsonlite::base64_dec(b64data))
}

#' Transcribe Audio from Data URI Using OpenAI's Whisper Model
#'
#' This function takes an audio file in data URI format, converts it to WAV, and
#' sends it to OpenAI's transcription API to get the transcribed text.
#'
#' @param audio_input A string. The audio data in data URI format.
#' @param api_key A string. Your OpenAI API key. Defaults to the OPENAI_API_KEY
#'   environment variable.
#'
#' @return A string containing the transcribed text.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' audio_uri <- "data:audio/webm;base64,SGVsbG8gV29ybGQ=" # Example data URI
#' transcription <- transcribe_audio(audio_uri)
#' print(transcription)
#' }
#'
transcribe_audio <- function(audio_input, api_key = Sys.getenv("OPENAI_API_KEY")) {
  parsed <- parse_data_uri(audio_input)

  temp_webm <- tempfile(fileext = ".webm")
  temp_wav <- tempfile(fileext = ".wav")
  writeBin(parsed$data, temp_webm)
  system_result <- # nolint
    system2("ffmpeg",
      args = c("-i", temp_webm, "-acodec", "pcm_s16le", "-ar", "44100", temp_wav), # nolint
      stdout = TRUE,
      stderr = TRUE
    )

  if (!file.exists(temp_wav)) {
    cli::cli_abort("Failed to convert audio: {system_result}")
  }

  req <- request("https://api.openai.com/v1/audio/transcriptions") %>%
    req_auth_bearer_token(api_key) %>%
    req_body_multipart(
      file = curl::form_file(temp_wav),
      model = "whisper-1",
      response_format = "text"
    )

  resp <- req_perform(req)

  if (resp_is_error(resp)) {
    cli::cli_abort("API request failed: {resp_status_desc(resp)}")
  }

  user_prompt <- resp_body_string(resp)
  file.remove(temp_webm, temp_wav)
  invisible(user_prompt)
}
