% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/service-openai_api_calls.R
\name{openai_create_chat_completion}
\alias{openai_create_chat_completion}
\title{Generate text completions using OpenAI's API for Chat}
\usage{
openai_create_chat_completion(
  prompt = "<|endoftext|>",
  model = getOption("gptstudio.model"),
  openai_api_key = Sys.getenv("OPENAI_API_KEY"),
  task = "chat/completions"
)
}
\arguments{
\item{prompt}{The prompt for generating completions}

\item{model}{The model to use for generating text}

\item{openai_api_key}{The API key for accessing OpenAI's API. By default, the
function will try to use the \code{OPENAI_API_KEY} environment variable.}

\item{task}{The task that specifies the API url to use, defaults to
"completions" and "chat/completions" is required for ChatGPT model.}
}
\value{
A list with the generated completions and other information returned
by the API.
}
\description{
Generate text completions using OpenAI's API for Chat
}
\examples{
\dontrun{
openai_create_completion(
  model = "text-davinci-002",
  prompt = "Hello world!"
)
}
}
