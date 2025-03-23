describe("chat() openai", {
  it("fails without API KEY", {
    skip_on_ci()
    skip_on_cran()

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
    skip_on_ci()
    skip_on_cran()

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
  it("fails without API KEY", {
    skip_on_ci()
    skip_on_cran()

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
    skip_on_ci()
    skip_on_cran()

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
  it("fails without API KEY", {
    skip_on_ci()
    skip_on_cran()

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
    skip_on_ci()
    skip_on_cran()

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
  it ("works", {
    skip_on_ci()
    skip_on_cran()
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
