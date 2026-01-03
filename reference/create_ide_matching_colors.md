# Chat message colors in RStudio

This returns a list of color properties for a chat message

## Usage

``` r
create_ide_matching_colors(
  role = c("user", "assistant"),
  ide_colors = get_ide_theme_info()
)
```

## Arguments

- role:

  The role of the message author

- ide_colors:

  List containing the colors of the IDE theme.

## Value

list
