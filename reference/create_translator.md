# Internationalization for the ChatGPT addin

The language can be set via
`options("gptstudio.language" = "<language>")` (defaults to "en").

## Usage

``` r
create_translator(language = getOption("gptstudio.language"))
```

## Arguments

- language:

  The language to be found in the translation JSON file.

## Value

A Translator from
[`shiny.i18n::Translator`](https://appsilon.github.io/shiny.i18n/reference/Translator.html)
