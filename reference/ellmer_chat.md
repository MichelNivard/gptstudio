# Create Chat Client for Different API Providers

This function provides a generic interface for creating chat clients for
different API providers (e.g., OpenAI, HuggingFace, Google AI Studio).
It dispatches the actual client creation to the relevant method based on
the `class` of the `skeleton` argument.

## Usage

``` r
ellmer_chat(skeleton, all_turns)
```

## Arguments

- skeleton:

  A `gptstudio_request_skeleton` object containing API configuration

- all_turns:

  A list of conversation turns formatted for the ellmer package

## Value

An ellmer chat client object for the specific API provider
