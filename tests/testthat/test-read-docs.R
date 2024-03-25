test_that("read_docs() returns NULL when there is no namespace::object match in prompt", {
  read_docs("Text with no match for regular expression") %>%
    expect_null()
})

test_that("read_docs() matches all expected case types", {
  # meaning snake_case, camelCase, etc
  read_docs("purrr::as_vector") %>% expect_type("list")
  read_docs("base::as.data.frame") %>% expect_type("list")
  read_docs("base::data.frame") %>% expect_type("list")
  read_docs("base::isTrue") %>% expect_type("list")
  read_docs("stringr::str_view") %>% expect_type("list")
})

test_that("read_docs() works in operators", {
  skip("To be implemented: work in operators")

  # Right now this returns NULL, as in no match
  read_docs("magrittr::%>%") %>% expect_type("list")
})

test_that("read_docs() works when functions share docs", {
  skip("To be implemented: functions share docs")

  # Right now this errors for some reason
  read_docs("stringr::str_split_1") %>% expect_type("list")
  read_docs("htmltools::tags") %>% expect_type("list")
  read_docs("rlang::is_atomic") %>% expect_type("list")

  # but this works ?
  read_docs("stringr::str_split") %>% expect_type("list")
})

test_that("read_docs() returns expected lengths and types", {
  test_prompt_single <- "Check purrr::map for info"
  test_prompt_multiple <- "Check rlang::abort and cli::cli for examples"

  read_docs(test_prompt_single) %>%
    expect_type("list") %>%
    expect_length(1L)

  read_docs(test_prompt_multiple) %>%
    expect_type("list") %>%
    expect_length(2L)
})

test_that("read_docs() returns expected structure when documentation exists", {
  test_prompt <- "See glue::glue for more" %>%
    read_docs()

  test_prompt %>%
    expect_type("list") %>%
    expect_length(1L)

  test_prompt %>%
    purrr::pluck(1L) %>%
    expect_named(c("pkg_ref", "topic", "inner_text"))

  test_prompt %>%
    purrr::pluck(1L, "inner_text") %>%
    expect_type("list")
})

test_that("read_docs() returns expected structure when no documentation found", {
  test_prompt <- "See base::tibble for more" %>%
    read_docs()

  test_prompt %>%
    expect_type("list") %>%
    expect_length(1L)

  test_prompt %>%
    purrr::pluck(1L) %>%
    expect_named(c("pkg_ref", "topic", "inner_text"))

  test_prompt %>%
    purrr::pluck(1L, "inner_text") %>%
    expect_null()
})
