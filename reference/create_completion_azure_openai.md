# Generate text using Azure OpenAI's API

Use this function to generate text completions using OpenAI's API.

## Usage

``` r
create_completion_azure_openai(
  prompt,
  task = Sys.getenv("AZURE_OPENAI_TASK"),
  base_url = Sys.getenv("AZURE_OPENAI_ENDPOINT"),
  deployment_name = Sys.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
  api_key = Sys.getenv("AZURE_OPENAI_API_KEY"),
  api_version = Sys.getenv("AZURE_OPENAI_API_VERSION")
)
```

## Arguments

- prompt:

  a list to use as the prompt for generating completions

- task:

  a character string for the API task (e.g. "completions"). Defaults to
  the Azure OpenAI task from environment variables if not specified.

- base_url:

  a character string for the base url. It defaults to the Azure OpenAI
  endpoint from environment variables if not specified.

- deployment_name:

  a character string for the deployment name. It will default to the
  Azure OpenAI deployment name from environment variables if not
  specified.

- api_key:

  a character string for the API key. It will default to the Azure
  OpenAI API key from your environment variables if not specified.

- api_version:

  a character string for the API version. It will default to the Azure
  OpenAI API version from your environment variables if not specified.

## Value

a list with the generated completions and other information returned by
the API
