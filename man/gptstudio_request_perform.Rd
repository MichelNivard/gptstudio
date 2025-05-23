% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_perform_request.R
\name{gptstudio_request_perform}
\alias{gptstudio_request_perform}
\title{Perform API Request}
\usage{
gptstudio_request_perform(skeleton, shiny_session = NULL)
}
\arguments{
\item{skeleton}{A \code{gptstudio_request_skeleton} object}

\item{shiny_session}{Shiny session to send messages to. Only relevant if skeleton$stream is TRUE.}
}
\value{
A list with a skeleton and and the last response
}
\description{
This function provides a wrapper for calling different APIs
(e.g., OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
calls to the relevant ellmer chat.
}
