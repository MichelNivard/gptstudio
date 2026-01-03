# Create a Request Skeleton

This function dynamically creates a request skeleton for different AI
text generation services.

## Usage

``` r
gptstudio_create_skeleton(
  service = "openai",
  prompt = "Name the top 5 packages in R.",
  history = list(list(role = "system", content = "You are an R chat assistant")),
  stream = TRUE,
  model = "gpt-4o-mini",
  ...
)
```

## Arguments

- service:

  The text generation service to use. Currently supports "openai",
  "huggingface", "anthropic", "google", "azure_openai", "ollama", and
  "perplexity".

- prompt:

  The initial prompt or question to pass to the text generation service.

- history:

  A list indicating the conversation history, where each element is a
  list with elements "role" (who is speaking; e.g., "system", "user")
  and "content" (what was said).

- stream:

  Logical; indicates if streaming responses should be used. Currently,
  this option is not supported across all services.

- model:

  The specific model to use for generating responses. Defaults to
  "gpt-3.5-turbo".

- ...:

  Additional arguments passed to the service-specific skeleton creation
  function.

## Value

Depending on the selected service, returns a list that represents the
configured request ready to be passed to the corresponding API.

## Examples

``` r
if (FALSE) { # \dontrun{
request_skeleton <- gptstudio_create_skeleton(
  service = "openai",
  prompt = "Name the top 5 packages in R.",
  history = list(list(role = "system", content = "You are an R assistant")),
  stream = TRUE,
  model = "gpt-3.5-turbo"
)
} # }
```
