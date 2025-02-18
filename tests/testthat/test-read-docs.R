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

# Comprehensive tests for valid R package names with user-like prompts
test_that("Valid R package names are correctly matched", {
    expect_equal(locate_double_colon_calls("Is A1::func correct?"), 
                 list(list(pkg_ref = "A1", topic = "func")))                 
    expect_equal(locate_double_colon_calls("Check this abc::f example"), 
                 list(list(pkg_ref = "abc", topic = "f")))                     
    expect_equal(locate_double_colon_calls("The long.package.name::another_function() is great"), 
                 list(list(pkg_ref = "long.package.name", topic = "another_function")))
    expect_equal(locate_double_colon_calls("Replace with ab.c::func call"), 
                 list(list(pkg_ref = "ab.c", topic = "func")))               
    expect_equal(locate_double_colon_calls("What about AB.C::func?"), 
                 list(list(pkg_ref = "AB.C", topic = "func")))               
    expect_equal(locate_double_colon_calls("Use Ab123::func instead"), 
                 list(list(pkg_ref = "Ab123", topic = "func")))              
    expect_equal(locate_double_colon_calls("Try package.name123::func"), 
                 list(list(pkg_ref = "package.name123", topic = "func")))       
    expect_equal(locate_double_colon_calls("pkg.name::function.subfunc() should work"), 
                 list(list(pkg_ref = "pkg.name", topic = "function.subfunc")))  
    expect_equal(locate_double_colon_calls("Use a.very.long.package.name.012::complex_fun.name"), 
                 list(list(pkg_ref = "a.very.long.package.name.012", topic = "complex_fun.name")))         
    expect_equal(locate_double_colon_calls("Look at x.y.z::a.b.c example"), 
                 list(list(pkg_ref = "x.y.z", topic = "a.b.c"))) 
    expect_equal(locate_double_colon_calls("Call SomeName::anotherFunction"), 
                 list(list(pkg_ref = "SomeName", topic = "anotherFunction"))) 
    # Additional tests with multiple pkg::func combinations
    expect_equal(locate_double_colon_calls("Use dv.loader::load_data and A1::func to achieve this"), 
                 list(list(pkg_ref = "dv.loader", topic = "load_data"), 
                      list(pkg_ref = "A1", topic = "func")))     
    expect_equal(locate_double_colon_calls("abc::f and abc.def::function_name are both used here"), 
                 list(list(pkg_ref = "abc", topic = "f"), 
                      list(pkg_ref = "abc.def", topic = "function_name")))                   
    expect_equal(locate_double_colon_calls("The long.package.name::another_function and AB.C::func are important"), 
                 list(list(pkg_ref = "long.package.name", topic = "another_function"), 
                      list(pkg_ref = "AB.C", topic = "func")))               
    expect_equal(locate_double_colon_calls("Use Ab123::func with package.name123::func for this task"), 
                 list(list(pkg_ref = "Ab123", topic = "func"), 
                      list(pkg_ref = "package.name123", topic = "func")))              
})

