#' Compare two sheets to see if formula use changed
#'
#' Identifies if one or more cells changed from having a formula to not between two excel sheets.
#'
#' @inheritParams excel_diff
#'
#' @return invisibly returns dataframe of the cell address and before/after formulas for cases in which a formula was present in both files but differed.
#' @export
#'
#' @examples
#' \dontrun{
#' formula_diff(
#'   file_1 = "CohoPugetSoundTAMMInputTemplate2025.xlsx",
#'   file_2 = "CohoPugetSoundTAMMInputs 2025 v1.5.xlsx",
#'   sheet_name = "Input_Harvestnew"
#' )
#' }
formula_diff <- function(file_1, file_2, sheet_name) {
  validate_character(file_1, n = 1)
  validate_character(file_2, n = 1)
  validate_character(sheet_name)


  res_ls = list()
  for(i.sheet in 1:length(sheet_name)){
    cli::cli_h1("Looking for formula discrepencies in sheet \"{sheet_name[i.sheet]}\" between \n{.file {basename(file_1)}} and {.file {basename(file_2)}}.")
    cat("\n")

    ## tidy
    sheet1 <- tidyxl::xlsx_cells(file_1, sheet_name[i.sheet])
    sheet2 <- tidyxl::xlsx_cells(file_2, sheet_name[i.sheet])

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

    differing_df <- address_s1 |>
      dplyr::full_join(address_s2, by = "address", suffix = c("_1", "_2")) |>
      dplyr::filter(.data$formula_1 != .data$formula_2 |
                      is.na(.data$formula_1) |
                      is.na(.data$formula_2)) |>
      dplyr::mutate(sheet = sheet_name[i.sheet])

    differing_formulas_df <- differing_df |>
      na.omit()

    if(length(sheet_name) == 1){
      cli::cli_h2("Checking for changes in formula status (was formula in one sheet, not in the other)")
      if (length(address_s1$address) == length(address_s2$address) &&
          all(address_s1$address == address_s2$address)) {
        cli::cli_alert_success("All {nrow(address_s1)} formula cells in sheet \"{sheet_name[i.sheet]}\" of `{basename(file_1)}` are also formulas in `{basename(file_2)}`.")
      } else {
        cli::cli_alert_warning("MISMATCHES FOUND!")
        cli::cli_alert("{.strong {nrow(address_s1)}} cells are formulas in `{basename(file_1)}`, {.strong {nrow(address_s2)}} are in `{basename(file_2)}`.")
        cli::cli_alert_warning("{length(setdiff(address_s1$address, address_s2$address))} cells are formulas in `{basename(file_1)}` and not in `{basename(file_2)}`:\n{.emph {setdiff(address_s1$address, address_s2$address)}}")
        cli::cli_alert_warning("{length(setdiff(address_s2$address, address_s1$address))} cells  are formulas `{basename(file_2)}` and not in `{basename(file_1)}`:\n{.emph {setdiff(address_s2$address, address_s1$address)}}")
      }
      cli::cli_h2("Checking for changes in formulas for cells that were formulas in both sheets:")

      if (nrow(differing_formulas_df) == 0) {
        cli::cli_alert_success("For cells that were formulas in both files, those formulas always matched.")
      } else {
        cli::cli_alert_warning("MISMATCHES FOUND!")
        cli::cli_alert_warning("{nrow(differing_formulas_df)} cells have differing formulas between the two files:\n{.emph {differing_formulas_df$address} }")
      }

    }
    res_ls[[i.sheet]] = differing_df
  }
  res = do.call(rbind, res_ls)
  if(length(sheet_name) == 1){
    return(invisible(differing_df))
  } else {
    if(nrow(res) == 0){
      cli::cli_alert_success("No formula differces identified between any sheets examined!")
    } else{
      cli::cli_alert_warning("{nrow(res)} discrepencies found across sheets {unique(res$sheet)}! See output for details!")
    }
    return(res)
  }
}
