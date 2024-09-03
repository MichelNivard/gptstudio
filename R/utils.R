# Taken from https://github.com/hadley/elmer, which was translated from
# https://github.com/langchain-ai/langchain/blob/master/libs/core/langchain_core/utils/_merge.py
merge_dicts <- function(left, right) {
  for (right_k in names(right)) {
    right_v <- right[[right_k]]
    left_v <- left[[right_k]]

    if (is.null(right_v)) {
      left[right_k] <- list(NULL)
    } else if (is.null(left_v)) {
      left[[right_k]] <- right_v
    } else if (identical(left_v, right_v)) {
      next
    } else if (is.character(left_v)) {
      left[[right_k]] <- paste0(left_v, right_v)
    } else if (is.list(left_v)) {
      if (!is.null(names(right_v))) {
        left[[right_k]] <- merge_dicts(left_v, right_v)
      } else {
        left[[right_k]] <- merge_lists(left_v, right_v)
      }
    } else if (!identical(class(left_v), class(right_v))) {
      stop(paste0("additional_kwargs['", right_k, "'] already exists in this message, but with a different type."))
    } else {
      stop(paste0(
        "Additional kwargs key ",
        right_k,
        " already exists in left dict and value has unsupported type ",
        class(left[[right_k]]),
        "."
      ))
    }
  }

  left
}

merge_lists <- function(left, right) {

  if (is.null(right)) {
    return(left)
  } else if (is.null(left)) {
    return(right)
  }

  for (e in right) {
    idx <- find_index(left, e)
    if (is.na(idx)) {
      left <- c(left, list(e))
    } else {
      # If a top-level "type" has been set for a chunk, it should no
      # longer be overridden by the "type" field in future chunks.
      if (!is.null(left[[idx]]$type) && !is.null(e$type)) {
        e$type <- NULL
      }
      left[[idx]] <- merge_dicts(left[[idx]], e)
    }
  }
  left
}

find_index <- function(left, e_right) {
  if (!is.list(e_right) || !has_name(e_right, "index") || !is.numeric(e_right$index)) {
    return(NA)
  }

  matches_idx <- map_lgl(left, function(e_left) e_left$index == e_right$index)
  if (sum(matches_idx) != 1) {
    return(NA)
  }
  which(matches_idx)[[1]]
}
