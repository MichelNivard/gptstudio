# Set allowed models by provider

**\[experimental\]**

Sometimes it is useful to restrict the list of options in the model
selection dropdown of the chat app. This function will check against
[`get_available_models()`](get_available_models.md) to restrict the list
to models that are actually available.

## Usage

``` r
set_allowed_models(service, models = NULL)
```

## Arguments

- service:

  The API service

- models:

  A character vector containing the list of allowed models that should
  be shown in the dropdown selector. If `NULL` (default), all models
  will be available.
