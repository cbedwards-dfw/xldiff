#' Adds cell borders to openxlsx spreadsheet
#'
#' Update: `excel_diff` now includes formatting! This function should hopefully be less necessary.
#'
#' When calling `sheet_diff()`, creating a new workbook for the diff contents, and
#' then coloring to highlight changed cells, the original spreadsheet formatting is lost.
#' To facilitate interpretting the diff, it can be useful to recreate the major components of the original
#' formatting, especially cell borders. This function adds cell borders, and is designed for ease of use
#' when replicating formatting from the original excel file. Blocks of cells to give borders to can be
#' specified in the original excel format (e.g. "A1:D5"). For only outside borders around each block (default), use argument
#' `every_cell = FALSE`. To add all the cell borders within each block to generate a grid appearance, set `every_cell = TRUE`.
#' Note that non-border formatting of each cell will not be maintained, but border formatting will be overwritten. When adding
#' thin boundaries between inner cells and a thick outer border for a block of cells, first use `add_cell_borders` to
#' with `every_cell = TRUE`, and appropriate border arguments (usually `border_thickness = "thin"`)
#' and then use again with `every_cell = FALSE` and appropriate border arguments (usually `border_thickness = "medium"`).
#'
#' @param wb openxlsx workbook object
#' @param sheet character corresponding to sheet name of openxlsx workbook object `wb`.
#' @param block_ranges One or more cell ranges specified in excel format (e.g. `c("A1:D5, "B6", "A8:D8")`)
#' @param sheet_start Optional. If `wb$sheet` corresponds to an excel sheet in which the `wb$sheet` entries were read starting on a cell other than "A1"
#' (e.g. `readxl::read_excel` with range specified or skip provided), provide the top left cell that was read into R in order
#' to handle the offsetting, so that you can specify cell ranges based on the original excel file.
#' @param every_cell Do we want borders around each individual cell in each cell block (`TRUE`), or just around the outer edges of the block (`FALSE`). Defaults to `FALSE`.
#' @param border_col Color for border. See `?openxlsx::createStyle` for details. Defaults to "black".
#' @param border_thickness Thickness for border. See `?openxlsx::createStyle` for details. Common choices: "thin", "thick".
#'
#' @importFrom rlang .data
#'
#' @export
#'
add_cell_borders <- function(wb,
                             sheet,
                             block_ranges, ## character vector of excel-style ranges of cells that should be given borders. Can take individual cells
                             sheet_start = "A1", ## offset for if
                             every_cell = FALSE, ## If TRUE,
                             border_col = "black",
                             border_thickness = "medium") {
  cells_ls <- lapply(block_ranges, cell_range_translate, start = sheet_start)

  if (every_cell) { ## each cell should have all borders on it.
    temp_style <- openxlsx::createStyle(
      border = "TopBottomLeftRight",
      borderColour = border_col,
      borderStyle = border_thickness
    )
    cells_df <- unique(do.call(rbind, cells_ls))
    openxlsx::addStyle(
      wb,
      sheet,
      style = temp_style,
      rows = cells_df$row,
      cols = cells_df$col,
      gridExpand = FALSE,
      stack = TRUE
    )
  } else {
    ## for each block, identify the top, bottom, left, and right cells.
    cells_top <- unique(
      do.call(
        rbind, ## for each
        purrr::map(cells_ls,
          .f = function(x) {
            x |> dplyr::filter(.data$row == min(.data$row))
          }
        )
      )
    )

    cells_bottom <- unique(
      do.call(
        rbind,
        purrr::map(cells_ls,
          .f = function(x) {
            x |> dplyr::filter(.data$row == max(.data$row))
          }
        )
      )
    )
    cells_left <- unique(
      do.call(
        rbind,
        purrr::map(cells_ls,
          .f = function(x) {
            x |> dplyr::filter(.data$col == min(.data$col))
          }
        )
      )
    )
    cells_right <- unique(
      do.call(
        rbind,
        purrr::map(cells_ls,
          .f = function(x) {
            x |> dplyr::filter(.data$col == max(.data$col))
          }
        )
      )
    )
    ## apply appropriate borders to each set of cells.
    temp_style <- openxlsx::createStyle(
      border = "top",
      borderColour = border_col,
      borderStyle = border_thickness
    )
    openxlsx::addStyle(
      wb,
      sheet,
      style = temp_style,
      rows = cells_top$row,
      cols = cells_top$col,
      gridExpand = FALSE,
      stack = TRUE
    )

    temp_style <- openxlsx::createStyle(
      border = "bottom",
      borderColour = border_col,
      borderStyle = border_thickness
    )
    openxlsx::addStyle(
      wb,
      sheet,
      style = temp_style,
      rows = cells_bottom$row,
      cols = cells_bottom$col,
      gridExpand = FALSE,
      stack = TRUE
    )

    temp_style <- openxlsx::createStyle(
      border = "left",
      borderColour = border_col,
      borderStyle = border_thickness
    )
    openxlsx::addStyle(
      wb,
      sheet,
      style = temp_style,
      rows = cells_left$row,
      cols = cells_left$col,
      gridExpand = FALSE,
      stack = TRUE
    )

    temp_style <- openxlsx::createStyle(
      border = "right",
      borderColour = border_col,
      borderStyle = border_thickness
    )
    openxlsx::addStyle(
      wb,
      sheet,
      style = temp_style,
      rows = cells_right$row,
      cols = cells_right$col,
      gridExpand = FALSE,
      stack = TRUE
    )
  }
}
