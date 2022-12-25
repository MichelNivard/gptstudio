# GPTstudio
GPT addins for Rstudio

## Instalation

1. make and openai.com account (free one will do for now)

2. generate an API key to use openai from Rstudio: https://beta.openai.com/account/api-keys

3. set the Apikey uyp in Rstudion in one of two ways:

By default, functions of openai will look for OPENAI_API_KEY environment variable. If you want to set a global environment variable, you can use the following command (where xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx should be replaced with your actual key):

```
Sys.setenv(
    OPENAI_API_KEY = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
)
```

Otherwise, you can add the key to the .Renviron file of the project. The following commands will open .Renviron for editing:

```
if (!require(usethis))
    install.packages("usethis")

usethis::edit_r_environ(scope = "project")
You can add the following line to the file (again, replace xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx with your actual key):


OPENAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Note: If you are using GitHub/Gitlab, do not forget to add .Renviron to .gitignore!

Finally, you can always provide the key manually to the functions of the package.

