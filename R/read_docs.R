read_docs <- function(user_prompt) {
  calls <- locate_double_colon_calls(user_prompt)

  if (length(calls) == 0) return()

  documentation <- calls %>%
    purrr::map(function(x) read_html_docs(x$pkg_ref, x$topic))

  inner_text <- documentation %>%
    purrr::map(docs_get_inner_text)

  purrr::map2(calls, inner_text, ~c(.x, list(inner_text = .y)))
}


read_html_docs <- function(pkg_ref, topic_name) {
  # This should output a scalar character
  file_location <- help(topic = (topic_name), package = (pkg_ref), help_type = "html") %>%
    as.character()

  if (rlang::is_empty(file_location)) return()

  env <- rlang::new_environment()

  file_location %>%
    get_help_file_path() %>%
    lazyLoad(envir = env)

  #################
  # This is an alternative way to read the help but
  # requires writing to disk first

  # tmp <- tempfile(fileext = ".html")
  # tools::Rd2HTML(Rd = env[[topic_name]], out = tmp)
  # rvest::read_html(tmp)
  ##################

  env[[topic_name]] %>%
    tools::Rd2HTML() %>%
    capture.output() %>%
    paste0(collapse = "\n") %>%
    rvest::read_html()
}

get_help_file_path <- function (file) {
  path <- dirname(file)
  dirpath <- dirname(path)
  if (!file.exists(dirpath))
    stop(gettextf("invalid %s argument", sQuote("file")),
         domain = NA)
  pkgname <- basename(dirpath)
  file.path(path, pkgname)
}


docs_get_inner_text <- function(x) {
  if(is.null(x)) return(NULL)

  main_container <- x %>%
    rvest::html_element("body") %>%
    rvest::html_element(".container")

  title <- main_container %>%
    rvest::html_element("h2") %>%
    rvest::html_text()

  sections <- main_container %>%
    rvest::html_children() %>%
    docs_get_sections()

  list(
    title = title, # all
    description = sections[["Description"]], # all
    usage = sections[["Usage"]], # all
    arguments = sections[["Arguments"]], # only functions
    examples = sections[["Examples"]], # only functions
    value = sections[["Value"]], # only functions
    format = sections[["Format"]] # only data
  )

}

docs_get_sections <- function(children) {
  h3_locations <- children %>%
    purrr::map_lgl(~rvest::html_name(.x) == "h3") %>%
    which()

  inner_texts <- children %>%
    purrr::map_chr(rvest::html_text2)

  section_ranges <- h3_locations %>%
    purrr::imap(function(.x, i){
      begin <- h3_locations[i] + 1
      end <- integer()
      item_is_the_last_h3 <- i == length(h3_locations)

      if (item_is_the_last_h3) {
        end <- length(children)
      } else {
        end <- h3_locations[i+1] - 1
      }

      list(begin = begin, end = end)
    })

  section_ranges %>%
    purrr::map(~inner_texts[.x$begin:.x$end] %>% paste0(collapse = "\n\n")) %>%
    purrr::set_names(inner_texts[h3_locations])
}

locate_double_colon_calls <- function(x) {
  all_matches <- x %>%
    stringr::str_extract_all("`?\\b\\w+::(\\w|\\.)+\\b`?")

  all_matches[[1]] %>%
    stringr::str_remove_all("`") %>%
    stringr::str_split("::") %>%
    purrr::map(~list(pkg_ref = .x[1], topic = .x[2]))
}
