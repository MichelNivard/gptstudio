# Transcribe Audio from Data URI Using OpenAI's Whisper Model

This function takes an audio file in data URI format, converts it to
WAV, and sends it to OpenAI's transcription API to get the transcribed
text.

## Usage

``` r
transcribe_audio(audio_input, api_key = Sys.getenv("OPENAI_API_KEY"))
```

## Arguments

- audio_input:

  A string. The audio data in data URI format.

- api_key:

  A string. Your OpenAI API key. Defaults to the OPENAI_API_KEY
  environment variable.

## Value

A string containing the transcribed text.

## Examples

``` r
if (FALSE) { # \dontrun{
audio_uri <- "data:audio/webm;base64,SGVsbG8gV29ybGQ=" # Example data URI
transcription <- transcribe_audio(audio_uri)
print(transcription)
} # }
```
