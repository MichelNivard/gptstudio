test_that("html_to_taglist() works", {
  test_html_1 <-
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
  test_html_2 <-
    '
  <div class="bs-dropdown" data-toggle>
    <img src="here">
    <div>Hello</div>
  </div>
  '
  test_shinytags_1 <-
    htmltools::tagList(
      htmltools::tags$table(
        `style` = "width:100%",
        htmltools::tags$tr(
          htmltools::tags$th("Firstname"),
          htmltools::tags$th("Lastname"),
          htmltools::tags$th("Age")
        ),
        htmltools::tags$tr(
          htmltools::tags$td("Jill"),
          htmltools::tags$td("Smith"),
          htmltools::tags$td("50")
        )
      )
    )

  test_shinytags_2 <-
    htmltools::tagList(
      htmltools::tags$div(
        `class` = "bs-dropdown",
        `data-toggle` = "",
        htmltools::tags$img(`src` = "here"),
        htmltools::tags$div("Hello"),
      )
    )

  test_html_1 |>
    html_to_taglist() |>
    expect_equal(test_shinytags_1)

  test_html_2 |>
    html_to_taglist() |>
    expect_equal(test_shinytags_2)
})
