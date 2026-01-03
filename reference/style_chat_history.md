# Style Chat History

This function processes the chat history, filters out system messages,
and formats the remaining messages with appropriate styling.

## Usage

``` r
style_chat_history(history, ide_colors = get_ide_theme_info())
```

## Arguments

- history:

  A list of chat messages with elements containing 'role' and 'content'.

- ide_colors:

  List containing the colors of the IDE theme.

## Value

A list of formatted chat messages with styling applied, excluding system
messages.

## Examples

``` r
chat_history_example <- list(
  list(role = "user", content = "Hello, World!"),
  list(role = "system", content = "System message"),
  list(role = "assistant", content = "Hi, how can I help?")
)

if (FALSE) { # \dontrun{
style_chat_history(chat_history_example)
} # }
```
