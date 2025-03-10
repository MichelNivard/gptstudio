test_that("read_docs() returns NULL when there is no namespace::object match in prompt", {
  read_docs("Text with no match for regular expression") |>
    expect_null()
})

test_that("read_docs() matches all expected case types", {
  # meaning snake_case, camelCase, etc
  read_docs("purrr::as_vector") |> expect_type("list")
  read_docs("base::as.data.frame") |> expect_type("list")
  read_docs("base::data.frame") |> expect_type("list")
  read_docs("base::isTrue") |> expect_type("list")
  read_docs("stringr::str_view") |> expect_type("list")
})

test_that("read_docs() gets non null content when successful", {
  # These expectations can fail when the tested documentations are changed by their authors
  # when they fail, first try previous versions of the packages

  str_view_docs <- read_docs("stringr::str_view")[[1]]
  data.frame_docs <- read_docs("base::data.frame")[[1]] # nolint: object_name_linter

  expect_false(is.null(str_view_docs$pkg_ref))
  expect_false(is.null(str_view_docs$topic))
  expect_false(is.null(str_view_docs$inner_text))
  expect_false(is.null(str_view_docs$inner_text$title))
  expect_false(is.null(str_view_docs$inner_text$description))
  expect_false(is.null(str_view_docs$inner_text$usage))
  expect_false(is.null(str_view_docs$inner_text$arguments))
  expect_false(is.null(str_view_docs$inner_text$examples))

  expect_false(is.null(data.frame_docs$pkg_ref))
  expect_false(is.null(data.frame_docs$topic))
  expect_false(is.null(data.frame_docs$inner_text))
  expect_false(is.null(data.frame_docs$inner_text$title))
  expect_false(is.null(data.frame_docs$inner_text$description))
  expect_false(is.null(data.frame_docs$inner_text$usage))
  expect_false(is.null(data.frame_docs$inner_text$arguments))
  expect_false(is.null(data.frame_docs$inner_text$examples))
})

test_that("read_docs() works in operators", {
  skip("To be implemented: work in operators")

  # Right now this returns NULL, as in no match
  read_docs("magrittr::|>") |> expect_type("list")
})

test_that("read_docs() works when functions share docs", {
  skip("To be implemented: functions share docs")

  # Right now this errors for some reason
  read_docs("stringr::str_split_1") |> expect_type("list")
  read_docs("htmltools::tags") |> expect_type("list")
  read_docs("rlang::is_atomic") |> expect_type("list")

  # but this works ?
  read_docs("stringr::str_split") |> expect_type("list")
})

test_that("read_docs() returns expected lengths and types", {
  test_prompt_single <- "Check purrr::map for info"
  test_prompt_multiple <- "Check rlang::abort and cli::cli for examples"

  read_docs(test_prompt_single) |>
    expect_type("list") |>
    expect_length(1L)

  read_docs(test_prompt_multiple) |>
    expect_type("list") |>
    expect_length(2L)
})

test_that("read_docs() returns expected structure when documentation exists", {
  test_prompt <- "See glue::glue for more" |>
    read_docs()

  test_prompt |>
    expect_type("list") |>
    expect_length(1L)

  test_prompt |>
    purrr::pluck(1L) |>
    expect_named(c("pkg_ref", "topic", "inner_text"))

  test_prompt |>
    purrr::pluck(1L, "inner_text") |>
    expect_type("list")
})

test_that("read_docs() returns expected structure when no documentation found", {
  test_prompt <- "See base::tibble for more" |>
    read_docs()

  test_prompt |>
    expect_type("list") |>
    expect_length(1L)

  test_prompt |>
    purrr::pluck(1L) |>
    expect_named(c("pkg_ref", "topic", "inner_text"))

  test_prompt |>
    purrr::pluck(1L, "inner_text") |>
    expect_null()
})

# Helper function to create expected value format for locate_double_colon_calls tests below
get_expected_value_format <- function(...) {
  # Convert pairs of arguments into list of pkg_ref and topic pairs
  args <- list(...)
  if (length(args) %% 2 != 0) stop("Arguments must be pairs of pkg_ref and topic")
  even_indices <- seq(2, length(args), by = 2)
  Map(list, pkg_ref = args[even_indices - 1], topic = args[even_indices])
}

# Comprehensive tests for valid R package names with user-like prompts
test_that("Valid R package names are correctly matched", {
  expect_equal(
    locate_double_colon_calls("Is A1::func correct?"),
    get_expected_value_format("A1", "func")
  )
  expect_equal(
    locate_double_colon_calls("Check this abc::f example"),
    get_expected_value_format("abc", "f")
  )
  expect_equal(
    locate_double_colon_calls("The long.package.name::another_function() is great"),
    get_expected_value_format("long.package.name", "another_function")
  )
  expect_equal(
    locate_double_colon_calls("Replace with ab.c::func call"),
    get_expected_value_format("ab.c", "func")
  )
  expect_equal(
    locate_double_colon_calls("What about AB.C::func?"),
    get_expected_value_format("AB.C", "func")
  )
  expect_equal(
    locate_double_colon_calls("Use Ab123::func instead"),
    get_expected_value_format("Ab123", "func")
  )
  expect_equal(
    locate_double_colon_calls("Try package.name123::func"),
    get_expected_value_format("package.name123", "func")
  )
  expect_equal(
    locate_double_colon_calls("pkg.name::function.subfunc() should work"),
    get_expected_value_format("pkg.name", "function.subfunc")
  )
  expect_equal(
    locate_double_colon_calls("Use a.very.long.package.name.012::complex_fun.name"),
    get_expected_value_format("a.very.long.package.name.012", "complex_fun.name")
  )
  expect_equal(
    locate_double_colon_calls("Look at x.y.z::a.b.c example"),
    get_expected_value_format("x.y.z", "a.b.c")
  )
  expect_equal(
    locate_double_colon_calls("Call SomeName::anotherFunction"),
    get_expected_value_format("SomeName", "anotherFunction")
  )
  # Additional tests with multiple pkg::func combinations
  expect_equal(
    locate_double_colon_calls("Use dv.loader::load_data and A1::func to achieve this"),
    get_expected_value_format("dv.loader", "load_data", "A1", "func")
  )
  expect_equal(
    locate_double_colon_calls("abc::f and abc.def::function_name are both used here"),
    get_expected_value_format("abc", "f", "abc.def", "function_name")
  )
  expect_equal(
    locate_double_colon_calls(paste0(
      "The long.package.name::another_function and ",
      "AB.C::func are important"
    )),
    get_expected_value_format("long.package.name", "another_function", "AB.C", "func")
  )
  expect_equal(
    locate_double_colon_calls(
      "Use Ab123::func with package.name123::func for this task"
    ),
    get_expected_value_format("Ab123", "func", "package.name123", "func")
  )
})
