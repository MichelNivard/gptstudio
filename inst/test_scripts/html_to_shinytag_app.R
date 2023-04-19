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

makeAttrs <- function(node) {
	attrs <- XML::xmlAttrs(node)
	names(attrs) %>%
		Map(function (name) {
			val <- attrs[[name]]
			paste0(name, ' = ', if (val == "") "NA" else paste0('"', val, '"'))
		}, .)
}

Keep <- function(fun, xs) Map(fun, xs) %>% Filter(Negate(is.null), .)

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
			Keep(purrr::partial(renderNode, indent = newIndent, prefix = prefix), .) %>%
			append(makeAttrs(node), .) %>%
			paste(collapse = stringr::str_pad(",\n", width = newIndent, side = c("right"))) %>%
			trimws(which = c("left")) %>%
			paste0(tagName, "(", ., ")")
	}
}

html2R <- function(htmlStr, prefix = FALSE) {
	htmlStr %>%
		XML::htmlParse() %>%
		XML::getNodeSet("/html/body/*") %>%
		`[[`(1) %>%
		renderNode(prefix = prefix)
}

server <- function(input, output, session) {
	
	rcode <- eventReactive(input$convert, {
		html2R(input$html, prefix = input$prefix)
	}, ignoreInit = TRUE)
	
	output$rCode <- renderText(rcode())
}

shinyApp(ui, server)