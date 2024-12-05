#' a function that determines the appropriate directory to cache a token
#' @export
gptstudio_cache_directory = function(){
  tools::R_user_dir(package = "gptstudio")
}
