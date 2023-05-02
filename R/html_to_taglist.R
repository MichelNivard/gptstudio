#' Convert HTML to a Tag List
#'
#' This function takes a character string of HTML code and returns a tag list
#' that can be used to display the HTML content in an R Markdown document or
#' Shiny app. The resulting tag list can be passed as an argument to the
#' `htmltools::tagQuery()` function or used as an input to other HTML rendering
#' functions in R.
#'
#' @param html A character string of HTML code
#' @return A tag list that can be used to display the HTML content
#' @export
html_to_taglist <- function(html) {
  text <- html %>% html_to_r()
  parse(text = text) %>% eval()
}


#' Convert HTML to R Code
#'
#' This function takes a character string of HTML code and returns a styled R
#' code that can be used to recreate the HTML structure. The resulting R code is
#' a character string that can be copied and pasted into an R script or console.
#'
#' @param html A character string of HTML code
#' @return A character string of styled R code that can be used to recreate the
#'   HTML structure
#' @export
html_to_r <- function(html) {
  html %>%
    html_str_to_nodeset() %>%
    purrr::map(get_node_params) %>%
    purrr::map_chr(node_params_to_str) %>%
    glue::glue_collapse(sep = ", ") %>%
    into_taglist()
}

#' HTML string to xml nodeset
#'
#' This function takes HTML defined as a string and returns it as a xml_nodeset.
#'
#' @param str A character string that represents the HTML to be parsed
#' @return A nodeset representing the parsed HTML
html_str_to_nodeset <- function(str) {
  str %>%
    xml2::read_html() %>%
    xml2::xml_find_all("./body/*")
}


node_is_text <- function(node) xml2::xml_name(node) == "text"

node_text_is_empty <- function(node) xml2::xml_text(node, trim = TRUE) == ""

node_content_is_nodeset <- function(node) {
  "xml_nodeset" %in% class(node$contents)
}

node_content_is_empty <- function(node) length(node$content) == 0

#' Get Nodeset Tag Contents
#'
#' This function takes a nodeset and returns the contents of each tag.
#'
#' @param nodeset A nodeset representing a parsed HTML document
#' @return A character vector containing the contents of each tag in the nodeset
get_nodeset_tag_contents <- function(nodeset) {
  nodeset %>%
    xml2::xml_contents() %>%
    purrr::discard(\(node) node_is_text(node) && node_text_is_empty(node))
}


#' Get Node Parameters
#'
#' This function takes a node and returns a list with its name, attributes, and
#' contents. This functions applies recursively to every element of its contents
#' until the element is plain text or has no extra content.
#'
#' @param node A node representing an element or text node in a parsed HTML
#'   document
#' @return A list with the name, attributes, and contents of the node
#'
get_node_params <- function(node) {
  if (node_is_text(node)) {
    list(
      name = "text",
      attrs = xml2::xml_attrs(node),
      contents = xml2::xml_text(node)
    )
  } else {
    node_with_params <- list(
      name = xml2::xml_name(node),
      attrs = xml2::xml_attrs(node),
      contents = get_nodeset_tag_contents(node)
    )
    if (node_content_is_nodeset(node_with_params) &&
        !node_content_is_empty(node_with_params)) {
      node_with_params$contents <- node_with_params$contents %>%
        purrr::map(get_node_params)
    }
    node_with_params
  }
}


#' Convert Attributes to Parameters
#'
#' This function takes a named character vector representing attributes and
#' returns a character string that can be used as a parameter list in an HTML
#' tag.
#'
#' @param attrs A named character vector representing attributes
#' @return A character string that can be used as a parameter list in an HTML
#'   tag
attrs_to_params <- function(attrs) {
  if (length(attrs) == 0) {
    return("")
  }
  params_names <- names(attrs)
  params_values <- unname(attrs)
  params <- glue::glue("`{params_names}` = \"{params_values}\"")
  glue::glue_collapse(params, ", ")
}


#' Convert Node Parameters to String
#'
#' This function takes a list of parameters for an HTML tag and returns a
#' character string that represents the tag with the given parameters. Aplies
#' recursively to every child content until content is text or empty.
#'
#' @param node_params A list of parameters for an HTML tag
#' @return A character string that represents the tag with the given parameters
#'
node_params_to_str <- function(node_params) {
  if (node_params$name == "text") {
    safe_text <- gsub("'", "\\\\'", node_params$contents)
    glue::glue("'{safe_text}'")
  } else {
    tag_name <- glue::glue("htmltools::tags${node_params$name}")
    params <- attrs_to_params(node_params$attrs)
    if (node_params$name == "code") {
      params = c(params, '.noWS="outside"')
    }
    contents <- node_params$contents
    if (length(contents) > 0) {
      contents <- contents %>%
        purrr::map_chr(node_params_to_str) %>%
        glue::glue_collapse(sep = ", ")
    } else {
      contents <- ""
    }
    fun_args <- c(params, contents)
    fun_args <- fun_args[fun_args != ""]
    fun_args <- paste(fun_args, collapse = ", ")
    glue::glue("{tag_name}({fun_args})")
  }
}


#' Paste tags string inside a tagList
#'
#' This function takes a list of HTML tags and returns a character string that,
#' when evaluated, will produce a tagList object containing the given tags.
#'
#' @param tags_str A list of HTML tags
#' @return A character string that, when evaluated, will produce a tagList
#'   object containing the given tags
into_taglist <- function(tags_str) {
  glue::glue("htmltools::tagList({tags_str})")
}
