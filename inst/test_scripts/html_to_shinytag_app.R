library(magrittr)

test_html_1 <-
	'
  <div>
    <table style="width:100%">
  	  <tr>
  	    <th>Firstname</th>
  	    <th>Lastname</th>
  	    <th>Age</th>
  	  </tr>
  	  <tr>
  	    <td>Jill</td>
  	    <td>Smith</td>
  	    <td>50</td>
  	  </tr>
  	  <tr>
  	    <td>Eve</td>
  	    <td>Jackson</td>
  	    <td>94</td>
  	  </tr>
  	</table>
  </div>
  '
test_html_2 <-
	'
  <div class="bs-dropdown" data-toggle>
  <img src="here">
  <div>Hello</div>
    <table style="width:100%">
  	  <tr>
  	    <th>Firstname</th>
  	    <th>Lastname</th>
  	    <th>Age</th>
  	  </tr>
  	  <tr>
  	    <td>Jill</td>
  	    <td>Smith</td>
  	    <td>50</td>
  	  </tr>
  	  <tr>
  	    <td>Eve</td>
  	    <td>Jackson</td>
  	    <td>94</td>
  	  </tr>
  	</table>
  </div>
  '


make_attrs_list <- function(node) {
  attrs <- xml2::xml_attrs(node)
  purrr::imap(attrs, \(.x, i){
    paste0(i, ' = ', dplyr::if_else(.x == "", "NA", glue::glue('"{.x}"')))
  })
}

render_node <- function(node, indent = 0, prefix = FALSE) {
	if (xml2::xml_name(node) == "text") {
		# txt <- xml2::xml_text(node)
		# if (nchar(trimws(txt)) > 0) {
		# 	paste0('"', trimws(txt), '"')
		# }
	  render_text(node)
	} else {
		tagName <- if (prefix) paste0("tags$", xml2::xml_name(node)) else xml2::xml_name(node)
		newIndent <- indent + length(tagName) + 1
		xml2::xml_contents(node) %>%
		  purrr::map(render_node, indent = newIndent, prefix = prefix) %>%
		  purrr::compact() %>%
			append(make_attrs_list(node), after = 0) %>%
			paste(collapse = stringr::str_pad(",\n", width = newIndent, side = c("right"))) %>%
			trimws(which = c("left")) %>%
			paste0(tagName, "(", ., ")")
		  # identity()
	}
}

render_text <- function(node) {
  txt <- xml2::xml_text(node)
  if (nchar(trimws(txt)) > 0) {
    paste0('"', trimws(txt), '"')
  }
}


html2R <- function(htmlStr, prefix = FALSE) {
	htmlStr %>%
    xml2::read_xml(tree) %>%
    xml2::xml_find_first(".") %>%
		render_node(prefix = prefix)
}

'<div>Hello</div>' |>
  xml2::read_html() |>
  xml2::xml_find_all("./body/*") |>
  purrr::map(xml2::xml_contents)

get_nodeset_from_string <- function(str) {
  str |>
    xml2::read_html() |>
    xml2::xml_find_all("./body/*")
}

node_is_text <- function(node) xml2::xml_name(node) == "text"

node_text_is_empty <- function(node) xml2::xml_text(node, trim = TRUE) == ""

content_is_nodeset <- function(node) "xml_nodeset" %in% class(node$contents)

content_is_empty <- function(node) length(node$content) == 0

get_nodeset_tag_contents <- function(nodeset) {
  nodeset |>
    xml2::xml_contents() |>
    purrr::discard(\(node) node_is_text(node) && node_text_is_empty(node))
}

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
    if (content_is_nodeset(node_with_params) && !content_is_empty(node_with_params)) {
      node_with_params$contents <- node_with_params$contents |>
        purrr::map(get_node_params)
    }
    node_with_params
  }
}

node_params_to_str <- function(node_params) {
  if (node_params$name == "text") {
    node_params$contents
  } else {
    tag_name <- glue::glue("htmltools::tags${node_params$name}")
    params_collapsed <- attrs_to_params(node_params$attrs)
    contents <- node_params$contents
    if (length(contents) > 0) {
      contents <- contents |>
        purrr::map_chr(node_params_to_str)
      contents <- paste0(", ", contents)
    } else {
      contents <- ""
    }
    glue::glue("{tag_name}({params_collapsed}{contents})")
  }
}

attrs_to_params <- function(attrs) {
  if (length(attrs) == 0) return("")
  params_names <- names(attrs)
  params_values <- unname(attrs)
  params <- glue::glue("`{params_names}` = \"{params_values}\"")
  glue::glue_collapse(params, ", ")
}

fake_nodeset <- list()
class(fake_nodeset) <- c("xml_nodeset", class(fake_nodeset))

list(
  name = "div",
  attrs = c(class = "card"),
  contents = list(
    list(
      name = "div",
      attrs = c(class = "card-header", "data-toggle" = "yes"),
      contents = list(
        list(
          name = "div",
          attrs = character(),
          contents = fake_nodeset
        )
      )
    )
  )
) |>
  node_params_to_str()

test_html_2 |>
  get_nodeset_from_string() |>
  purrr::map(get_node_params) |>
  node_params_to_str()
  identity()

ui <- fluidPage(
  titlePanel("HTML to R Converter"),
  fluidRow(
    column(5, textAreaInput("html", "HTML", rows=20, value = test_html)
    ),
    column(2, checkboxInput("prefix", "Prefix"), actionButton("convert", "Convert")),
    column(5, tags$pre(textOutput("rCode")))
  ),
  fluidRow(tags$a(href = "https://github.com/alandipert/html2r", "Github"))
)

server <- function(input, output, session) {

	rcode <- eventReactive(input$convert, {
		html2R(input$html, prefix = input$prefix)
	}, ignoreInit = TRUE)

	output$rCode <- renderText(rcode())
}

shinyApp(ui, server)
