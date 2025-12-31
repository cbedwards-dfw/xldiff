#' Summarize the rows changed between two dataframes
#'
#' When given two dataframes, uses sheet_comp to compare the two dataframes, then
#' presents the rows that have changed: prints the row numbers to the console, and then
#' returns the "diff" of those rows, with column names matching excel column naming conventions.
#'
#' Alternatively, look at the `diffdf` package!
#'
#' @inheritParams sheet_comp
#' @param trim_cols Remove unchanged columns? Useful with wide dataframes when viewing results in the console. Defaults to TRUE.
#' @param diff_only Show only the changed values? defaults to TRUE.
#'
#' @return A diff of the two dataframes, similar to `$sheet_diff` part of the return of sheet_comp. Includes a `row_number` column, and remaining columns have been labeled to match excel column naming conventions.
#' @export
#'
present_rows_changed <- function(t1,
                                 t2,
                                 proportional_threshold = 0.001,
                                 absolute_threshold = NULL,
                                 digits_show = 6,
                                 trim_cols = TRUE,
                                 diff_only = TRUE) {
  out <- sheet_comp(t1, t2,
    proportional_threshold = proportional_threshold,
    absolute_threshold = absolute_threshold,
    digits_show = digits_show
  )

  rows_changed <- apply(out$mat_changed, 1, any)

  cli::cli_alert("The following rows have changed: {which(rows_changed)}")

  mat_diff <- out$sheet_diff
  if (diff_only) {
    mat_diff[!out$mat_changed] <- ""
  }
  rowdiffs <-
    tibble::as_tibble(mat_diff)
  rowdiffs <- rowdiffs[rows_changed, ]

  excel_colnames <- apply(as.matrix(tidyr::expand_grid(c("", LETTERS), LETTERS)), 1, function(x) {
    paste(x, collapse = "")
  })
  names(rowdiffs) <- excel_colnames[1:ncol(rowdiffs)]



  if (trim_cols) {
    cols_changed <- apply(out$mat_changed, 2, any)
    rowdiffs <- rowdiffs[, cols_changed] # slight jank - have new "row" column
  }
  # rowdiffs = rbind(rows = which(rows_changed),
  #                  rowdiffs)
  rowdiffs <- rowdiffs |>
    dplyr::mutate(row_name = which(rows_changed)) |>
    dplyr::relocate("row_name")
  return(rowdiffs)
}
