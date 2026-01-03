# Custom textAreaInput

Modified version of `textAreaInput()` that removes the label container.
It's used in `mod_prompt_ui()`

## Usage

``` r
text_area_input_wrapper(
  inputId,
  label,
  value = "",
  width = NULL,
  height = NULL,
  cols = NULL,
  rows = NULL,
  placeholder = NULL,
  resize = NULL,
  textarea_class = NULL
)
```

## Arguments

- inputId:

  The `input` slot that will be used to access the value.

- label:

  Display label for the control, or `NULL` for no label.

- value:

  Initial value.

- width:

  The width of the input, e.g. `'400px'`, or `'100%'`; see
  [`validateCssUnit()`](https://rstudio.github.io/htmltools/reference/validateCssUnit.html).

- height:

  The height of the input, e.g. `'400px'`, or `'100%'`; see
  [`validateCssUnit()`](https://rstudio.github.io/htmltools/reference/validateCssUnit.html).

- cols:

  Value of the visible character columns of the input, e.g. `80`. This
  argument will only take effect if there is not a CSS `width` rule
  defined for this element; such a rule could come from the `width`
  argument of this function or from a containing page layout such as
  [`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html).

- rows:

  The value of the visible character rows of the input, e.g. `6`. If the
  `height` argument is specified, `height` will take precedence in the
  browser's rendering.

- placeholder:

  A character string giving the user a hint as to what can be entered
  into the control. Internet Explorer 8 and 9 do not support this
  option.

- resize:

  Which directions the textarea box can be resized. Can be one of
  `"both"`, `"none"`, `"vertical"`, and `"horizontal"`. The default,
  `NULL`, will use the client browser's default setting for resizing
  textareas.

- textarea_class:

  Class to be applied to the textarea element

## Value

A modified textAreaInput
