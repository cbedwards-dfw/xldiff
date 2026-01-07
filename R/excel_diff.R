#' Minimal spreadsheet comparison function
#'
#' Compares a single sheet between two files, creating a new file that uses the formatting of
#' the existing sheets (except highlighting) and highlights cells that differed.
#' Small numeric differences between cell values can be the result of happenstance ("decimal dust") - the `digits_signif` and `proportional.diff` arguments can control behavior to ignore minor numeric differences.
#'
#'
#'
#' @param file_1 Filename (including path) for first file to compare
#' @param file_2 Filename (including path) for second file to compare
#' @param results_name Name (including path) for file to save comparison to. Must end in ".xlsx"
#' @param sheet_name Character string of sheet to compare. Can provide vector of character strings to produce comparisons of multiple sheets.
#' @param sheet_name_file_2 OPTIONAL. Matching sheet names to `sheet_name` but for file 2. Use only if the two files have matching sheets with different names. Defaults to NULL.
#' @inheritParams sheet_comp
#' @param extra_width How much extra width should be added to columns that changed? Helpful to improve readability, since changed cells have longer entries. Numeric, defaults to 0.4.
#' @param verbose Should sheet names be listed as they are diffed? Logical, defaults to TRUE
#'
#' @seealso [excel_diff_table()], [excel_diff_tibble()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' filename_1 <- "Chin1124.xlsx"
#' filename_2 <- "Chin2524.xlsx"
#'
#' excel_diff(
#'   file_1 = filename_1,
#'   file_2 = filename_2,
#'   results.name = "Chin1124 vs Chin 2524.xlsx",
#'   sheet_name = "ER_ESC_Overview_New"
#' )
#' }
excel_diff <- function(file_1, file_2, results_name, sheet_name,
                       sheet_name_file_2 = NULL,
                       proportional_threshold = 0.001,
                       absolute_threshold = NULL,
                       digits_show = 6,
                       verbose = FALSE,
                       extra_width = NULL) {
  validate_character(file_1, n = 1)
  validate_character(file_2, n = 1)
  validate_character(results_name, n = 1)
  if (!all(grepl(".xls.?$", c(file_1, file_2, results_name)))) {
    cli::cli_abort("`file_1`, `file_2`, and `results_name` must end in `.xlsx` or `.xls`.")
  }
  validate_character(sheet_name)
  if (!is.null(sheet_name_file_2)) {
    validate_character(sheet_name_file_2)
  }
  if (!is.null(sheet_name_file_2) && (!is.character(sheet_name_file_2) | length(sheet_name_file_2) == length(sheet_name))) {
    cli::cli_abort("If provided, `sheet_name_file_2` must be a character string of the same length as `sheet_name`!")
  }
  validate_flag(verbose)
  ## thresholds validated in sheet_comp
  if(!is.null(extra_width)){
    validate_numeric(extra_width, n = 1, min = 0, max = 1)
  }

  if (is.null(sheet_name_file_2)) {
    sheet_name_file_2 <- sheet_name
  }

  ## The implementation here is indirect (copy sheet styles to empty sheet, cloning that to new workbook,
  ## adding in diff data)
  ## This gets around issues with excel files that have non-standard XML components,
  ## which is common in the excel files the FRAM team works with.

  wb <- openxlsx2::wb_load(file_1) |>
    ## add a temporary "style storage" sheet
    openxlsx2::wb_add_worksheet(sheet = "style_storage")
  wb2 <- openxlsx2::wb_load(file_2)

  wb_new <- openxlsx2::wb_workbook()

  ## sheet validation
  file_1_sheets <- wb |>
    openxlsx2::wb_get_sheet_names()
  file_2_sheets <- wb2 |>
    openxlsx2::wb_get_sheet_names()
  if (!all(sheet_name %in% file_1_sheets)) {
    cli::cli_abort("`sheet_name` must be in each file! The following sheet names are missing from file 1: {setdiff(sheet_name, file_1_sheets)}")
  }
  if (!all(sheet_name %in% file_1_sheets)) {
    cli::cli_abort("`sheet_name` must be in each file! The following sheet names are missing from file 2: {setdiff(sheet_name_file_2, file_2_sheets)}")
  }

  for (i.sheet in seq_along(sheet_name)) {
    if(verbose){
      cli::cli_alert("Diffing {sheet_name[i.sheet]}...")
    }
    wb <- wb |>
      openxlsx2::wb_clone_sheet_style(
        from = sheet_name[i.sheet],
        to = "style_storage"
      )

    f1 <- openxlsx2::wb_to_df(wb,
                              sheet = sheet_name[i.sheet],
                              col_names = FALSE,
                              na = NA
    )

    f2 <- openxlsx2::wb_to_df(wb2,
                              sheet = sheet_name_file_2[i.sheet],
                              col_names = FALSE,
                              na = NA
    )

    sheet_comp <- sheet_comp(f1, f2,
                             proportional_threshold = proportional_threshold,
                             absolute_threshold = absolute_threshold
    )

    all_dims <- dim(f1)
    all_dims_a1 <- openxlsx2::wb_dims(1:all_dims[1], 1:all_dims[2])

    suppressWarnings({
      wb_new <- wb_new |>
        openxlsx2::wb_clone_worksheet(
          old = "style_storage",
          new = sheet_name[i.sheet],
          from = wb
        )
    })
    wb_new <- wb_new |>
      openxlsx2::wb_add_fill(
        sheet = sheet_name[i.sheet],
        dims = all_dims_a1,
        color = NULL
      ) |>
      openxlsx2::wb_add_data(
        sheet = sheet_name[i.sheet],
        x = sheet_comp$sheet_diff, na = "",
        col_names = FALSE
      ) |>
      add_changed_formats(
        cur_sheet = sheet_name[i.sheet],
        sheet_comp = sheet_comp
      )

    ## widen columns with corrections in them
    if(!is.null(extra_width)){
      cols_changed <- (apply(sheet_comp$mat_changed, 2, any))
      col_widths <- wb_get_col_widths(wb, sheet = sheet_name[i.sheet])
      new_widths <- col_widths$width[1:length(cols_changed)] * (1 + extra_width * cols_changed)

      wb_new <- wb_new |>
        openxlsx2::wb_set_col_widths(sheet = sheet_name[i.sheet], cols = 1:length(new_widths), widths = new_widths)
    }
  }

  suppressWarnings({
    openxlsx2::wb_save(wb_new, file = results_name, overwrite = TRUE)
  })
}
