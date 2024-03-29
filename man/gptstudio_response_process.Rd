% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_process_response.R
\name{gptstudio_response_process}
\alias{gptstudio_response_process}
\title{Call API}
\usage{
gptstudio_response_process(skeleton, ...)
}
\arguments{
\item{skeleton}{A \code{gptstudio_response_skeleton} object}

\item{...}{Extra arguments, not currently used}
}
\value{
A \code{gptstudio_request_skeleton} with updated history and prompt removed
}
\description{
This function provides a generic interface for calling different APIs
(e.g., OpenAI, HuggingFace, Google AI Studio). It dispatches the actual API
calls to the relevant method based on the \code{class} of the \code{skeleton} argument.
}
\examples{
\dontrun{
gptstudio_response_process(gptstudio_skeleton)
}
}
