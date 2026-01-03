# Get IDE Theme Information

Retrieves the current RStudio IDE theme information including whether it
is a dark theme, and the background and foreground colors in hexadecimal
format.

## Usage

``` r
get_ide_theme_info()
```

## Value

A list with the following components:

- is_dark:

  A logical indicating whether the current IDE theme is dark.

- bg:

  A character string representing the background color of the IDE theme
  in hex format.

- fg:

  A character string representing the foreground color of the IDE theme
  in hex format.

If RStudio is unavailable, returns the fallback theme details.

## Examples

``` r
theme_info <- get_ide_theme_info()
print(theme_info)
#> $is_dark
#> [1] TRUE
#> 
#> $bg
#> [1] "#181818"
#> 
#> $fg
#> [1] "#C1C1C1"
#> 
```
