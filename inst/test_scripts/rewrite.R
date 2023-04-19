library(magrittr)
# Example XML document
tree <- '<book isbn="978-0596007126" title="R Cookbook" author="Paul Teetor"/>'

# Test case for makeAttrs
expected <- c('isbn = "978-0596007126"', 'title = "R Cookbook"', 'author = "Paul Teetor"')

xml_1 <- XML::htmlParse(tree) |> 
	XML::getNodeSet("/html/body/*") %>% 
	`[[`(1)

xml_2 <- xml2::read_xml(tree) |>
	xml2::xml_find_first(".")


xml_1
# Test the original makeAttrs function
makeAttrs_orig <- function(node) {
	attrs <- XML::xmlAttrs(node)
	names(attrs) %>%
		Map(function (name) {
			val <- attrs[[name]]
			paste0(name, ' = ', if (val == "") "NA" else paste0('"', val, '"'))
		}, .)
}

actual_orig <- makeAttrs_orig(xml_1)
identical(expected, actual_orig) # should return TRUE

# Test the new makeAttrs function using xml2 and tidyverse

makeAttrs_new <- function(node) {
	attrs <- xml2::xml_attrs(node) 
	purrr::imap(attrs, \(.x, i){
		# val <- unname(.x)
		paste0(i, ' = ', dplyr::if_else(.x == "", "NA", glue::glue('"{.x}"')))
	}) 
}

actual_new <- makeAttrs_new(xml_2)
identical(expected, actual_new) # should return TRUE

identical(actual_orig, actual_new)
