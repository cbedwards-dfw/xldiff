#' Compare all pairwise combinations of list items for two lists of matching dimensions
#'
#' Intended to handle lists of vectors with matching dimensions; typically these will be generated from
#' [listify_sheet()]. Returns a matrix where each value is the proportion of items that match.
#'
#' @param list_1 list of items
#' @param list_2 list of items, same dimensions as `list_1`
#'
#'
#' @examples
#' list_1 = as.list(c("a", "b", "10"))
#' list_2 = as.list(c("a", "b", "11"))
#' compare_lists(list_1, list_2)

compare_lists <- function(list_1, list_2){
  level_1_compare = function(x, vec_cur){
    mean(vec_cur == x)
  }

  level_2_compare <- function(vec_cur, list_2){
    purrr::map_dbl(list_2, \(x) level_1_compare(x, vec_cur))
  }

  res <- purrr::map(list_1,\(x){level_2_compare(x, list_2)})

  do.call(rbind, res)
}

#' Processes a character atomic for easier comparisons
#'
#' Cleans up atomics read in from excel to make for more consistent comparisons.
#'
#' @details
#' Excel cells read into R are often read in as characters, and this can lead to funkiness
#' that might make it hard to compare to another version of the cell read in under funky conditions.
#' For example, miniscule numeric differences lead to different non-comparable character vectors. Further,
#' if a cell is formatted as % in one file and not in another, the raw versions read in from excel will
#' appear distinct.
#'
#' If the input is meant to be a character, the function will return a character. If the input is a number
#' that was read as a character, this function will, as appropriate (a) remove commas, (b) convert from
#' percent to numeric, and then round to the nearest `digits` digits (default: 10). The function will
#' then return this as a character (for easier application to vectors of mixed contents). If the input is
#' `NA`, this function returns "".
#'
#'
#'
#' @param x Atomic to clean. Recommend providing only characters.
#' @param digits Number of digits to round to. Defaults to 10.
#'
#' @return Character atomic
#' @export
#'
#' @examples
#' make_cell_comparable("1,503.999999999999995")
#' make_cell_comparable(NA)
#' make_cell_comparable("escapement")
#' make_cell_comparable("13.00000000000005%")
make_cell_comparable <- function(x, digits = 10){
  validate_integer(digits, n = 1 )
  # Skip if empty or NA
  if(is.na(x) || x == "") {
    return("")
  }
  mult = 1 ## for rapid rescaling when percent
  # Remove commas (for numbers like 1,000)
  x_clean <- gsub(",", "", x)
  if(grepl("%$", x_clean)) {
    x_clean <- sub("%$", "", x_clean)
    mult = .01
  }
  # Check if it's numeric (after removing commas)
  num_val <- suppressWarnings(as.numeric(x_clean))
  if(!is.na(num_val)) {
    return(as.character(round(num_val*mult, digits)))
  }
  # Otherwise, keep as character
  return(x)
}



#' Converts dataframe or matrix into list
#'
#' @param df dataframe or matrix
#' @param direction Should the function compare row-wise (1) or column-wise (2)
#' @param digits How many digits should numeric values be rounded to before comparing? Numeric, defaults to 10.
#'
#' @return list, where each item is a row (`direction = 1`) or a column (`direction = 2`) of argument `df`, with the values transformed using [make_cell_comparable()].
#' @export
#'
#' @examples
#' listify_sheet(mtcars, direction = 1)
#' listify_sheet(mtcars, direction = 2)
listify_sheet <- function(df, direction, digits = 10){

  rlang::arg_match(direction, values = 1:2)
  validate_integer(digits, n = 1)

  if(direction == 2){
    if(is.data.frame(df)){
      res <- as.list(df)
    } else {
      res <- apply(df, 2, list) |>
        purrr::flatten()
    }
  }
  if(direction == 1){
    res <- apply(df, 1, list) |>
      purrr::flatten()
  }
  res <- res |>
    purrr::map(
      \(x){make_vec_comparable(x, digits = digits)})
  return(res)
}

#' All row-wise or column-wise comparisons of two dataframes
#'
#' Intended for use on objects read in from excel, which may contain formatting complications.
#'
#'
#' @param df_1 First dataframe or matrix to compare
#' @param df_2 Second dataframe or matrix to compare
#' @inheritParams listify_sheet
#'
#' @return Matrix of all pairwise comparisons of columns or rows; values are the proportion of cells that match.
#' @export
#'
#' @examples
#' mat1 = matrix(rnorm(12), 3, 4)
#'
#' mat2 = mat1
#'
#' mat2[3,] = mat1[1,]
#' mat2[1,1] = 10
#'
#' make_alignment_matrix(mat1, mat2, 2)
make_alignment_matrix <- function(df_1, df_2, direction, digits = 10){
  rlang::arg_match(direction, values = 1:2)
  validate_integer(digits, n = 1)
  list_1 <- listify_sheet(df_1, direction, digits = digits)
  list_2 <- listify_sheet(df_2, direction, digits = digits)
  compare_lists(list_1, list_2)
}

