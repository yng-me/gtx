apply_col_merge <- function(.data, .col_merge, .boxhead, .start_row, .start_col = 2, ...) {

  clean_glue <- function(.x) {
    .x |>
      stringr::str_remove_all("<<\\s*\\-\\s*>>") |>
      stringr::str_remove_all("(>|<)+") |>
      stringr::str_remove_all("\\(\\)") |>
      stringr::str_squish()
  }

  for(i in seq_along(.col_merge)) {

    merge <- .col_merge[[i]]
    pattern <- merge$pattern
    pattern_new <- pattern
    vars <- merge$vars

    v <- stringr::str_extract_all(pattern, '\\{.*?\\}')[[1]]

    for(j in seq_along(v)) {
      y <- stringr::str_extract_all(v[j], "\\d+")[[1]]
      var <- paste0("`", vars[as.integer(y)], "`")
      pattern_new <- stringr::str_replace(pattern_new, y, var)
    }

    if(grepl("<br\\s?\\/?>", pattern_new)) {
      attr(.data, "row_heights") <- merge$rows + .start_row
    }

    pattern_new <- pattern_new |>
      stringr::str_replace_all("\\s*<br\\s?\\/?>\\s*", "\n")

    col_selected <- .boxhead[.boxhead %in% vars]

    if(length(col_selected) > 0) {
      .data <- .data |>
        dplyr::mutate(
          !!as.name(col_selected[1]) := dplyr::if_else(
            as.integer(`__row_number__`) %in% merge$rows,
            clean_glue(as.character(glue::glue(pattern_new, .na = ""))),
            as.character(!!as.name(col_selected[1]))
          )
        )
    }

  }

  return(.data)

}
