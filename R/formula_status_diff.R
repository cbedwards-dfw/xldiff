#' Compare two sheets to see if formula use changed
#'
#' Identifies if one or more cells changed from having a formula to not between two excel sheets.
#'
#' @inheritParams excel_diff_table
#'
#' @return Nothing
#' @export
#'
#' @examples
#' \dontrun{
#' formula_status_diff(
#'   file_1 = "CohoPugetSoundTAMMInputTemplate2025.xlsx",
#'   file_2 = "CohoPugetSoundTAMMInputs 2025 v1.5.xlsx",
#'   sheet_name = "Input_Harvestnew"
#' )
#' }
formula_status_diff <- function(file_1, file_2, sheet_name) {
  validate_character(file_1, n = 1)
  validate_character(file_2, n = 1)
  validate_character(sheet_name, n = 1)

  cli::cli_h1("Looking for formula discrepencies in sheet \"{sheet_name}\" between \n{.file {basename(file_1)}} and {.file {basename(file_2)}}.")
  cat("\n")

  ## tidy
  sheet1 <- tidyxl::xlsx_cells(file_1, sheet_name)
  sheet2 <- tidyxl::xlsx_cells(file_2, sheet_name)

  address_s1 <- sheet1 |>
    dplyr::filter(!is.na(.data$formula)) |>
    dplyr::select("address", "formula") |>
    dplyr::arrange(.data$address)

  address_s2 <- sheet2 |>
    dplyr::filter(!is.na(.data$formula)) |>
    dplyr::select("address", "formula") |>
    dplyr::arrange(.data$address)
  cli::cli_div(theme = list(
    span.file = list(color = "lightblue"),
    span.emph = list(color = "blue")
  ))

  cli::cli_h2("Checking for changes in formula status (was formula in one sheet, not in the other)")
  if (length(address_s1$address) == length(address_s2$address) &&
    all(address_s1$address == address_s2$address)) {
    cli::cli_alert_success("All {nrow(address_s1)} formula cells in sheet \"{sheet_name}\" of `{basename(file_1)}` are also formulas in `{basename(file_2)}`.")
  } else {
    cli::cli_alert_warning("MISMATCHES FOUND!")
    cli::cli_alert("{.strong {nrow(address_s1)}} cells are formulas in `{basename(file_1)}`, {.strong {nrow(address_s2)}} are in `{basename(file_2)}`.")
    cli::cli_alert_warning("{length(setdiff(address_s1$address, address_s2$address))} cells are formulas in `{basename(file_1)}` and not in `{basename(file_2)}`:\n{.emph {setdiff(address_s1$address, address_s2$address)}}")
    cli::cli_alert_warning("{length(setdiff(address_s2$address, address_s1$address))} cells  are formulas `{basename(file_2)}` and not in `{basename(file_1)}`:\n{.emph {setdiff(address_s2$address, address_s1$address)}}")
  }
  cli::cli_h2("Checking for changes in formulas for cells that were formulas in both sheets:")

  differing_formulas_df <- address_s1 |>
    dplyr::inner_join(address_s2, by = "address", suffix = c("_1", "_2")) |>
    dplyr::filter(.data$formula_1 != .data$formula_2)
  if (nrow(differing_formulas_df) == 0) {
    cli::cli_alert_success("For cells that were formulas in both files, those formulas always matched.")
  } else {
    cli::cli_alert_warning("MISMATCHES FOUND!")
    cli::cli_alert_warning("{nrow(differing_formulas_df)} cells have differing formulas between the two files:\n{.emph {differing_formulas_df$address} }")
  }

  return(invisible(differing_formulas_df))
}
