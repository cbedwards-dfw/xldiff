#' Diff excel sheets and show table
#'
#' Similar to excel_diff, but returns flextable that can be displayed and navigated in the Rstudio viewer. Only shows rows that have changed. For every row with changes, provides a row of before and after, highlighting changed vlaues (red for the value in file_1, green for the value in file_2)."ROWS" column identifies excel row number and columns identify excel column names. Defaults to flagging changes of at least 0.1% from `file_1` to `file_2` (`proportional.diff = TRUE`, `digits.signif = 3`).
#'
#' @inheritParams excel_diff
#' @param sheet_name Character string of a single excel sheet to compare between the files. (Unlike `excel_diff`, only one sheet can be compared at a time)
#' @inheritParams sheet_comp
#'
#' @seealso [excel_diff()], [excel_diff_tibble()]
#'
#' @return flextable object.
#' @export
#'
#' @examples
#' \dontrun{
#' excel_diff_table(
#'   file_1 = "C:/Repos/test file 1.xlsx",
#'   file_2 = "C:/Repos/test file 2.xlsx",
#'   sheet = "Sheet1"
#' )
#' }
excel_diff_table <- function(file_1,
                             file_2,
                             sheet_name,
                             proportional_threshold = 0.001,
                             absolute_threshold = NULL,
                             digits_show = 6) {
  validate_character(file_1, n = 1)
  validate_character(file_2, n = 1)
  if (!all(grepl(".xlsx$", c(file_1, file_2)))) {
    cli::cli_abort("`file_1` and `file_2` must end in `.xlsx`.")
  }
  validate_character(sheet_name, n = 1)
  validate_numeric(proportional_threshold, n = 1, min = 0)
  if (!is.null(absolute_threshold)) {
    validate_numeric(absolute_threshold, n = 1, min = 0)
  }
  validate_integer(digits_show, n = 1)

  f1 <- readxl::read_excel(file_1, sheet = sheet_name, col_names = FALSE, .name_repair = "unique_quiet")
  f2 <- readxl::read_excel(file_2, sheet = sheet_name, col_names = FALSE, .name_repair = "unique_quiet")

  diff_to_table(
    df1 = f1,
    df2 = f2,
    proportional_threshold = proportional_threshold,
    absolute_threshold = absolute_threshold,
    digits_show = digits_show,
    dfnames = c(file_1, file_2),
    excelify_col_names = TRUE
  )
}


#' Compares two dataframes and returns diff as flextable
#'
#' Workhorse function for `excel_diff_table()`. Can be used to diff any pair of dataframes or tibbles. Diff is applied cell by cell, so results will only be meaningful if the shape of the two objects is the same.
#'
#' @param df1 first dataframe or tibble
#' @param df2 second dataframe or tibble
#' @inheritParams sheet_comp
#' @param dfnames Character vector with names of the two dataframes to use for table title. Optional.
#' @param excelify_col_names Should columns be identified by excel letter convention? Defaults to FALSE. Set to TRUE when comparing dataframes extracted from excel sheets.
#'
#' @return flextable object
#' @export
#'
#' @examples
#' df1 <- mtcars
#' df2 <- mtcars
#' df2[2, 2] <- -8
#' df2[5, c(3, 4)] <- c(11, 15)
#' diff_to_table(df1, df2)
diff_to_table <- function(df1, df2,
                          proportional_threshold = 0.001,
                          absolute_threshold = NULL,
                          digits_show = 6,
                          dfnames = NULL, excelify_col_names = FALSE) {
  sheet_comp_simple <- sheet_comp(df1, df2,
    proportional_threshold = proportional_threshold,
    absolute_threshold = absolute_threshold,
    digits_show = digits_show
  )$mat_changed

  rows_mod <- which(apply(sheet_comp_simple, 1, any))

  if (length(rows_mod) == 0) {
    cli::cli_alert_success("No differences detected")
    tab_use <- flextable::flextable(data = data.frame(results = "No difference detected"))
  } else {
    ## the following will be reformed as dfs, just using lists for speed
    diff_ls <- list()
    ## note: these should be pairs of row/cols for highlighting
    highlight_red_ls <- list()
    highlight_green_ls <- list()
    i_row <- 1

    for (i in 1:length(rows_mod)) {
      cur_row <- rows_mod[[i]]
      diff_ls[[i]] <- cbind(
        ROW = rep(cur_row, 2), ## adding identifier column
        dplyr::bind_rows(
          df1[cur_row, ],
          df2[cur_row, ]
        )
      )

      highlight_red_ls[[i]] <- data.frame(
        rows = rep(i_row, sum(sheet_comp_simple[cur_row, ])),
        cols = which(sheet_comp_simple[cur_row, ]) + 1
      ) ## accounting for new identifier column
      highlight_green_ls[[i]] <- highlight_red_ls[[i]] |>
        dplyr::mutate(rows = .data$rows + 1)
      i_row <- i_row + 2 ## one each for initial and final
    }

    diff_df <- do.call(rbind, diff_ls)
    highlight_red_df <- do.call(rbind, highlight_red_ls)
    highlight_green_df <- do.call(rbind, highlight_green_ls)

    if (excelify_col_names) {
      names(diff_df) <- c(
        "ROW",
        apply(tidyr::expand_grid(c("", LETTERS), LETTERS),
          1, paste0,
          collapse = ""
        )
      )[1:ncol(diff_df)]
    }

    if (is.null(dfnames)) {
      tab_title <- "Diff table"
    } else {
      tab_title <- flextable::as_paragraph(
        flextable::as_chunk(
          glue::glue("Diff of {basename(dfnames[1])}\n")
        ),
        flextable::as_chunk(
          glue::glue("  to {basename(dfnames[2])}")
        )
      )
    }

    tab_use <- diff_df |>
      flextable::flextable() |>
      flextable::vline(j = 1) |>
      flextable::set_caption(
        caption = tab_title
      )
    if (nrow(diff_df) > 2) {
      tab_use <- tab_use |>
        flextable::hline(i = (1:(nrow(diff_df) / 2 - 1)) * 2)
    }

    for (i_row in 1:nrow(highlight_green_df)) {
      tab_use <- tab_use |>
        flextable::highlight(
          i = highlight_green_df$rows[i_row],
          j = highlight_green_df$cols[i_row],
          color = "#9beeb4"
        ) |>
        flextable::highlight(
          i = highlight_red_df$rows[i_row],
          j = highlight_red_df$cols[i_row],
          color = "#ffbfbd"
        )
    }
  }
  return(tab_use)
}
