mockr::local_mock(
  get_selection = function() {
    data.frame(value = "here is some selected text", stringsAsFactors = FALSE)
  }
)
