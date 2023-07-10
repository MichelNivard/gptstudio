
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gptstudio <img src="man/figures/logo.png" align="right" height="98"/>

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/gptstudio)](https://CRAN.R-project.org/package=gptstudio)
[![Codecov test
coverage](https://codecov.io/gh/MichelNivard/gptstudio/branch/main/graph/badge.svg)](https://app.codecov.io/gh/MichelNivard/gptstudio?branch=main)
[![R-CMD-check](https://github.com/MichelNivard/gptstudio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MichelNivard/gptstudio/actions/workflows/R-CMD-check.yaml)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/gptstudio)](https://www.r-pkg.org:443/pkg/gptstudio)
<!-- badges: end -->

The goal of gptstudio is for R programmers to easily incorporate use of
large language models (LLMs) into their project workflows. These models
appear to be a step change in our use of text for knowledge work, but
you should carefully consider ethical implications of using these
models. Ethics of LLMs (also called [Foundation
Models](https://arxiv.org/abs/2108.07258)) is an area of very active
discussion.

For further addins, tailored for R developers, also see the sister
package: [gpttools](https://jameshwade.github.io/gpttools/)

## Install the addins from this package:

``` r
install.packages("gptstudio")
```

To get a bug fix or to use a feature from the development version, you
can install the development version of this package from GitHub.

``` r
# install.packages("pak")
pak::pak("MichelNivard/gptstudio")
```

## Privacy Notice for gptstudio

This privacy notice is applicable to the R package that utilizes the
GPT-3 and GPT-3.5 API provided by OpenAI. By using this package, you
agree to adhere to the privacy terms and conditions set by OpenAI.

### Data Sharing with OpenAI

When using this R package, the text or code that you highlight/select
with your cursor, or the prompt you enter within the built-in
applications, will be sent to OpenAI as part of an API request. This
data sharing is governed by the privacy notice, rules, and exceptions
that you agreed to with OpenAI when creating an account.

### Security and Data Usage by OpenAI

We cannot guarantee the security of the data you send to OpenAI via the
API, nor can we provide details on how OpenAI processes or uses your
data. However, OpenAI has stated that they utilize prompts and results
to enhance their AI models, as outlined in their terms of use. You can
opt-out of this data usage by contacting OpenAI directly and making an
explicit request.

### Limiting Data Sharing

The R package is designed to share only the text or code that you
specifically highlight/select or include in a prompt through our
built-in applications. No other elements of your R environment will be
shared. It is your responsibility to ensure that you do not accidentally
share sensitive data with OpenAI.

**IMPORTANT: To maintain the privacy of your data, do not highlight,
include in a prompt, or otherwise upload any sensitive data, code, or
text that should remain confidential.**

## Prerequisites

1.  Make an OpenAI account.

2.  [Create an OpenAI API
    key](https://platform.openai.com/account/api-keys) to use with the
    package.

3.  Set the API key up in Rstudio

### Configuring OpenAI API Key

To interact with the OpenAI API, it’s required to have a valid
`OPENAI_API_KEY` environment variable. Here are the steps to configure
it.

You can establish this environment variable globally by including it in
your project’s .Renviron file. This approach ensures that the
environment variable persists across all sessions as the Shiny app runs
in the background.

Here is a set of commands to open the .Renviron file for modification:

``` r
require(usethis)
edit_r_environ()
```

If you wish to set the variable temporarily for a single session, use
this command, substituting `"<APIKEY>"` with your actual OpenAI API key:

``` r
Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
```

For a persistent setting that loads every time you launch this project,
add the following line to .Renviron, replacing `"<APIKEY>"` with your
actual API key:

``` bash
OPENAI_API_KEY="<APIKEY>"
```

**Caution:** If you’re using version control systems like GitHub or
GitLab, remember to include .Renviron in your .gitignore file to prevent
exposing your API key!

**Important Note:** OpenAI API will not function without valid payment
details entered into your OpenAI account. This is a restriction imposed
by OpenAI and is unrelated to this package.

## Usage

Some examples of use.

### ChatGPT in RStudio

1.  **Addins \> gptstudio \> ChatGPT**
2.  Type your question.
3.  Click “Send” button or press “Enter”
4.  Ask more questions
5.  Copy and try code

<video src="https://user-images.githubusercontent.com/6314313/252512856-7f677852-f2c8-4d7c-a2b6-ca909caaa142.mov" data-canonical-src="https://user-images.githubusercontent.com/6314313/252512856-7f677852-f2c8-4d7c-a2b6-ca909caaa142.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 border-top width-fit" style="max-height:640px; min-height: 200px">
</video>

The ChatGPT addin supports internationalization. You can set the
“GPTSTUDIO_LANGUAGE” environmental variable to the language of your
preference (i.e. `GPTSTUDIO_LANGUAGE="es"` for spanish). See the full
list of supported languages in the translation file
(`"inst/translations/translation.json"`).

#### Using Other Models

We’re excited to announce that our service now includes models from
HuggingFace’s inference API, Anthropic’s claude models, and Google’s
MakerSuite, and Azure OpenAI service broadening the range of AI
solutions you can use. You can set the model using the setting (gear)
button in the ChatGPT addin app.

<video src="https://user-images.githubusercontent.com/6314313/252512899-c45e4711-2197-4849-a5c1-4925355a1369.mov" data-canonical-src="https://user-images.githubusercontent.com/6314313/252512899-c45e4711-2197-4849-a5c1-4925355a1369.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 border-top width-fit" style="max-height:640px; min-height: 200px">
</video>

#### Persistent User Settings & Custom Prompt

You can now save your app settings across sessions. These are saved in a
user config file. The easiest way to change these settings is the “Save
as Default” button in the add-in app. This also allows you to specify
your own custom prompt to pass to the model as instructions.

<video src="https://user-images.githubusercontent.com/6314313/252512933-5965b70c-4d58-4b82-aa67-7e2baf10660c.mov" data-canonical-src="https://user-images.githubusercontent.com/6314313/252512933-5965b70c-4d58-4b82-aa67-7e2baf10660c.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 border-top width-fit" style="max-height:640px; min-height: 200px">
</video>

### Provide your own instructions in R, R Markdown, or Quarto files

**Addins \> GPTSTUDIO \> ChatGPT in Source:** Apply any edit what YOU
desire or can dream up to a selection of code or text.

<video src="https://user-images.githubusercontent.com/6314313/225774578-72e4e966-a740-4afc-beca-1ac25abb504c.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 border-top width-fit" style="max-height:640px; min-height: 200px">
</video>

### Spelling ang grammar check

**Addins \> GPTSTUDIO \> Spelling and Grammar:** Takes the selected text
sends it to OpenAI’s best model and instructs it to return a spelling
and grammar checked version.

<figure>
<img
src="https://raw.githubusercontent.com/MichelNivard/gptstudio/main/media/spelling.gif"
alt="spelling" />
<figcaption aria-hidden="true">spelling</figcaption>
</figure>

### Comment your code:

**Addins \> GPTSTUDIO \> Comment your code:** Takes the selected text
sends it to OpenAI as a prompt for a code specific model to work with,
asks for a version with a comment added explaining the code line by
line.

<figure>
<img
src="https://raw.githubusercontent.com/MichelNivard/gptstudio/main/media/comments.gif"
alt="add comments to code" />
<figcaption aria-hidden="true">add comments to code</figcaption>
</figure>

## Azure OpenAI Service

To configure gptstudio to work using Azure OpenAI service, you need to
provide some configuration details in your .Renviron file. Specifically,
gptstudio looks for five environment variables:

- AZURE_OPENAI_TASK
- AZURE_OPENAI_ENDPOINT
- AZURE_OPENAI_DEPLOYMENT_NAME
- AZURE_OPENAI_KEY
- AZURE_OPENAI_API_VERSION

Here’s how you can add these details to your .Renviron file:

1.  Locate your .Renviron file with `usethis::edit_r_environ()`.
2.  Add environment variable details: Add a new line for each variable
    you need to set in the following format: VARIABLE_NAME=“YOUR_VALUE”.
    Replace VARIABLE_NAME with the name of the environment variable and
    YOUR_VALUE with the actual value that you want to set. For example,
    to set the API key you would have a line like this:

``` bash
AZURE_OPENAI_KEY="your_actual_key_goes_here"
```

You need to do this for each of the environment variables expected by
the function. Your .Renviron file should look something like this:

``` bash
AZURE_OPENAI_TASK="your_task_code"
AZURE_OPENAI_ENDPOINT="your_endpoint_url"
AZURE_OPENAI_DEPLOYMENT_NAME="your_deployment_name"
AZURE_OPENAI_KEY="your_api_key"
AZURE_OPENAI_API_VERSION="your_api_version"
```

3.  Save and Close .Renviron: After adding your environment variables,
    save your .Renviron file and close it. You will need to restart your
    R session to make sure the new environment variables are loaded
    properly.

Remember to replace your_task_code, your_endpoint_url,
your_deployment_name, your_api_key, and your_api_version with your
actual Azure OpenAI details. You can retrieve these details from your
Azure OpenAI service account. For more information about Azure OpenAI
configuration, refer to the [Microsoft quickstart
guide](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/quickstart?tabs=command-line&pivots=rest-api).

## Code of Conduct

Please note that the gptstudio project is released with a [Contributor
Code of
Conduct](https://github.com/MichelNivard/gptstudio/blob/main/.github/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
