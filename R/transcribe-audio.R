#' Parse a Data URI
#'
#' This function parses a data URI and returns the MIME type and decoded data.
#'
#' @param data_uri A string. The data URI to parse.
#'
#' @return A list with two elements: 'mime_type' and 'data'.
#'
parse_data_uri <- function(data_uri) {
  match <- regexec("data:(.+);base64,(.+)", data_uri)
  if (match[[1]][1] == -1) {
    stop("Invalid data URI format")
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
#' audio_uri <- "data:audio/webm;base64,SGVsbG8gV29ybGQ="  # Example data URI
#' transcription <- transcribe_audio(audio_uri)
#' print(transcription)
#' }
#'
#' @importFrom httr2 request req_auth_bearer_token req_body_multipart
#'   req_perform resp_is_error resp_status_desc resp_body_json
#' @importFrom jsonlite fromJSON
transcribe_audio <- function(audio_input, api_key = Sys.getenv("OPENAI_API_KEY")) {
  # Parse the data URI
  parsed <- parse_data_uri(audio_input)

  # Convert WebM to WAV (R doesn't have native WebM support, so we're using WAV)
  temp_webm <- tempfile(fileext = ".webm")
  temp_wav <- tempfile(fileext = ".wav")
  writeBin(parsed$data, temp_webm)
  system_result <-
    system2("ffmpeg",
            args = c("-i", temp_webm, "-acodec", "pcm_s16le", "-ar", "44100", temp_wav), #nolint
            stdout = TRUE,
            stderr = TRUE)

  if (!file.exists(temp_wav)) {
    stop("Failed to convert audio: ", paste(system_result, collapse = "\n"))
  }

  # Transcribe audio using OpenAI API
  req <- httr2::request("https://api.openai.com/v1/audio/transcriptions") %>%
    httr2::req_auth_bearer_token(api_key) %>%
    httr2::req_body_multipart(
      file = curl::form_file(temp_wav),
      model = "whisper-1",
      response_format = "text"
    )

  resp <- httr2::req_perform(req)

  if (httr2::resp_is_error(resp)) {
    stop("API request failed: ", httr2::resp_status_desc(resp))
  }

  user_prompt <- resp_body_string(resp)

  # Clean up temporary files
  file.remove(temp_webm, temp_wav)

  invisible(user_prompt)
}


#' Convert Audio File to Data URI
#'
#' This function takes an audio file path and converts it to a data URI.
#'
#' @param file_path A string. The path to the audio file.
#'
#' @return A string containing the data URI.
#'
audio_to_data_uri <- function(file_path) {
  # Read the file
  audio_data <- readBin(file_path, "raw", file.info(file_path)$size)

  # Encode the data
  encoded_data <- jsonlite::base64_enc(audio_data)

  # Get the MIME type
  mime_type <- mime::guess_type(file_path)

  # Construct the data URI
  data_uri <- paste0("data:", mime_type, ";base64,", encoded_data)

  return(data_uri)
}
