#' Add NA rows or columns to either of two dataframes to give same dimensions
#'
#' @param df1 dataframe or matrix
#' @param df2 dataframe or matrix
#'
#' @return list, with padded version of `df1` as first item and padded version of `df2` as second item
#' @export
#'
#' @examples
#'   mat1 <- mtcars[c(1,1,5),]
#'   mat2 <- mtcars[c(1,5), ]
#'   res <- pad_sheets(mat1, mat2)
pad_sheets <- function(df1, df2){

  row_diff <- nrow(df1) - nrow(df2)
  if(row_diff>0){
    df2[nrow(df2) + 1:row_diff, ] <- NA
  }
  if(row_diff<0){
    df1[nrow(df1) + 1:(-1 * (row_diff)), ] <- NA
  }

  col_diff <- ncol(df1) - ncol(df2)

  if(col_diff>0){
    df2[ , ncol(df2) + 1:col_diff ] <- NA
  }
  if(col_diff<0){
    df1[, ncol(df1) + 1:(-1 * (col_diff)) ] <- NA
  }

  return(list(df1, df2))

}

## aligns FIRST matrix to maximize matchingness with SECOND matrix.
## For use in excel diff, want to provide SECOND sheet as FIRST argument
#' Re-arrange rows of one matrix or dataframe to maximize similarity to a second.
#'
#'  Re-arranges rows of first input to maximize similarity with second matrix.
#'  `sheet_to_change` and `sheet_to_match` must have the same dimensions.
#'
#'  Re-arrangement is ordered by calculating similarity using `make_alignment_matrix` and then solving this as a linear sum assignment problem using the Hungarian method.
#'
#' @param sheet_to_change Dataframe or matrix that should be arranged.
#' @param sheet_to_match Dataframe or matrix to compare against. Must have same dimensions as `sheet_to_change`.
#' @param verbose Warn if re-arranging? Logical, defaults to FALse
#'
#' @return re-arrange version of `sheet_to_change`
#' @export
#'
#' @examples
#'   ## example problem:
#'   ## two versions of a datafame that almost
#'   ##    match aside from the first dataframe containing an extra row of NAs
#'   mat1 <- mtcars[c(1,1,5),]
#'   mat1[2, ] = NA
#'   mat2 <- mtcars[c(1,5), ]
#'   mat2[1,1] = 10
#'
#'   res <- pad_sheets(mat1, mat2)
#'   temp <- align_rows(res[[1]], res[[2]])
#'   temp <- align_rows(res[[1]], res[[2]], verbose = TRUE)
align_rows <- function(sheet_to_change,
                       sheet_to_match,
                       verbose = FALSE){
  align_mat <- make_alignment_matrix(sheet_to_change, sheet_to_match, direction = 1)
  best_order <- as.numeric(clue::solve_LSAP(align_mat, maximum = TRUE))
  if(any(best_order != 1:length(best_order)) & verbose){
    cli::cli_alert("Rows re-aligned for better comparisons. Likely 1 or more blank rows different between sheets.")
  }
  sheet_to_change <- sheet_to_change[best_order,]
  return(sheet_to_change = sheet_to_change)
}

