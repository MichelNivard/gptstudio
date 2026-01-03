# Chat server

Chat server

## Usage

``` r
mod_chat_server(
  id,
  ide_colors = get_ide_theme_info(),
  translator = create_translator(),
  settings,
  history
)
```

## Arguments

- id:

  id of the module

- ide_colors:

  List containing the colors of the IDE theme.

- translator:

  Translator from
  [`shiny.i18n::Translator`](https://appsilon.github.io/shiny.i18n/reference/Translator.html)

- settings, history:

  Reactive values from the settings and history module
