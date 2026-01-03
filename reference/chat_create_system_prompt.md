# Create system prompt

This function creates a customizable system prompt based on user-defined
parameters such as coding style, skill level, and task. It supports
customization for specific use cases through a custom prompt option.

## Usage

``` r
chat_create_system_prompt(
  style = getOption("gptstudio.code_style"),
  skill = getOption("gptstudio.skill"),
  task = getOption("gptstudio.task"),
  custom_prompt = getOption("gptstudio.custom_prompt"),
  in_source = FALSE
)
```

## Arguments

- style:

  A character string indicating the preferred coding style. Valid values
  are "tidyverse", "base", "no preference". Defaults to
  `getOption(gptstudio.code_style)`.

- skill:

  The self-described skill level of the programmer. Valid values are
  "beginner", "intermediate", "advanced", "genius". Defaults to
  `getOption(gptstudio.skill)`.

- task:

  The specific task to be performed: "coding", "general", "advanced
  developer", or "custom". This influences the generated system prompt.
  Defaults to "coding".

- custom_prompt:

  An optional custom prompt string to be utilized when `task` is set to
  "custom". Default is NULL.

- in_source:

  A logical indicating whether the instructions are intended for use in
  a source script. This parameter is required and must be explicitly set
  to TRUE or FALSE. Default is FALSE.

## Value

Returns a character string that forms a system prompt tailored to the
specified parameters. The string provides guidance or instructions based
on the user's coding style, skill level, and task.

## Examples

``` r
if (FALSE) { # \dontrun{
chat_create_system_prompt(in_source = TRUE)
chat_create_system_prompt(
  style = "tidyverse",
  skill = "advanced",
  task = "coding",
  in_source = FALSE
)
} # }
```
