# Run GPTStudio Chat App

This function initializes and runs the Chat GPT Shiny App as a
background job in RStudio and opens it in the viewer pane or browser
window.

## Usage

``` r
gptstudio_chat(host = getOption("shiny.host", "127.0.0.1"))
```

## Arguments

- host:

  A character string specifying the host on which to run the app.
  Defaults to the value of `getOption("shiny.host", "127.0.0.1")`.

## Value

This function does not return a value. It runs the Shiny app as a side
effect.

## Details

The function performs the following steps:

1.  Verifies that RStudio API is available.

2.  Finds an available port for the Shiny app.

3.  Creates a temporary directory for the app files.

4.  Runs the app as a background job in RStudio.

5.  Opens the app in the RStudio viewer pane or browser window.

## Note

This function is designed to work within the RStudio IDE and requires
the rstudioapi package.

## Examples

``` r
if (FALSE) { # \dontrun{
gptstudio_chat()
} # }
```
