# API checking fails with missing, inactive, or badly formatted key

    Code
      check_api()
    Message <rlang_message>
      Checking API key using OPENAI_API_KEY environment variable...
    Message <cliMessage>
      v API key found and matches the expected format.
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

---

    Code
      check_api()
    Message <rlang_message>
      Checking API key using OPENAI_API_KEY environment variable...
    Message <cliMessage>
      ! OPENAI_API_KEY is not set.

---

    Code
      check_api()
    Message <rlang_message>
      Checking API key using OPENAI_API_KEY environment variable...
    Message <cliMessage>
      x API key not found or is not formatted correctly.
      i Attempted to validate key: <hidden> (too short to obscure)
      i Generate a key at <https://beta.openai.com/account/api-keys>

# API checking works on CI

    Code
      check_api()
    Message <rlang_message>
      Checking API key using OPENAI_API_KEY environment variable...
    Message <cliMessage>
      v API key found and matches the expected format.
      v API key is valid and a simple API call worked.
      i The API is validated once per session.
      The default value for number of tokens per query is 500. This equates to
      approximately $0.01 USD per query. You can increase or decrease the number of
      tokens with the `gptstudio.max_tokens` option. Here is an example to lower the
      max tokens to 100 tokens per query:
      options("gptstudio.max_tokens") = 100

---

    Code
      check_api()
    Message <cliMessage>
      v API already validated in this session.

---

    Code
      check_api()
    Message <cliMessage>
      ! API key has changed. Re-checking API connection.
      v API key found and matches the expected format.
      v API key is valid and a simple API call worked.
      i The API is validated once per session.
      The default value for number of tokens per query is 500. This equates to
      approximately $0.01 USD per query. You can increase or decrease the number of
      tokens with the `gptstudio.max_tokens` option. Here is an example to lower the
      max tokens to 100 tokens per query:
      options("gptstudio.max_tokens") = 100

# API checking works, assumes OPENAI_API_KEY is set

    Code
      check_api()
    Message <rlang_message>
      Checking API key using OPENAI_API_KEY environment variable...
    Message <cliMessage>
      v API key found and matches the expected format.
      v API key is valid and a simple API call worked.
      i The API is validated once per session.
      The default value for number of tokens per query is 500. This equates to
      approximately $0.01 USD per query. You can increase or decrease the number of
      tokens with the `gptstudio.max_tokens` option. Here is an example to lower the
      max tokens to 100 tokens per query:
      options("gptstudio.max_tokens") = 100

---

    Code
      check_api()
    Message <cliMessage>
      v API already validated in this session.

---

    Code
      check_api()
    Message <cliMessage>
      ! API key has changed. Re-checking API connection.
      v API key found and matches the expected format.
      x API key found but call was unsuccessful.
      i Attempted to use API key: 38a5****************************2d60

# API key validation works

    Code
      check_api_key(sample_key)
    Message <cliMessage>
      v API key found and matches the expected format.

---

    Code
      check_api_key("1234")
    Message <cliMessage>
      x API key not found or is not formatted correctly.
      i Attempted to validate key: <hidden> (too short to obscure)
      i Generate a key at <https://beta.openai.com/account/api-keys>

---

    Code
      check_api_key("")
    Message <cliMessage>
      ! OPENAI_API_KEY is not set.

# API connection checking works

    Code
      check_api_connection(sample_key)
    Message <cliMessage>
      v API key found and matches the expected format.
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
    Message <cliMessage>
      v API key found and matches the expected format.
      v API key is valid and a simple API call worked.
      i The API is validated once per session.
      The default value for number of tokens per query is 500. This equates to
      approximately $0.01 USD per query. You can increase or decrease the number of
      tokens with the `gptstudio.max_tokens` option. Here is an example to lower the
      max tokens to 100 tokens per query:
      options("gptstudio.max_tokens") = 100

