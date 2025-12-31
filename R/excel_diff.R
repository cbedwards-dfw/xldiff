#' Minimal spreadsheet comparison function
#'
#' Compares a single sheet between two files, creating a new file that uses the formatting of
#' the existing sheets (except highlighting) and highlights cells that differed.
#' Small numeric differences between cell values can be the result of happenstance ("decimal dust") - the `digits.signif` and `proportional.diff` arguments can control behavior to ignore minor numeric differences.
#'
#' @param file.1 Filename (including path) for first file to compare
#' @param file.2 Filename (including path) for second file to compare
#' @param results.name Name (including path) for file to save comparison to. Must end in ".xlsx"
#' @param sheet.name character string of sheet to compare. If the sheets have different names (or to compare two sheets in one file), can take a character vector of length two, with the sheet names from the first and second file in order. In this case, the results file will use the first of the sheet names.
#' @param digits.signif Numeric, controls the amount of difference a number needs to have to be identified as differing between the two sheets. When `proportional.diff = TRUE`, defines proportional change that triggers a "diff" status, where the number is the number of digits of the proportion (2 = 1% difference, 3 = 0.1% difference, 4 = 0.01% difference). When `proportional.diff = FALSE`, defines the absolute difference that triggers a difference, in digits of round (1 = 0.1 difference, 2 = 0.01 difference, 3 = 0.001).
#' @param proportional.diff Should minor differences between cells be judged on an absolute basis (`FALSE`) or a proportional basis (`TRUE`). `FALSE` is useful for identifying a level of decimal dust that we don't want to worry about when diff-ing (e.g., "If the differences is in the 1000ths place or smaller, I don't care"). `TRUE` is useful when a sheet contains values of varying magnitudes, as it allows specifying proprotional changes that should be ignored when diffing (e.g., "If the value changed by less than 0.1%, I don't care).
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' filename.1 = "Chin1124.xlsx"
#' filename.2 = "Chin2524.xlsx"
#'
#' excel_diff(file.1 = filename.1,
#'           file.2 = filename.2,
#'           results.name = "Chin1124 vs Chin 2524.xlsx",
#'           sheet.name = "ER_ESC_Overview_New"
#' )
#' }

excel_diff = function(file.1, file.2, results.name, sheet.name,
                      digits.signif = 3,
                      proportional.diff = TRUE){

  if(!all(grepl(".xls.?$", c(file.1, file.2, results.name)))){
    cli::cli_abort("`file.1`, `file.2`, and `results.name` must end in `.xlsx` or `.xls`.")
  }

  if(length(sheet.name) == 1){
    sheet.name = c(sheet.name, sheet.name)
  }

  wb <- openxlsx2::wb_load(file.1, sheet = sheet.name[1])
  wb2 <- openxlsx2::wb_load(file.2, sheet = sheet.name[2])

  f1 = openxlsx2::wb_to_df(wb,
                           sheet = sheet.name[1],
                           col_names = FALSE,
                           na = NA)

  f2 = openxlsx2::wb_to_df(wb2,
                           sheet = sheet.name[2],
                           col_names = FALSE,
                           na = NA)

  sheet.comp = sheet_comp(f1, f2,
                          digits.signif = digits.signif,
                          proportional.diff = proportional.diff)

  all_dims <- dim(f1)
  all_dims_a1 <-  openxlsx2::wb_dims(1:all_dims[1], 1:all_dims[2])

  wb_new <- wb |>
    openxlsx2::wb_add_fill(sheet = sheet.name[1],
                dims = all_dims_a1,
                color = NULL) |>
    openxlsx2::wb_add_data(sheet = sheet.name[1],
                x = sheet.comp$sheet.diff, na = "",
                col_names = FALSE) |>
    add_changed_formats(cur.sheet = sheet.name[1],
                        sheet.comp = sheet.comp)

  openxlsx2::wb_save(wb_new, file = results.name, overwrite = TRUE)
}



