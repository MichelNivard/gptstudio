read_docs <- function(user_prompt) {
  calls <- locate_double_colon_calls(user_prompt)

  if (length(calls) == 0) {
    return()
  }

  documentation <- calls %>%
    purrr::map(function(x) read_html_docs(x$pkg_ref, x$topic))

  inner_text <- documentation %>%
    purrr::map(docs_get_inner_text)

  purrr::map2(calls, inner_text, ~ c(.x, list(inner_text = .y)))
}


read_html_docs <- function(pkg_ref, topic_name) {
  # This should output a scalar character
  file_location <- utils::help(topic = (topic_name), package = (pkg_ref), help_type = "html") %>%
    as.character()

  if (rlang::is_empty(file_location)) {
    return()
  }

  env <- rlang::new_environment()

  file_location %>%
    get_help_file_path() %>%
    lazyLoad(envir = env)

  env[[topic_name]] %>%
    tools::Rd2HTML() %>%
    utils::capture.output() %>%
    paste0(collapse = "\n") %>%
    rvest::read_html()
}

get_help_file_path <- function(file) {
  path <- dirname(file)
  dirpath <- dirname(path)
  if (!file.exists(dirpath)) {
    stop(gettextf("invalid %s argument", sQuote("file")),
      domain = NA
    )
  }
  pkgname <- basename(dirpath)
  file.path(path, pkgname)
}


docs_get_inner_text <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

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
    format = sections[["Format"]], # only data
    value = sections[["Value"]], # only functions
    examples = sections[["Examples"]] # only functions
  )
}

docs_get_sections <- function(children) {
  h3_locations <- children %>%
    purrr::map_lgl(~ rvest::html_name(.x) == "h3") %>%
    which()

  inner_texts <- children %>%
    purrr::map_chr(rvest::html_text2)

  section_ranges <- h3_locations %>%
    purrr::imap(function(.x, i) {
      begin <- h3_locations[i] + 1
      end <- integer()
      item_is_the_last_h3 <- i == length(h3_locations)

      if (item_is_the_last_h3) {
        end <- length(children)
      } else {
        end <- h3_locations[i + 1] - 1
      }

      list(begin = begin, end = end)
    })

  section_ranges %>%
    purrr::map(~ inner_texts[.x$begin:.x$end] %>% paste0(collapse = "\n\n")) %>% # nolint
    purrr::set_names(inner_texts[h3_locations])
}

locate_double_colon_calls <- function(x) {
  all_matches <- x %>%
    stringr::str_extract_all("`?\\b\\w+::(\\w|\\.)+\\b`?")

  all_matches[[1]] %>%
    stringr::str_remove_all("`") %>%
    stringr::str_split("::") %>%
    purrr::map(~ list(pkg_ref = .x[1], topic = .x[2]))
}

docs_to_message <- function(x) {
  inner_content <- x$inner_text %>%
    purrr::compact() %>%
    purrr::imap_chr(function(.x, i) {
      if (i == "title") {
        return(glue::glue("# {.x}"))
      }

      section_title <- stringr::str_to_title(i)
      section_body <- if (i == "examples") glue::glue("<pre>{.x}</pre>") else .x
      glue::glue("## {section_title}\n\n{section_body}")
    }) %>%
    paste0(collapse = "\n\n")

  glue::glue("gptstudio-metadata-docs-start-{x$pkg_ref}-{x$topic}-gptstudio-metadata-docs-end{inner_content}") # nolint
}

add_docs_messages_to_history <- function(skeleton_history) {
  last_user_message <- skeleton_history[[length(skeleton_history)]]$content
  docs <- read_docs(last_user_message)

  if (is.null(docs)) {
    return(skeleton_history)
  }

  purrr::walk(docs, ~ {
    if (is.null(.x$inner_text)) {
      return(NULL)
    }
    skeleton_history <<- chat_history_append(
      history = skeleton_history,
      role = "user",
      content = docs_to_message(.x),
      name = "docs"
    )
  })
  skeleton_history
}
