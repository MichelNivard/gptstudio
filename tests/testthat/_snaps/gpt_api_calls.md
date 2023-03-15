# OpenAI create completion fails with bad key

    Code
      openai_create_completion(model = "text-davinci-003", prompt = "a test prompt",
        openai_api_key = sample_key)
    Message <cliMessage>
      ! OpenAI API request failed [401].Error message: Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys.
    Output
      $error
      $error$message
      [1] "Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys."
      
      $error$type
      [1] "invalid_request_error"
      
      $error$param
      NULL
      
      $error$code
      [1] "invalid_api_key"
      
      

# OpenAI create edit fails with bad key

    Code
      openai_create_edit(model = "text-davinci-edit-001", input = "I is a human.",
        temperature = 1, instruction = "fix the grammar", openai_api_key = sample_key)
    Message <cliMessage>
      ! OpenAI API request failed [401].Error message: Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys.
    Output
      $error
      $error$message
      [1] "Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys."
      
      $error$type
      [1] "invalid_request_error"
      
      $error$param
      NULL
      
      $error$code
      [1] "invalid_api_key"
      
      

---

    Code
      openai_create_edit(model = "text-davinci-edit-001", input = "I is a human.",
        temperature = 1, instruction = "fix the grammar", top_p = 1, openai_api_key = sample_key)
    Warning <rlang_warning>
      Specify either temperature or top_p, not both.
    Message <cliMessage>
      ! OpenAI API request failed [401].Error message: Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys.
    Output
      $error
      $error$message
      [1] "Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys."
      
      $error$type
      [1] "invalid_request_error"
      
      $error$param
      NULL
      
      $error$code
      [1] "invalid_api_key"
      
      

# OpenAI create chat completion fails with bad key

    Code
      openai_create_chat_completion(prompt = "What is your name?", openai_api_key = sample_key)
    Message <cliMessage>
      ! OpenAI API request failed [401].Error message: Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys.
    Output
      $error
      $error$message
      [1] "Incorrect API key provided: 4f9bb533************************cc24. You can find your API key at https://platform.openai.com/account/api-keys."
      
      $error$type
      [1] "invalid_request_error"
      
      $error$param
      NULL
      
      $error$code
      [1] "invalid_api_key"
      
      

