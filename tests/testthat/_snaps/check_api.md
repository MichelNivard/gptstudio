# API checking fails with missing, inactive, or badly formatted key

    Code
      check_api()
    Message <cliMessage>
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

---

    Code
      check_api()
    Message <cliMessage>
      ! OPENAI_API_KEY is not set.

---

    Code
      check_api()
    Message <cliMessage>
      x API key not found or is not formatted correctly.Attempted to validate key: <hidden> (too short to obscure)Generate a key at <https://platform.openai.com/account/api-keys>

# API checking works on CI

    Code
      check_api()

---

    Code
      check_api()

---

    Code
      check_api()

# API checking works, assumes OPENAI_API_KEY is set

    Code
      check_api()

---

    Code
      check_api()

---

    Code
      check_api()
    Message <cliMessage>
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

# API key validation works

    Code
      check_api_key(sample_key)

---

    Code
      check_api_key("1234")
    Message <cliMessage>
      x API key not found or is not formatted correctly.Attempted to validate key: <hidden> (too short to obscure)Generate a key at <https://platform.openai.com/account/api-keys>

---

    Code
      check_api_key("")
    Message <cliMessage>
      ! OPENAI_API_KEY is not set.

# API connection checking works

    Code
      check_api_connection(sample_key)
    Message <cliMessage>
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

---

    Code
      check_api_connection("")
    Message <cliMessage>
      ! OPENAI_API_KEY is not set.

# API connection can return true

    Code
      check_api_connection(Sys.getenv("OPENAI_API_KEY"))

# set_openai_api_key handles valid and invalid API keys

    Code
      set_openai_api_key()
    Message <cliMessage>
      v API key is valid.Setting OPENAI_API_KEY environment variable.You can set this variable in your .Renviron file.

---

    Code
      set_openai_api_key()
    Message <cliMessage>
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60
      x API key is invalid.Get key from <https://platform.openai.com/account/api-keys>

# ask_to_set_api handles different user responses

    Code
      ask_to_set_api()

---

    Code
      ask_to_set_api()

---

    Code
      ask_to_set_api()

