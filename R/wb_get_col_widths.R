#' `r lifecycle::badge("experimental")`
#' Get column widths of openxlsx2 Workbook sheet
#'
#' Code by Jan Marvin. This function will likely be superceded by a function in openxlsx2 in the future.
#'
#' @param wb openxlsx2 workbook object
#' @param sheet sheet name, defaults to current sheet
#'
#' @return Dataframe with $col (column names) and $width (column widths)
#' @export
#'
#' @examples
#' library(openxlsx2)
#' wb <- wb_workbook() |>
#'   wb_add_worksheet("Sheet1") |>
#'   wb_add_data(x = mtcars) |>
#'   wb_set_col_widths(cols = 2:4, widths = 12)
#'
#' current_widths <- wb_get_col_widths(wb, sheet = "Sheet1")
#' current_widths
wb_get_col_widths <- function(wb, sheet = openxlsx2::current_sheet()) {
  if (!("wbWorkbook" %in% class(wb))) {
    cli::cli_abort("`wb` must be an `openxlsx2` workbook!")
  }
  sheet_id <- wb$.__enclos_env__$private$get_sheet_index(sheet)
  wds <- wb$worksheets[[sheet_id]]$unfold_cols()[c("min", "width")]
  wds$col <- openxlsx2::int2col(as.numeric(wds$min))
  wds$width <- as.numeric(wds$width)
  wds[c("col", "width")]
}
