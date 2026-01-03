# Streaming message

Places an invisible empty chat message that will hold a streaming
message. It can be reset dynamically inside a shiny app

## Usage

``` r
streamingMessage(
  ide_colors = get_ide_theme_info(),
  width = NULL,
  height = NULL,
  element_id = NULL
)
```

## Arguments

- ide_colors:

  List containing the colors of the IDE theme.

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- element_id:

  The element's id
