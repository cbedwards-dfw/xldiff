#' Compare two sheets to see if formula use changed
#'
#' Identifies if one or more cells changed from having a formula to not between two excel sheets.
#'
#' @inheritParams excel_diff
#'
#' @return Nothing
#' @export
#'
#' @examples
#' \dontrun{
#' formula_status_diff(file.1 = "CohoPugetSoundTAMMInputTemplate2025.xlsx",
#'    file.2 = "CohoPugetSoundTAMMInputs 2025 v1.5.xlsx",
#'    sheet.name = "Input_Harvestnew")
#' }
formula_status_diff = function(file.1, file.2, sheet.name){

  ## To support differing sheet names, sheet.name must be vector with length 2
  if(length(sheet.name) == 1){
    sheet.name = c(sheet.name, sheet.name)
  }

  ## tidy
  sheet1 = tidyxl::xlsx_cells(file.1, sheet.name[1])
  sheet2 = tidyxl::xlsx_cells(file.2, sheet.name[2])

  address_s1 = sheet1 |>
    dplyr::filter(!is.na(.data$formula)) |>
    dplyr::pull(.data$address)

  address_s2 = sheet2 |>
    dplyr::filter(!is.na(.data$formula)) |>
    dplyr::pull(.data$address)
  cli::cli_div(theme = list(span.file = list(color = "lightblue"),
                            span.emph = list(color = "blue")))
  cli::cli_alert_info("Checking for changes in formula status (was formula in one sheet, not in the other)")
  cli::cli_alert_info("Comparing between \n{.file {file.1}} sheet {sheet.name[1]}\n and \n{.file {file.2}} sheet {sheet.name[2]}.")
  cli::cli_alert_info("...")
  cli::cli_alert("{.strong {length(address_s1)}} cells are formulas in sheet 1, {.strong {length(address_s2)}} are in sheet 2.")
  cli::cli_alert("Cells that are formulas in sheet 1 and not in sheet 2:\n{.emph {setdiff(address_s1, address_s2)}}")
  cli::cli_alert("Cells that are formulas in sheet 2 and not in sheet 1:\n{.emph {setdiff(address_s2, address_s1)}}")
}
