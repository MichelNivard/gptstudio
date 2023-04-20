library(shiny)
library(XML)
library(magrittr)
library(purrr)
library(stringr)

test_html <-
	' <table style="width:100%">
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
	</table>'


makeAttrs <- function(node) {
	attrs <- XML::xmlAttrs(node)
	names(attrs) %>%
		Map(function (name) {
			val <- attrs[[name]]
			paste0(name, ' = ', if (val == "") "NA" else paste0('"', val, '"'))
		}, .)
}

make_attrs_list <- function(node) {
  attrs <- xml2::xml_attrs(node)
  purrr::imap(attrs, \(.x, i){
    paste0(i, ' = ', dplyr::if_else(.x == "", "NA", glue::glue('"{.x}"')))
  })
}

renderNode <- function(node, indent = 0, prefix = FALSE) {
	if (XML::xmlName(node) == "text") {
		txt <- XML::xmlValue(node)
		if (nchar(trimws(txt)) > 0) {
			paste0('"', trimws(txt), '"')
		}
	} else {
		tagName <- if (prefix) paste0("tags$", XML::xmlName(node)) else XML::xmlName(node)
		newIndent <- indent + length(tagName) + 1
		XML::xmlChildren(node) %>%
		  purrr::map(renderNode, indent = newIndent, prefix = prefix) %>%
		  purrr::compact() %>%
			append(makeAttrs(node), after = 0) %>%
			paste(collapse = stringr::str_pad(",\n", width = newIndent, side = c("right"))) %>%
			trimws(which = c("left")) %>%
			paste0(tagName, "(", ., ")")
	}
}

renderNode2 <- function(node, indent = 0, prefix = FALSE) {
	if (xml2::xml_name(node) == "text") {
		txt <- xml2::xml_text(node)
		if (nchar(trimws(txt)) > 0) {
			paste0('"', trimws(txt), '"')
		}
	} else {
		tagName <- if (prefix) paste0("tags$", xml2::xml_name(node)) else xml2::xml_name(node)
		newIndent <- indent + length(tagName) + 1
		xml2::xml_contents(node) %>%
		  purrr::map(renderNode2, indent = newIndent, prefix = prefix) %>%
		  purrr::compact() %>%
			append(make_attrs_list(node), after = 0) %>%
			paste(collapse = stringr::str_pad(",\n", width = newIndent, side = c("right"))) %>%
			trimws(which = c("left")) %>%
			paste0(tagName, "(", ., ")")
	}
}

html2R <- function(htmlStr, prefix = FALSE) {
	htmlStr %>%
    xml2::read_xml(tree) %>%
    xml2::xml_find_first(".") %>%
		# XML::htmlParse() %>%
		# XML::getNodeSet("/html/body/*") %>%
		# `[[`(1) %>%
		renderNode2(prefix = prefix)
}

html2R(test_html) |> cat()


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
