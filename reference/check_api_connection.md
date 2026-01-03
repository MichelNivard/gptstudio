# Check API Connection

This generic function checks the API connection for a specified service
by dispatching to related methods.

## Usage

``` r
check_api_connection(service, api_key = "", model = NULL)
```

## Arguments

- service:

  The name of the API service for which the connection is being checked.

- api_key:

  The API key used for authentication.

- model:

  The service's model to check

## Value

A logical value indicating whether the connection was successful.
