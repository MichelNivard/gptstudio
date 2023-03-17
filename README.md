
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gptstudio <img src="man/figures/logo.png" align="right" height="98"/>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/gptstudio)](https://CRAN.R-project.org/package=gptstudio)
[![Codecov test
coverage](https://codecov.io/gh/MichelNivard/gptstudio/branch/main/graph/badge.svg)](https://app.codecov.io/gh/MichelNivard/gptstudio?branch=main)
[![R-CMD-check](https://github.com/MichelNivard/gptstudio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MichelNivard/gptstudio/actions/workflows/R-CMD-check.yaml)
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
#> Installing package into '/private/var/folders/f0/vt7wqnsn2_108drc_6r2ml040000gn/T/RtmpCACE1Y/temp_libpath6d4f67d20111'
#> (as 'lib' is unspecified)
#> Warning: package 'gptstudio' is not available for this version of R
#> 
#> A version of this package for your version of R might be available elsewhere,
#> see the ideas at
#> https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Installing-packages
```

To get a bug fix or to use a feature from the development version, you
can install the development version of this package from GitHub.

``` r
# install.packages("pak")
pak::pak("MichelNivard/gptstudio")
#> ℹ Loading metadata database
#> ℹ Loading metadata database
#> ✔ Loading metadata database ... done
#> ✔ Loading metadata database ... done
#> 
#>  
#> 
#> → Will install 53 packages.
#> → Will install 53 packages.
#> → Will update 1 package.
#> → Will update 1 package.
#> → Will download 1 package with unknown size.
#> → Will download 1 package with unknown size.
#> + askpass             1.1     
#> + assertthat          0.2.1   
#> + base64enc           0.1-3   
#> + bslib               0.4.2   
#> + cachem              1.0.7   
#> + cli                 3.6.0   
#> + clipr               0.8.0   
#> + commonmark          1.8.1   
#> + crayon              1.5.2   
#> + credentials         1.3.2   
#> + curl                5.0.0   
#> + desc                1.4.2   
#> + digest              0.6.31  
#> + ellipsis            0.3.2   
#> + fastmap             1.1.1   
#> + fontawesome         0.5.0   
#> + fs                  1.6.1   
#> + gert                1.9.2   
#> + gh                  1.4.0   
#> + gitcreds            0.1.2   
#> + glue                1.6.2   
#> + gptstudio   0.0.5 → 0.0.4   👷🏻‍♀️🔧 ⬇ (GitHub: 77e4050)
#> + htmltools           0.5.4   
#> + httpuv              1.6.9   
#> + httr                1.4.5   
#> + httr2               0.2.2   
#> + ini                 0.3.1   
#> + jquerylib           0.1.4   
#> + jsonlite            1.8.4   
#> + later               1.3.0   
#> + lifecycle           1.0.3   
#> + magrittr            2.0.3   
#> + memoise             2.0.1   
#> + mime                0.12    
#> + openssl             2.0.6   
#> + promises            1.2.0.1 
#> + purrr               1.0.1   
#> + R6                  2.5.1   
#> + rappdirs            0.3.3   
#> + Rcpp                1.0.10  
#> + rlang               1.1.0   
#> + rprojroot           2.0.3   
#> + rstudioapi          0.14    
#> + sass                0.4.5   
#> + shiny               1.7.4   
#> + sourcetools         0.1.7-1 
#> + sys                 3.4.1   
#> + usethis             2.1.6   
#> + vctrs               0.5.2   
#> + whisker             0.4.1   
#> + withr               2.5.0   
#> + xtable              1.8-4   
#> + yaml                2.3.7   
#> + zip                 2.2.2   
#> + askpass             1.1     
#> + assertthat          0.2.1   
#> + base64enc           0.1-3   
#> + bslib               0.4.2   
#> + cachem              1.0.7   
#> + cli                 3.6.0   
#> + clipr               0.8.0   
#> + commonmark          1.8.1   
#> + crayon              1.5.2   
#> + credentials         1.3.2   
#> + curl                5.0.0   
#> + desc                1.4.2   
#> + digest              0.6.31  
#> + ellipsis            0.3.2   
#> + fastmap             1.1.1   
#> + fontawesome         0.5.0   
#> + fs                  1.6.1   
#> + gert                1.9.2   
#> + gh                  1.4.0   
#> + gitcreds            0.1.2   
#> + glue                1.6.2   
#> + gptstudio   0.0.5 → 0.0.4   👷🏻‍♀️🔧 ⬇ (GitHub: 77e4050)
#> + htmltools           0.5.4   
#> + httpuv              1.6.9   
#> + httr                1.4.5   
#> + httr2               0.2.2   
#> + ini                 0.3.1   
#> + jquerylib           0.1.4   
#> + jsonlite            1.8.4   
#> + later               1.3.0   
#> + lifecycle           1.0.3   
#> + magrittr            2.0.3   
#> + memoise             2.0.1   
#> + mime                0.12    
#> + openssl             2.0.6   
#> + promises            1.2.0.1 
#> + purrr               1.0.1   
#> + R6                  2.5.1   
#> + rappdirs            0.3.3   
#> + Rcpp                1.0.10  
#> + rlang               1.1.0   
#> + rprojroot           2.0.3   
#> + rstudioapi          0.14    
#> + sass                0.4.5   
#> + shiny               1.7.4   
#> + sourcetools         0.1.7-1 
#> + sys                 3.4.1   
#> + usethis             2.1.6   
#> + vctrs               0.5.2   
#> + whisker             0.4.1   
#> + withr               2.5.0   
#> + xtable              1.8-4   
#> + yaml                2.3.7   
#> + zip                 2.2.2
#> ℹ Getting 1 pkg with unknown size, 53 (41.00 MB) cached
#> ℹ Getting 1 pkg with unknown size, 53 (41.00 MB) cached
#> ✔ Cached copy of gptstudio 0.0.4 (source) is the latest build
#> ✔ Cached copy of gptstudio 0.0.4 (source) is the latest build
#> ✔ Got httr2 0.2.2 (aarch64-apple-darwin20) (376.14 kB)
#> ✔ Got httr2 0.2.2 (aarch64-apple-darwin20) (376.14 kB)
#> ✔ Got sass 0.4.5 (aarch64-apple-darwin20) (2.41 MB)
#> ✔ Got sass 0.4.5 (aarch64-apple-darwin20) (2.41 MB)
#> ✔ Got httpuv 1.6.9 (aarch64-apple-darwin20) (2.74 MB)
#> ✔ Got httpuv 1.6.9 (aarch64-apple-darwin20) (2.74 MB)
#> ✔ Installed R6 2.5.1  (74ms)
#> ✔ Installed R6 2.5.1  (74ms)
#> ✔ Installed askpass 1.1  (121ms)
#> ✔ Installed askpass 1.1  (121ms)
#> ✔ Installed assertthat 0.2.1  (138ms)
#> ✔ Installed assertthat 0.2.1  (138ms)
#> ✔ Installed base64enc 0.1-3  (152ms)
#> ✔ Installed base64enc 0.1-3  (152ms)
#> ✔ Installed cachem 1.0.7  (168ms)
#> ✔ Installed cachem 1.0.7  (168ms)
#> ✔ Installed cli 3.6.0  (186ms)
#> ✔ Installed cli 3.6.0  (186ms)
#> ✔ Installed clipr 0.8.0  (219ms)
#> ✔ Installed clipr 0.8.0  (219ms)
#> ✔ Installed commonmark 1.8.1  (231ms)
#> ✔ Installed commonmark 1.8.1  (231ms)
#> ✔ Installed crayon 1.5.2  (120ms)
#> ✔ Installed crayon 1.5.2  (120ms)
#> ✔ Installed Rcpp 1.0.10  (322ms)
#> ✔ Installed Rcpp 1.0.10  (322ms)
#> ✔ Installed credentials 1.3.2  (83ms)
#> ✔ Installed credentials 1.3.2  (83ms)
#> ✔ Installed bslib 0.4.2  (490ms)
#> ✔ Installed bslib 0.4.2  (490ms)
#> ✔ Installed curl 5.0.0  (222ms)
#> ✔ Installed curl 5.0.0  (222ms)
#> ✔ Installed desc 1.4.2  (182ms)
#> ✔ Installed desc 1.4.2  (182ms)
#> ✔ Installed digest 0.6.31  (42ms)
#> ✔ Installed digest 0.6.31  (42ms)
#> ✔ Installed ellipsis 0.3.2  (65ms)
#> ✔ Installed ellipsis 0.3.2  (65ms)
#> ✔ Installed fastmap 1.1.1  (45ms)
#> ✔ Installed fastmap 1.1.1  (45ms)
#> ✔ Installed fontawesome 0.5.0  (48ms)
#> ✔ Installed fontawesome 0.5.0  (48ms)
#> ✔ Installed fs 1.6.1  (49ms)
#> ✔ Installed fs 1.6.1  (49ms)
#> ✔ Installed gert 1.9.2  (49ms)
#> ✔ Installed gert 1.9.2  (49ms)
#> ✔ Installed gh 1.4.0  (70ms)
#> ✔ Installed gh 1.4.0  (70ms)
#> ✔ Installed gitcreds 0.1.2  (43ms)
#> ✔ Installed gitcreds 0.1.2  (43ms)
#> ✔ Installed glue 1.6.2  (43ms)
#> ✔ Installed glue 1.6.2  (43ms)
#> ✔ Installed htmltools 0.5.4  (45ms)
#> ✔ Installed htmltools 0.5.4  (45ms)
#> ✔ Installed httpuv 1.6.9  (82ms)
#> ✔ Installed httpuv 1.6.9  (82ms)
#> ✔ Installed httr2 0.2.2  (88ms)
#> ✔ Installed httr2 0.2.2  (88ms)
#> ✔ Installed httr 1.4.5  (51ms)
#> ✔ Installed httr 1.4.5  (51ms)
#> ✔ Installed ini 0.3.1  (39ms)
#> ✔ Installed ini 0.3.1  (39ms)
#> ✔ Installed jquerylib 0.1.4  (37ms)
#> ✔ Installed jquerylib 0.1.4  (37ms)
#> ✔ Installed jsonlite 1.8.4  (61ms)
#> ✔ Installed jsonlite 1.8.4  (61ms)
#> ✔ Installed later 1.3.0  (42ms)
#> ✔ Installed later 1.3.0  (42ms)
#> ✔ Installed lifecycle 1.0.3  (42ms)
#> ✔ Installed lifecycle 1.0.3  (42ms)
#> ✔ Installed magrittr 2.0.3  (44ms)
#> ✔ Installed magrittr 2.0.3  (44ms)
#> ✔ Installed memoise 2.0.1  (45ms)
#> ✔ Installed memoise 2.0.1  (45ms)
#> ✔ Installed mime 0.12  (61ms)
#> ✔ Installed mime 0.12  (61ms)
#> ✔ Installed openssl 2.0.6  (56ms)
#> ✔ Installed openssl 2.0.6  (56ms)
#> ✔ Installed promises 1.2.0.1  (61ms)
#> ✔ Installed promises 1.2.0.1  (61ms)
#> ✔ Installed purrr 1.0.1  (44ms)
#> ✔ Installed purrr 1.0.1  (44ms)
#> ✔ Installed rappdirs 0.3.3  (67ms)
#> ✔ Installed rappdirs 0.3.3  (67ms)
#> ✔ Installed rlang 1.1.0  (54ms)
#> ✔ Installed rlang 1.1.0  (54ms)
#> ✔ Installed rprojroot 2.0.3  (47ms)
#> ✔ Installed rprojroot 2.0.3  (47ms)
#> ✔ Installed rstudioapi 0.14  (44ms)
#> ✔ Installed rstudioapi 0.14  (44ms)
#> ✔ Installed sass 0.4.5  (63ms)
#> ✔ Installed sass 0.4.5  (63ms)
#> ✔ Installed sourcetools 0.1.7-1  (35ms)
#> ✔ Installed sourcetools 0.1.7-1  (35ms)
#> ✔ Installed shiny 1.7.4  (138ms)
#> ✔ Installed shiny 1.7.4  (138ms)
#> ✔ Installed sys 3.4.1  (55ms)
#> ✔ Installed sys 3.4.1  (55ms)
#> ✔ Installed usethis 2.1.6  (50ms)
#> ✔ Installed usethis 2.1.6  (50ms)
#> ✔ Installed vctrs 0.5.2  (74ms)
#> ✔ Installed vctrs 0.5.2  (74ms)
#> ✔ Installed whisker 0.4.1  (60ms)
#> ✔ Installed whisker 0.4.1  (60ms)
#> ✔ Installed withr 2.5.0  (42ms)
#> ✔ Installed withr 2.5.0  (42ms)
#> ✔ Installed xtable 1.8-4  (44ms)
#> ✔ Installed xtable 1.8-4  (44ms)
#> ✔ Installed yaml 2.3.7  (41ms)
#> ✔ Installed yaml 2.3.7  (41ms)
#> ✔ Installed zip 2.2.2  (58ms)
#> ✔ Installed zip 2.2.2  (58ms)
#> ℹ Packaging gptstudio 0.0.4
#> ℹ Packaging gptstudio 0.0.4
#> ✔ Packaged gptstudio 0.0.4 (477ms)
#> ✔ Packaged gptstudio 0.0.4 (477ms)
#> ℹ Building gptstudio 0.0.4
#> ℹ Building gptstudio 0.0.4
#> ✔ Built gptstudio 0.0.4 (1.4s)
#> ✔ Built gptstudio 0.0.4 (1.4s)
#> ✔ Installed gptstudio 0.0.4 (github::MichelNivard/gptstudio@77e4050) (66ms)
#> ✔ Installed gptstudio 0.0.4 (github::MichelNivard/gptstudio@77e4050) (66ms)
#> ✔ 1 pkg + 53 deps: upd 1, added 53, dld 3 (5.52 MB) [10.3s]
#> ✔ 1 pkg + 53 deps: upd 1, added 53, dld 3 (5.52 MB) [10.3s]
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

3.  Set the API key up in Rstudio in one of two ways:

- By default, API calls will look for `OPENAI_API_KEY` environment
  variable. If you want to set a global environment variable, you can
  use the following command, where `"<APIKEY>"` should be replaced with
  your actual key:

``` r
Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
```

- Otherwise, you can add the key to the .Renviron file of the project.
  The following commands will open .Renviron for editing:

``` r
require(usethis)
edit_r_environ(scope = "project")
```

You can add the following line to .Renviron (again, replace `"<APIKEY>"`
with your actual key):

``` bash
OPENAI_API_KEY= "<APIKEY>")
```

This now set the API key every time you start up this particular
project. Note: If you are using GitHub/Gitlab, do not forget to add
.Renviron to .gitignore!

## Usage

Some examples of use.

### ChatGPT in RStudio

1.  **Addins \> GPTSTUDIO \> ChatGPT**
2.  Type your question.
3.  \*\*Addins \> GPTSTUDIO \> GPT Chat

<video src="https://user-images.githubusercontent.com/6314313/225774512-bc0b0296-51c6-44a7-b665-e906610bed06.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 width-fit" style="max-height:640px;">
</video>

### Provide your own instructions in R, R Markdown, or Quarto files

**Addins \> GPTSTUDIO \> ChatGPT in Source:** Apply any edit what YOU
desire or can dream up to a selection of code or text.

<video src="https://user-images.githubusercontent.com/6314313/225774578-72e4e966-a740-4afc-beca-1ac25abb504c.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 width-fit" style="max-height:640px;">
</video>

### Spelling ang grammar check

**Addins \> GPTSTUDIO \> Spelling and Grammar:** Takes the selected text
sends it to OpenAI’s best model and instructs it to return a spelling
and grammar checked version.

![spelling](https://raw.githubusercontent.com/MichelNivard/gptstudio/main/media/spelling.gif)

### Comment your code:

**Addins \> GPTSTUDIO \> Comment your code:** Takes the selected text
sends it to OpenAI as a prompt for a code specific model to work with,
asks for a version with a comment added explaining the code line by
line.

![add comments to
code](https://raw.githubusercontent.com/MichelNivard/gptstudio/main/media/comments.gif)

## Code of Conduct

Please note that the gptstudio project is released with a Contributor
Code of Conduct. By contributing to this project, you agree to abide by
its terms.
