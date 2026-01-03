# Perform API Request

This function provides a wrapper for calling different APIs (e.g.,
OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
calls to the relevant ellmer chat.

## Usage

``` r
gptstudio_request_perform(skeleton, shiny_session = NULL)
```

## Arguments

- skeleton:

  A `gptstudio_request_skeleton` object

- shiny_session:

  Shiny session to send messages to. Only relevant if skeleton\$stream
  is TRUE.

## Value

A list with a skeleton and and the last response
