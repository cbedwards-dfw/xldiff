#' Summarize the rows changed between two dataframes
#'
#' When given two dataframes, uses sheet_comp to compare the two dataframes, then
#' presents the rows that have changed: prints the row numbers to the console, and then
#' returns the "diff" of those rows. Optionally, can ignore columns that have not changed and can show
#' only changed values.
#'
#' Alternatively, look at the `diffdf` package!
#'
#' @inheritParams sheet_comp
#' @param trim_cols Remove unchanged columns? Useful with wide dataframes when viewing results in the console. Defaults to FALSE.
#' @param diff_only Show only the changed values? defaults to FALSE.
#'
#' @return A diff of the two dataframes, similar to `$sheet_diff` part of the return of sheet_comp. Includes a `row_number` column, and remaining columns have been labeled to match excel column naming conventions.
#' @export
#'
present_rows_changed <- function(t1,
                                 t2,
                                 proportional_threshold = 0.001,
                                 absolute_threshold = NULL,
                                 digits_show = 6,
                                 trim_cols = FALSE,
                                 diff_only = FALSE) {
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


#' Diff excel sheet and return tibble
#'
#' Compares sheet from two excel files and returns a tibble of the diff.
#'
#' @inheritParams excel_diff_table
#' @inheritParams present_rows_changed
#'
#' @seealso [excel_diff()], [excel_diff_table()]
#'
#' @export
#'
excel_diff_tibble <- function(file_1,
                              file_2,
                              sheet_name,
                              proportional_threshold = 0.001,
                              absolute_threshold = NULL,
                              digits_show = 6,
                              trim_cols = FALSE,
                              diff_only = FALSE){
  validate_character(file_1, n = 1)
  validate_character(file_2, n = 1)
  if (!all(grepl(".xlsx$", c(file_1, file_2)))) {
    cli::cli_abort("`file_1` and `file_2` must end in `.xlsx`.")
  }
  validate_character(sheet_name, n = 1)
  validate_numeric(proportional_threshold, n = 1, min = 0)
  if (!is.null(absolute_threshold)) {
    validate_numeric(absolute_threshold, n = 1, min = 0)
  }
  validate_integer(digits_show, n = 1)

  f1 <- readxl::read_excel(file_1, sheet = sheet_name, col_names = FALSE, .name_repair = "unique_quiet")
  f2 <- readxl::read_excel(file_2, sheet = sheet_name, col_names = FALSE, .name_repair = "unique_quiet")

  res <- present_rows_changed(t1 = f1,
                       t2 = f2,
                       proportional_threshold = proportional_threshold,
                       absolute_threshold = absolute_threshold,
                       digits_show = digits_show,
                       trim_cols = trim_cols,
                       diff_only = diff_only)
  return(res)
}
