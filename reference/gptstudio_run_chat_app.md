# Run the ChatGPT app

This starts the chatgpt app. It is exported to be able to run it from an
R script.

## Usage

``` r
gptstudio_run_chat_app(
  ide_colors = get_ide_theme_info(),
  code_theme_url = get_highlightjs_theme(),
  host = getOption("shiny.host", "127.0.0.1"),
  port = getOption("shiny.port")
)
```

## Arguments

- ide_colors:

  List containing the colors of the IDE theme.

- code_theme_url:

  URL to the highlight.js theme

- host:

  The IPv4 address that the application should listen on. Defaults to
  the `shiny.host` option, if set, or `"127.0.0.1"` if not. See Details.

- port:

  The TCP port that the application should listen on. If the `port` is
  not specified, and the `shiny.port` option is set (with
  `options(shiny.port = XX)`), then that port will be used. Otherwise,
  use a random port between 3000:8000, excluding ports that are blocked
  by Google Chrome for being considered unsafe: 3659, 4045, 5060, 5061,
  6000, 6566, 6665:6669 and 6697. Up to twenty random ports will be
  tried.

## Value

Nothing.
