# Current Configuration for gptstudio

This function prints out the current configuration settings for
gptstudio and checks API connections if verbose is TRUE.

## Usage

``` r
gptstudio_sitrep(verbose = TRUE)
```

## Arguments

- verbose:

  Logical value indicating whether to output additional information,
  such as API connection checks. Defaults to TRUE.

## Value

Invisibly returns NULL, as the primary purpose of this function is to
print to the console.

## Examples

``` r
if (FALSE) { # \dontrun{
gptstudio_sitrep(verbose = FALSE) # Print basic settings, no API checks
gptstudio_sitrep() # Print settings and check API connections
} # }
```
