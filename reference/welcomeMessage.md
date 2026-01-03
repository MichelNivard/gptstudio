# Welcome message

HTML widget for showing a welcome message in the chat app. This has been
created to be able to bind the message to a shiny event to trigger a new
render.

## Usage

``` r
welcomeMessage(
  ide_colors = get_ide_theme_info(),
  translator = create_translator(),
  width = NULL,
  height = NULL,
  element_id = NULL
)
```

## Arguments

- ide_colors:

  List containing the colors of the IDE theme.

- translator:

  A Translator from
  [`shiny.i18n::Translator`](https://appsilon.github.io/shiny.i18n/reference/Translator.html)

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- element_id:

  The element's id
