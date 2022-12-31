#' Collect Dataframes
#'
#' @description Collect all the dataframes in the global environment.
#'
#' @return A character vector of dataframe names.
#'
#' @export
collect_dataframes <- function() {
  objects <- names(rlang::global_env())
  purrr::map_chr(
    .x = objects,
    .f = ~ if (is.data.frame(get(.x))) {
      .x
    } else {
      NA
    }
  ) %>%
    stats::na.omit()
}

skim_lite <- function(data) {
  my_skim <- skimr::skim_with(
    numeric = skimr::sfl(
      min = ~ min(.x),
      mean = ~ mean(.x),
      median = ~ median(.x),
      max = ~ max(.x)
    ),
    append = FALSE
  )
  my_skim(data)
}

collect_column_types <- function(data) {
  purrr::map_dfr(
    names(data),
    ~ data.frame(
      column = .x,
      type = class(data[[.x]])
    )
  )
}

#' Summarize data
#'
#' Summarize a data frame using one of three methods.
#'
#' @param data A data frame
#' @param method A character vector specifying the method to use for summarizing the data.
#'   Must be one of "skimr", "skimr_lite", "column_types", or "summary". Default is "skimr".
#'
#' @return Summarized data according to specified method
summarize_data <- function(data, method = c("skimr", "skimr_lite", "column_types", "summary")) {
  assertthat::assert_that(is.data.frame(data))

  rlang::arg_match(method)

  switch(method[1],
    "skimr" = skimr::skim_without_charts(data),
    "skimr_lite" = skim_lite(data),
    "column_types" = collect_column_types(data),
    "summary" = summary(data)
  )
}



#' @title Preps OpenAI model prompt for data documentation
#' @description
#'   Prepares data prompt by summarizing data and printing it
#'
#' @param data A data.frame
#' @param method A summarization method, one of "skimr", "glimpse", or "summary"
#' @param prompt A prompt string
#' @return A string
#' @export
#' @examples
#' prep_data_prompt(
#'   data = mtcars,
#'   method = "skimr",
#'   prompt = "This is a test prompt."
#' )
prep_data_prompt <- function(data, method, prompt) {
  assertthat::assert_that(is.data.frame(data))
  assertthat::assert_that(assertthat::is.string(prompt))

  summarized_data <- summarize_data(data = data, method = method)

  paste(testthat::capture_output(print(summarized_data)), prompt, sep = "\n")
}
