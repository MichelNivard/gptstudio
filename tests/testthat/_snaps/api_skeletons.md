# multiplication works

    Code
      gptstudio_create_skeleton()
    Output
      $url
      https://api.openai.com/v1/chat/completions
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_openai"   "gptstudio_request_skeleton"

---

    Code
      gptstudio_create_skeleton(service = "anthropic")
    Output
      $url
      [1] "https://api.anthropic.com/v1/complete"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_anthropic" "gptstudio_request_skeleton" 

---

    Code
      gptstudio_create_skeleton(service = "cohere")
    Output
      $url
      [1] "https://api.cohere.ai/v1/chat"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_cohere"   "gptstudio_request_skeleton"

---

    Code
      gptstudio_create_skeleton(service = "google")
    Output
      $url
      [1] "https://generativelanguage.googleapis.com/v1beta2/models/"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_google"   "gptstudio_request_skeleton"

---

    Code
      gptstudio_create_skeleton(service = "huggingface")
    Output
      $url
      [1] "https://api-inference.huggingface.co/models"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_huggingface" "gptstudio_request_skeleton"   

---

    Code
      gptstudio_create_skeleton(service = "ollama")
    Output
      $url
      [1] "JUST A PLACEHOLDER"
      
      $api_key
      [1] "JUST A PLACEHOLDER"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_ollama"   "gptstudio_request_skeleton"

---

    Code
      gptstudio_create_skeleton(service = "openai")
    Output
      $url
      https://api.openai.com/v1/chat/completions
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_openai"   "gptstudio_request_skeleton"

---

    Code
      gptstudio_create_skeleton(service = "perplexity")
    Output
      $url
      [1] "https://api.perplexity.ai/chat/completions"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      list()
      
      attr(,"class")
      [1] "gptstudio_request_perplexity" "gptstudio_request_skeleton"  

---

    Code
      gptstudio_create_skeleton(service = "azure_openai")
    Output
      $url
      [1] "user provided with environmental variables"
      
      $api_key
      [1] "a-fake-key"
      
      $model
      [1] "gpt-4o-mini"
      
      $prompt
      [1] "Name the top 5 packages in R."
      
      $history
      $history[[1]]
      $history[[1]]$role
      [1] "system"
      
      $history[[1]]$content
      [1] "You are an R chat assistant"
      
      
      
      $stream
      [1] TRUE
      
      $extras
      $extras$extras
      $extras$extras$deployment_name
      [1] ""
      
      $extras$extras$api_version
      [1] ""
      
      $extras$extras$endpoint
      [1] ""
      
      
      
      attr(,"class")
      [1] "gptstudio_request_azure_openai" "gptstudio_request_skeleton"    

# validate_skeleton throws error for invalid URL

    Code
      validate_skeleton(url = 123, api_key = "valid_key", model = "test_model",
        prompt = "What is R?", history = list(), stream = TRUE)
    Condition
      Error in `validate_skeleton()`:
      ! `url` is not a valid character scalar. It is a <numeric>.

# validate_skeleton throws error for empty API key

    Code
      validate_skeleton(url = "https://api.example.com", api_key = "", model = "test_model",
        prompt = "What is R?", history = list(), stream = TRUE)
    Condition
      Error in `validate_skeleton()`:
      ! `api_key` is not a valid character scalar. It is a <character>.

# validate_skeleton throws error for non-character prompt

    Code
      validate_skeleton(url = "https://api.example.com", api_key = "valid_key",
        model = "test_model", prompt = list("not a string"), history = list(),
        stream = TRUE)
    Condition
      Error in `validate_skeleton()`:
      ! `prompt` is not a valid character scalar. It is a <list>.

# validate_skeleton throws error for invalid history

    Code
      validate_skeleton(url = "https://api.example.com", api_key = "valid_key",
        model = "test_model", prompt = "What is R?", history = "not a list", stream = TRUE)
    Condition
      Error in `validate_skeleton()`:
      ! `history` is not a valid list or NULL. It is a <character>.

# validate_skeleton throws error for non-boolean stream

    Code
      validate_skeleton(url = "https://api.example.com", api_key = "valid_key",
        model = "test_model", prompt = "What is R?", history = list(), stream = "not a boolean")
    Condition
      Error in `validate_skeleton()`:
      ! `stream` is not a valid boolean. It is a <character>.

