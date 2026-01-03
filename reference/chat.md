# Chat Interface for gptstudio

This function provides a high-level interface for communicating with
various services and models supported by gptstudio. It orchestrates the
creation, configuration, and execution of a request based on user inputs
and options set for gptstudio. The function supports a range of tasks
from text generation to code synthesis and can be customized according
to skill level and coding style preferences.

## Usage

``` r
chat(
  prompt,
  service = getOption("gptstudio.service"),
  history = list(list(role = "system", content = "You are an R chat assistant")),
  stream = FALSE,
  model = getOption("gptstudio.model"),
  skill = getOption("gptstudio.skill"),
  style = getOption("gptstudio.code_style", "no preference"),
  task = getOption("gptstudio.task", "coding"),
  custom_prompt = NULL,
  process_response = FALSE,
  session = NULL,
  ...
)
```

## Arguments

- prompt:

  A string containing the initial prompt or question to be sent to the
  model. This is a required parameter.

- service:

  The AI service to be used for the request. If not explicitly provided,
  this defaults to the value set in `getOption("gptstudio.service")`. If
  the option is not set, make sure to provide this parameter to avoid
  errors.

- history:

  An optional parameter that can be used to include previous
  interactions or context for the current session. Defaults to a system
  message indicating "You are an R chat assistant".

- stream:

  A logical value indicating whether the interaction should be treated
  as a stream for continuous interactions. If not explicitly provided,
  this defaults to the value set in `getOption("gptstudio.stream")`.

- model:

  The specific model to use for the request. If not explicitly provided,
  this defaults to the value set in `getOption("gptstudio.model")`.

- skill:

  A character string indicating the skill or capability level of the
  user. This parameter allows for customizing the behavior of the model
  to the user. If not explicitly provided, this defaults to the value
  set in `getOption("gptstudio.skill")`.

- style:

  The coding style preferred by the user for code generation tasks. This
  parameter is particularly useful when the task involves generating
  code snippets or scripts. If not explicitly provided, this defaults to
  the value set in `getOption("gptstudio.code_style")`.

- task:

  The specific type of task to be performed, ranging from text
  generation to code synthesis, depending on the capabilities of the
  model. If not explicitly provided, this defaults to the value set in
  `getOption("gptstudio.task")`.

- custom_prompt:

  An optional parameter that provides a way to extend or customize the
  initial prompt with additional instructions or context.

- process_response:

  A logical indicating whether to process the model's response.

- session:

  An optional parameter for a shiny session object.

- ...:

  Reserved for future use.

## Value

Depending on the task and processing, the function returns the response
from the model, which could be text, code, or any other structured
output defined by the task and model capabilities. The precise format
and content of the output depend on the specified options and the
capabilities of the selected model.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage with a text prompt:
result <- chat("What is the weather like today?")

# Advanced usage with custom settings, assuming appropriate global options are set:
result <- chat(
  prompt = "Write a simple function in R",
  skill = "advanced",
  style = "tidyverse",
  task = "coding"
)

# Usage with explicit service and model specification:
result <- chat(
  prompt = "Explain the concept of tidy data in R",
  service = "openai",
  model = "gpt-4-turbo-preview",
  skill = "intermediate",
  task = "general"
)
} # }
```
