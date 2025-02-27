

#' Minimal spreadsheet comparison function
#'
#' Compares a single sheet between two files, supports providing additional formatting
#' in the form of the optional `extra_format_fun` argument. For more complex use cases (e.g.,
#' multiple sheet, pre-comparison formatting to compare only specific regions, etc) `excel_diff` can
#' be used as a simple template for writing your own function.
#'
#' @param file.1 Filename (including path) for first file to compare
#' @param file.2 Filename (including path) for second file to compare
#' @param results.name Name (including path) for file to save comparison to. Must end in ".xlsx"
#' @param sheet.name character string of sheet to compare. If the sheets have different names (or to compare two sheets in one file), can take a character vector of length two, with the sheet names from the first and second file in order.
#' @param extra_format_fun Optional function to apply additional formatting, allowing users to specify additional
#' calls of `addStyle()` (or other openxslx functions, like setting column width). First argument must be the workbook
#' object this function makes changes to; second argument must be the name of the worksheet this function makes
#' changes to
#' @param ... Additional arguments passed to `extra_format_fun`
#'
#' @export
#'
#' @examples
#' \dontrun{
#' filename.1 = "Documents/WDFW FRAM team work/NOF material/NOF 2024/FRAM/Chin1124.xlsx"
#'filename.2 = "Documents/WDFW FRAM team work/NOF material/NOF 2024/NOF 2/Chin2524.xlsx"
#'
#'excel_diff(file.1 = filename.1,
#'           file.2 = filename.2,
#'           results.name = "Documents/WDFW FRAM team work/NOF material/NOF 2024/test1.xlsx",
#'           sheet.name = "ER_ESC_Overview_New"
#')
#'
#' ## create function to add in some additional formatting:
#' extra_form_fun = function(wb, sheet){
#'  ## add bold and increased size for the first two rows.
#'  openxlsx::addStyle(wb, sheet,
#'                     style = openxlsx::createStyle(fontSize = 16, textDecoration = "Bold"),
#'                     rows = 1:2, cols = 1:8, gridExpand = TRUE,
#'                     stack = TRUE)
#'  ## add thin inner cell borders
#'  add_cell_borders(wb, sheet,
#'                   block.ranges = c("B3:H34") )
#'  ## add thick outer borders
#'  add_cell_borders(wb, sheet,
#'                   block.ranges = c("A2", "B1:D2", "E1:H2",
#'                                    "A3:A34", "B3:D34", "E3:H34",
#'                                    "D36:H37"),
#'                   border.thickness = "medium")
#'}
#'
#'excel_diff(file.1 = filename.1,
#'           file.2 = filename.2,
#'           results.name = "Documents/WDFW FRAM team work/NOF material/NOF 2024/test2.xlsx",
#'           sheet.name = "ER_ESC_Overview_New",
#'           extra_format_fun = extra_form_fun
#')
#'}



excel_diff = function(file.1, file.2, results.name, sheet.name, extra_format_fun = NULL, ...){

  if(!all(grepl(".xlsx$", c(file.1, file.2, results.name)))){
    cli::cli_abort("`file.1`, `file.2`, and `results.name` must end in `.xlsx`.")
  }
  if(!is.null(extra_format_fun) & !is.function(extra_format_fun)){
    cli::cli_abort("If provided, `extra_format_fun` must be a function.")
  }
  if(length(sheet.name) == 1){
    sheet.name = c(sheet.name, sheet.name)
  }

  f1 = readxl::read_excel(file.1, sheet = sheet.name[1], col_names = FALSE)
  f2 = readxl::read_excel(file.2, sheet = sheet.name[2], col_names = FALSE)

  #carry out sheet comparison
  sheet.comp = sheet_comp(f1, f2)

  ## create workbook
  wb = openxlsx::createWorkbook()
  ## add in our sheet, fill in with the comparison information
  openxlsx::addWorksheet(wb, sheetName = sheet.name)
  openxlsx::writeData(wb, sheet.name, x = sheet.comp$sheet.diff, colNames = FALSE, keepNA = FALSE)

  ## support adding in additional formatting
  if(! is.null(extra_format_fun)){
    extra_format_fun(wb, sheet.name, ...)
  }

  ## highlight cells that changes
  add_changed_formats(wb, cur.sheet = sheet.name, sheet.comp = sheet.comp)


  openxlsx::saveWorkbook(wb, file = results.name, overwrite = TRUE)
}



