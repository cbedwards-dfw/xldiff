#' Summarize the rows changed between two dataframes
#'
#' When given two dataframes, uses sheet_comp to compare the two dataframes, then
#' presents the rows that have changed: prints the row numbers to the console, and then
#' returns the "diff" of those rows, with column names matching excel column naming conventions.
#'
#' @inheritParams sheet_comp
#' @param trim.cols Remove unchanged columns? Useful with wide dataframes when viewing results in the console. Defaults to TRUE.
#' @param diff.only Show only the changed values? defaults to TRUE.
#'
#' @return A diff of the two dataframes, similar to `$sheet.diff` part of the return of sheet_comp. Includes a `row_number` column, and remaining columns have been labeled to match excel column naming conventions.
#' @export
#'
present_rows_changed = function(t1,
                                t2,
                                digits.signif = 4,
                                trim.cols = TRUE,
                                diff.only = TRUE){

  out = sheet_comp(t1, t2, digits.signif = digits.signif)

  rows.changed = apply(out$mat.changed, 1, any)

  cli::cli_alert("The following rows have changed: {which(rows.changed)}")

  mat.diff = out$sheet.diff
  if(diff.only){
    mat.diff[!out$mat.changed] = ""
  }
  rowdiffs =
    tibble::as_tibble(mat.diff)
  rowdiffs = rowdiffs[rows.changed, ]

  excel.colnames = apply(as.matrix(tidyr::expand_grid(c("",LETTERS), LETTERS)), 1, function(x) {paste(x, collapse = "")})
  names(rowdiffs) = excel.colnames[1:ncol(rowdiffs)]



  if(trim.cols){
    cols.changed = apply(out$mat.changed, 2, any)
    rowdiffs = rowdiffs[, cols.changed] #slight jank - have new "row" column
  }
  # rowdiffs = rbind(rows = which(rows.changed),
  #                  rowdiffs)
  rowdiffs = rowdiffs |>
    dplyr::mutate(row_name = which(rows.changed)) |>
    dplyr::relocate("row_name")
  return(rowdiffs)
}
