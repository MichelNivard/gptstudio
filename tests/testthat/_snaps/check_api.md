# API checking fails with inactive key

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

# API checking fails with missing key

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

# API checking fails with badly formatted key

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

# API checking works on CI

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

# API checking works, assumes OPENAI_API_KEY is set

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api()
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

# API key validation works

    Code
      check_api_key(sample_key)
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api_key("1234")
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

---

    Code
      check_api_key("")
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

# API connection checking works

    Code
      check_api_connection(sample_key)
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

---

    Code
      check_api_connection("")
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

# API connection can return true

    Code
      check_api_connection(Sys.getenv("OPENAI_API_KEY"))
    Message
      ! OPENAI_API_KEY is not valid.
      i Generate a key at <https://platform.openai.com/account/api-keys>
      i Set the key in your .Renviron file `usethis::edit_r_environ()`

