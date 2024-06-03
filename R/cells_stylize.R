#' Apply style to worksheet based on one or more excel-style cell ranges
#'
#' @inheritParams add_cell_borders
#' @param style `openxlsx` cell style, created with `openxlsx::createStyle()`. This can include text size, bolding or italics, text wrapping, foreground color, text color, etc. See `?openxlsx::createStyle` for details.
#' @param stack Should style be appended to existing styles (`TRUE`) or replace existing styles (`FALSE`). Defaults to `TRUE`.
#'
#' @export
#'
cells_stylize <- function(wb, sheet, style, block.ranges, stack = TRUE){
  cells.modify = do.call(rbind,
                           purrr::map(block.ranges,
                                      .f = cell_range_translate))
  openxlsx::addStyle(wb, sheet = sheet, style = style,
                     rows = cells.modify$row,
                     cols = cells.modify$col,
                     stack = stack, gridExpand = FALSE)
}
