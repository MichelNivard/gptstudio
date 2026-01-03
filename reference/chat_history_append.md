# Append to chat history

This appends a new response to the chat history

## Usage

``` r
chat_history_append(history, role, content, name = NULL)
```

## Arguments

- history:

  List containing previous responses.

- role:

  Author of the message. One of `c("user", "assistant")`

- content:

  Content of the message. If it is from the user most probably comes
  from an interactive input.

- name:

  Name for the author of the message. Currently used to support
  rendering of help pages

## Value

list of chat messages
