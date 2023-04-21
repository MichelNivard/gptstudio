library(shiny)
library(gptstudio)

test_html <-
  '
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
  	</table>
  '
# this works in console but not in app
format_r_code_str <- function(code_str){
  code_str |>
    stringr::str_replace_all("(\\()([a-z[:symbol:]])", "\\1\n\\2") |> # new line after parenthesis or opening backtick
    stringr::str_replace_all("(,)", "\\1\n") |> # newline after comma
    styler::style_text()
}

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
	  input$html |>
	    html_to_r() |>
	    format_r_code_str()
	}, ignoreInit = TRUE)

	output$rCode <- renderText(rcode())
}

shinyApp(ui, server)
