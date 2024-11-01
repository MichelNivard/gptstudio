#' a function that determines the appropriate directory to cache a token
#' @export
gptstudio_cache_directory = function(){
  rappdirs::user_data_dir(appname = glue::glue("gptstudio"),
                          appauthor = "",
                          roaming = FALSE)
}
