#' Welcome message
#'
#' HTML widget for showing a welcome message in the chat app.
#' This has been created to be able to bind the message to a shiny event to trigger a new render.
#'
#' @import htmlwidgets
#' @inheritParams run_chatgpt_app
#' @inheritParams welcomeMessage-shiny
#' @inheritParams chat_message_default
#' @param element_id The element's id
welcomeMessage <- function(ide_colors = get_ide_theme_info(), # nolint
                           translator = create_translator(),
                           width = NULL,
                           height = NULL,
                           element_id = NULL) {
  default_message <- chat_message_default(translator = translator)

  # forward options using x
  x <- list(
    message = style_chat_message(default_message, ide_colors = ide_colors) %>% as.character()
  )

  # create widget
  htmlwidgets::createWidget(
    name = "welcomeMessage",
    x,
    width = width,
    height = height,
    package = "gptstudio",
    elementId = element_id
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
welcomeMessageOutput <- function(outputId, width = "100%", height = NULL) { # nolint
  htmlwidgets::shinyWidgetOutput(outputId, "welcomeMessage", width, height, package = "gptstudio")
}

#' @rdname welcomeMessage-shiny
renderWelcomeMessage <- function(expr, env = parent.frame(), quoted = FALSE) { # nolint
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(expr, welcomeMessageOutput, env, quoted = TRUE)
}





#' Default chat message
#' @inheritParams mod_chat_ui
#' @return A default chat message for welcoming users.
chat_message_default <- function(translator = create_translator()) {
  # nolint start
  welcome_messages <- c(
    "Welcome to the R programming language! I'm here to assist you in your journey, no matter your skill level.",
    "Hello there! Whether you're a beginner or a seasoned R user, I'm here to help.",
    "Hi! I'm your virtual assistant for R. Don't be afraid to ask me anything, I'm here to make your R experience smoother.",
    "Greetings! As an R virtual assistant, I'm here to help you achieve your coding goals, big or small.",
    "Welcome aboard! As your virtual assistant for R, I'm here to make your coding journey easier and more enjoyable.",
    "Nice to meet you! I'm your personal R virtual assistant, ready to answer your questions and provide support.",
    "Hi there! Whether you're new to R or an experienced user, I'm here to assist you in any way I can.",
    "Hello! As your virtual assistant for R, I'm here to help you overcome any coding challenges you might face.",
    "Welcome to the world of R! I'm your virtual assistant, here to guide you through the process of mastering this powerful language.",
    "Hey! I'm your personal R virtual assistant, dedicated to helping you become the best R programmer you can be.",
    "Greetings and welcome! I'm here to assist you on your R journey, no matter where you're starting from.",
    "Hi, I'm your R virtual assistant! My goal is to help you achieve success in your coding endeavors, whatever they may be.",
    "Hello and welcome! As your virtual assistant for R, I'm here to make your coding experience more efficient and productive.",
    "Hey there! I'm your personal R virtual assistant, ready to help you take your coding skills to the next level.",
    "Greetings! Whether you're a beginner or an experienced R user, I'm here to provide support and assistance.",
    "Hello and welcome to R! I'm your virtual assistant, and I'm excited to help you on your coding journey.",
    "Hey! I'm here to help you with all things R, no matter what your skill level is.",
    "Greetings and salutations! As your R virtual assistant, I'm here to provide the guidance and support you need to succeed.",
    "Welcome to the wonderful world of R! I'm your personal virtual assistant, ready to assist you in your coding journey.",
    "Hi there! Whether you're just starting out or a seasoned R user, I'm here to help you reach your coding goals.",
    "Hello and welcome to R! I'm your virtual assistant, and I'm here to help you navigate this powerful language with ease.",
    "Hey! I'm your personal R virtual assistant, and I'm dedicated to helping you achieve success in your coding endeavors.",
    "Greetings! As your virtual assistant for R, I'm here to help you become a confident and proficient R user.",
    "Welcome to the R community! I'm your virtual assistant, and I'm here to support you every step of the way.",
    "Hi there! I'm your personal R virtual assistant, and I'm committed to helping you achieve your coding goals."
  ) %>%
    purrr::map_chr(~ translator$t(.x))

  # nolint end

  content <- c(
    "{sample(welcome_messages, 1)}\n\n",
    translator$t("Type anything to start our conversation.")
  ) %>%
    glue::glue_collapse() %>%
    glue::glue()


  list(
    role = "assistant",
    content = content
  )
}
