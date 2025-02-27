#' Diff excel sheets and show table
#'
#' Similar to excel_diff, but returns flextable that can be displayed and navigated in the Rstudio viewer. Only shows rows that have changed. For every row with changes, provides a row of before and after, highlighting changed vlaues (red for the value in file.1, green for the value in file.2)."ROWS" column identifies excel row number and columns identify excel column names.
#'
#' @inheritParams excel_diff
#'
#' @return flextable object.
#' @export
#'
#' @examples
#' \dontrun{
#' excel_diff_table(file.1 = "C:/Repos/test file 1.xlsx",
#'file.2 = "C:/Repos/test file 2.xlsx",
#'sheet = "Sheet1")
#'}
excel_diff_table <- function(file.1, file.2, sheet.name){

  if(!all(grepl(".xlsx$", c(file.1, file.2)))){
    cli::cli_abort("`file.1` and `file.2` must end in `.xlsx`.")
  }

  if(length(sheet.name) == 1){
    sheet.name = c(sheet.name, sheet.name)
  }

  f1 = readxl::read_excel(file.1, sheet = sheet.name[1], col_names = FALSE)
  f2 = readxl::read_excel(file.2, sheet = sheet.name[2], col_names = FALSE)

  diff_to_table(f1, f2, dfnames = c(file.1, file.2),
                excelify.col.names = TRUE)
}


#' Compares two dataframes and returns diff as flextable
#'
#' Workhorse function for `excel_diff_table()`. Can be used to diff any pair of dataframes or tibbles. Diff is applied cell by cell, so results will only be meaningful if the shape of the two objects is the same.
#'
#' @param df1 first dataframe or tibble
#' @param df2 second dataframe or tibble
#' @param dfnames Character vector with names of the two dataframes to use for table title. Optional.
#' @param excelify.col.names Should columns be identified by excel letter convention? Defaults to FALSE. Set to TRUE when comparing dataframes extracted from excel sheets.
#'
#' @return flextable object
#' @export
#'
#' @examples
#' df1 = mtcars
#' df2 = mtcars
#' df2[2,2] = -8
#' df2[5, c(3,4)] = c(11, 15)
#' diff_to_table(df1, df2)
diff_to_table = function(df1, df2, dfnames = NULL, excelify.col.names = FALSE){
  sheet.comp <- sheet_comp(df1, df2)

  rows.mod = which(apply(sheet.comp$mat.changed, 1, any))

  ## the following will be reformed as dfs, just using lists for speed
  diff.ls = list()
  ## note: these should be pairs of row/cols for highlighting
  highlight.red.ls = list()
  highlight.green.ls = list()
  i.row = 1

  for(i in 1:length(rows.mod)){
    cur.row = rows.mod[[i]]
    diff.ls[[i]] = cbind(ROW = rep(cur.row, 2), ##adding identifier column
                         dplyr::bind_rows(df1[cur.row,],
                                          df2[cur.row,])
    )

    highlight.red.ls[[i]] = data.frame(rows = rep(i.row, sum(sheet.comp$mat.changed[cur.row,])),
                                       cols = which(sheet.comp$mat.changed[cur.row,])+1) ##accounting for new identifier column
    highlight.green.ls[[i]] = highlight.red.ls[[i]] |>
      dplyr::mutate(rows = .data$rows+1)
    i.row = i.row + 2 ## one each for initial and final
  }

  diff.df = dplyr::bind_rows(diff.ls)
  highlight.red.df = dplyr::bind_rows(highlight.red.ls)
  highlight.green.df = dplyr::bind_rows(highlight.green.ls)

  if(excelify.col.names){
    names(diff.df) = c("ROWS",
                       apply(tidyr::expand_grid(c("", LETTERS), LETTERS),
                             1, paste0, collapse = ""))[1:ncol(diff.df)]
  }

  if(is.null(dfnames)){
    tab.title = "Diff table"
  }else{
    tab.title = paste0("Diff of ", dfnames[1], " to ", dfnames[2])
  }
  tab.use = diff.df |>
    flextable::flextable() |>
    flextable::hline(i = (1:(nrow(diff.df)/2-1))*2) |>
    flextable::vline(j = 1) |>
    flextable::set_caption(tab.title)

  for(i.row in 1:nrow(highlight.green.df)){
    tab.use <- tab.use |>
      flextable::highlight(i = highlight.green.df$rows[i.row],
                           j = highlight.green.df$cols[i.row],
                           color = "#9beeb4") |>
      flextable:: highlight(i = highlight.red.df$rows[i.row],
                            j = highlight.red.df$cols[i.row],
                            color = "#ffbfbd")
  }
  return(tab.use)
}
