describe("chat() openai", {
  skip_on_ci()
  skip_on_cran()

  it("fails without API KEY", {
    expect_error({
      withr::with_envvar(OPENAI_API_KEY = "", {
        chat(
          prompt = "what is 1+1",
          service = "openai",
          history = NULL,
          stream = FALSE,
          model = "gpt-4o-mini"
        )
      })
    })
  })

  it ("works", {
    expect_no_error({
      chat(
        prompt = "what is 1+1",
        service = "openai",
        history = NULL,
        stream = FALSE,
        model = "gpt-4o-mini"
      )
    })
  })
})

describe("chat() huggingface", {
  skip_on_ci()
  skip_on_cran()

  it("fails without API KEY", {
    expect_error({
      withr::with_envvar(HF_API_KEY = "", {
        chat(
          prompt = "what is 1+1",
          service = "huggingface",
          history = NULL,
          stream = FALSE,
          model = "google/gemma-2-2b-it"
        )
      })
    })
  })

  it ("works", {
    expect_no_error({
      chat(
        prompt = "what is 1+1",
        service = "huggingface",
        history = NULL,
        stream = FALSE,
        model = "google/gemma-2-2b-it"
      )
    })
  })
})

describe("chat() anthropic", {
  skip_on_ci()
  skip_on_cran()

  it("fails without API KEY", {
    expect_error({
      withr::with_envvar(ANTHROPIC_API_KEY = "", {
        chat(
          prompt = "what is 1+1",
          service = "anthropic",
          history = NULL,
          stream = FALSE,
          model = "claude-3-5-sonnet-20240620"
        )
      })
    })
  })

  it ("works", {
    expect_no_error({
      chat(
        prompt = "what is 1+1",
        service = "anthropic",
        history = NULL,
        stream = FALSE,
        model = "claude-3-5-sonnet-20240620"
      )
    })
  })
})

describe("chat() ollama", {
  skip_on_ci()
  skip_on_cran()

  it ("works", {
    skip_if_not(ollama_is_available())
    expect_no_error({
      chat(
        prompt = "what is 1+1",
        service = "ollama",
        history = NULL,
        stream = FALSE,
        model = "gemma"
      )
    })
  })
})
