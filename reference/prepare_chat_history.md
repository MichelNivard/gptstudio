# Prepare chat completion prompt

This function prepares the chat completion prompt to be sent to the
OpenAI API. It also generates a system message according to the given
parameters and inserts it at the beginning of the conversation.

## Usage

``` r
prepare_chat_history(
  history = list(list(role = "system", content = "You are an R chat assistant")),
  style = getOption("gptstudio.code_style"),
  skill = getOption("gptstudio.skill"),
  task = getOption("gptstudio.task", "coding"),
  custom_prompt = NULL
)
```

## Arguments

- history:

  A list of previous messages in the conversation. This can include
  roles such as 'system', 'user', or 'assistant'. System messages are
  discarded. Default is NULL.i

- style:

  The style of code to use. Applicable styles can be retrieved from the
  "gptstudio.code_style" option. Default is the "gptstudio.code_style"
  option. Options are "base", "tidyverse", or "no preference".

- skill:

  The skill level of the user for the chat conversation. This can be set
  through the "gptstudio.skill" option. Default is the "gptstudio.skill"
  option. Options are "beginner", "intermediate", "advanced", and
  "genius".

- task:

  Specifies the task that the assistant will help with. Default is
  "coding". Others are "general", "advanced developer", and "custom".

- custom_prompt:

  This is a custom prompt that may be used to guide the AI in its
  responses. Default is NULL. It will be the only content provided to
  the system prompt.

## Value

A list where the first entry is an initial system message followed by
any non-system entries from the chat history.
