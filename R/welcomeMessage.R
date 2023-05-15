#' Welcome message
#'
#' HTML widget for showing a welcome message in the chat app.
#' This has been created to be able to bind the message to a shiny event to trigger a new render.
#'
#' @import htmlwidgets
#'
#' @export
welcomeMessage <- function(width = NULL, height = NULL, elementId = NULL) {

  default_message <- chat_message_default()[[1]]

  # forward options using x
  x = list(
    message = style_chat_message(default_message) |> as.character()
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'welcomeMessage',
    x,
    width = width,
    height = height,
    package = 'gptstudio',
    elementId = elementId
  )
}

#' Shiny bindings for welcomeMessage
#'
#' Output and render functions for using welcomeMessage within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a welcomeMessage
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name welcomeMessage-shiny
#'
#' @export
welcomeMessageOutput <- function(outputId, width = '100%', height = NULL){
  htmlwidgets::shinyWidgetOutput(outputId, 'welcomeMessage', width, height, package = 'gptstudio')
}

#' @rdname welcomeMessage-shiny
#' @export
renderWelcomeMessage <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, welcomeMessageOutput, env, quoted = TRUE)
}
