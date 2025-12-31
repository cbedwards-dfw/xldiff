#' Compare two dataframes of spreadsheets
#'
#' Primary funtion for `xldiff` package. When cell values change between dataframe `t1` and
#' dataframe `t2`, the corresponding `$sheet_diff` entry will show \[the first value\] `--> ` \[the second value\].
#' Note that because these changes are presenting as characters, changes in numbers with many digits can produce difficult-to-read cells.
#' The `proportional_threshold` (or optionally `absolute_threshold`) can be used to determine how big a change should be to be flagged. `digits_show` controls how many significant digits should be used when showing the diffs. For example, `proportional_threshold = 0.01` and `digits_show = 5` will flag changes of at least 1%, and when those changes are present, the flagged cell will simplify the numbers to 5 significant digits when showing `## -> ##`.
#'
#' @param t1 First dataframe
#' @param t2 Second dataframe, same dimensions as first.
#' @param proportional_threshold Sets a threshold of proportional change below which differences should be ignored. For example, a value of 0.1 means any changes less than 10% will not be flagged as having changed. `proportional_threshold` will override this value and behavior if it is provided. Numeric, defaults to 0.001 (0.1% change).
#' @param absolute_threshold Optional. Sets a threshold of absolute change below which differences should be ignored. For example, a value of 0.1 means any changes less than 0.1 will not be flagged as having changed. If provided, will override `proportional_threshold`. Numeric, defaults to NULL.
#' @param digits_show When there is a change in number values, how many digits should be shown in `## ---> ##`? Numeric, defaults to 6. Recommend not making this so small that flagged changes don't get printed (e.g., if this is 2 and `proportional_threshold` is 0.001, 0.1% changes will get flagged, but only the first two digits will get shown).
#'
#' @return List of comparison data frames, including logical matrices used in formatting cells to
#' highlight changes.
#'    - `$sheet_diff`: cell entries for comparison
#'    - `$mat_changed` logical matrix where `TRUE` corresponds to a cell that changed
#'    - `$mat_diff_decrease`: logical matrix where `TRUE` corresponds to a cell of numeric values that decreased
#'    = `mat_diff_increase`: as above, but for increases.
#' @export
#'
#' @examples
#' \dontrun{
#' ## using palmerpenguins data to simulate spreadsheets
#' library(palmerpenguins)
#' t1 <- t2 <- head(penguins)
#' ## change island variable to characters for easier modification
#' t2$island <- t1$island <- as.character(t1$island)
#' ## change several entries in the second version
#' t2$island[3] <- "Scotland"
#' t2$flipper_length_mm[1] <- 18
#' sheet_comp(t1, t2)
#' }
sheet_comp <- function(t1, t2, proportional_threshold = 0.001, absolute_threshold = NULL, digits_show = 6) {
  if (!(all(dim(t1) == dim(t2)))) {
    cli::cli_abort("Dataframes `t1` and `t2` must have the same dimensions")
  }

  validate_numeric(proportional_threshold, n = 1, min = 0)
  if (!is.null(absolute_threshold)) {
    validate_numeric(absolute_threshold, n = 1, min = 0)
  }
  validate_integer(digits_show, n = 1)

  mat1 <- as.matrix(t1)
  mat2 <- as.matrix(t2)

  ## cut out extraneous NAs now
  mat1 <- mat1[1:max(which(!apply(mat1, 1, function(x) {
    all(is.na(x))
  }))), ]
  mat2 <- mat2[1:max(which(!apply(mat2, 1, function(x) {
    all(is.na(x))
  }))), ]

  ## translate NAs for better comparison
  mat1[is.na(mat1)] <- "**NA**"
  mat2[is.na(mat2)] <- "**NA**"

  ## find differences
  mat_diff <- (mat1 != mat2)
  ## find which values can be treated as numbers and which can't
  mat_numbers <- suppressWarnings(!is.na(as.numeric(mat1)) & !is.na(as.numeric(mat2)))
  mat_numbers_percents <- suppressWarnings(!is.na(as.numeric(gsub("%$", "", mat1))) &
    !is.na(as.numeric(gsub("%$", "", mat2))))
  mat_numbers_percents <- mat_numbers_percents & !mat_numbers


  if (is.null(absolute_threshold)) {
    mat_denominator_zero <- suppressWarnings(!is.na(as.numeric(mat1)) &
      !is.na(as.numeric(mat2)) &
      mat1 == 0)
    suppressWarnings({
      diff_vec_nums <- comparify_nums(mat2[mat_numbers]) /
        comparify_nums(mat1[mat_numbers])
    })
    diff_vec <- (abs(diff_vec_nums) - 1) > proportional_threshold
    mat_diff[mat_numbers] <- diff_vec

    suppressWarnings({
      diff_vec_nums <- comparify_nums(gsub("%$", "", mat2)[mat_numbers_percents]) /
        comparify_nums(gsub("%$", "", mat1)[mat_numbers_percents])
    })
    diff_vec <- (abs(diff_vec_nums) - 1) > proportional_threshold
    mat_diff[mat_numbers_percents] <- diff_vec

    # handling cases when denominator is 0
    mat_denominator_zero <- suppressWarnings(!is.na(as.numeric(mat1)) &
      !is.na(as.numeric(mat2)) &
      mat1 == 0)
    mat_diff[mat_denominator_zero] <-
      as.numeric(mat2[mat_denominator_zero]) > proportional_threshold

    ## handles cases when denominator is 0 and %s: pretend is absolute threshold
    mat_denominator_zero <-
      suppressWarnings(!is.na(as.numeric(gsub("%$", "", mat1))) &
        !is.na(as.numeric(gsub("%$", "", mat2))) &
        !mat_numbers &
        as.numeric(gsub("%$", "", mat1) != 0))

    mat_diff[mat_denominator_zero] <-
      abs(as.numeric(gsub("%$", "", mat2)[mat_denominator_zero])) > proportional_threshold
  } else {
    ## use absolute_threshold
    mat_diff[mat_numbers] <- as.numeric(mat1[mat_numbers]) -
      as.numeric(mat2[mat_numbers]) > absolute_threshold

    mat_diff[mat_numbers_percents] <- suppressWarnings(
      abs(as.numeric(gsub("%$", "", mat1)[mat_numbers_percents]) -
        as.numeric(gsub("%$", "", mat2)[mat_numbers_percents])) > absolute_threshold
    )
  }

  ## find indices for changes that are text and are numeric
  ind_diff_text <- which(mat_diff & !mat_numbers)
  ind_diff_num <- which(mat_diff & mat_numbers)
  ind_diff_num_percents <- which(mat_diff & mat_numbers_percents)

  mat_new <- mat1
  mat_new[ind_diff_text] <- paste0(
    mat1[ind_diff_text], " --> ",
    mat2[ind_diff_text]
  )

  mat_new[ind_diff_num] <- paste0(
    signif(as.numeric(mat1[ind_diff_num]), digits_show), " --> ",
    signif(as.numeric(mat2[ind_diff_num]), digits_show)
  )
  mat_new[ind_diff_num_percents] <- suppressWarnings(
    paste0(
      signif(
        as.numeric(gsub("%$", "", mat1)[ind_diff_num_percents]),
        digits_show
      ), "% --> ",
      signif(as.numeric(as.numeric(gsub("%$", "", mat2))[ind_diff_num_percents]), digits_show), "%"
    )
  )

  mat_new[mat_new == "**NA**"] <- NA

  ## store matrices for style differences
  mat_diff_text <- mat_diff & !mat_numbers
  mat_diff_decrease <- mat_diff_increase <- matrix(FALSE,
    nrow = nrow(mat1),
    ncol = ncol(mat1)
  )
  mat_diff_decrease[ind_diff_num] <- mat1[ind_diff_num] > mat2[ind_diff_num]
  mat_diff_increase[ind_diff_num] <- mat1[ind_diff_num] < mat2[ind_diff_num]

  if (length(ind_diff_num_percents) > 0) {
    mat_diff_decrease[ind_diff_num_percents] <- gsub("%$", "", mat1[ind_diff_num_percents]) >
      gsub("%$", "", mat2[ind_diff_num_percents])
    mat_diff_increase[ind_diff_num_percents] <- gsub("%$", "", mat1[ind_diff_num_percents]) <
      gsub("%$", "", mat2[ind_diff_num_percents])
  }
  ## clear extraneous NAs from bottom of each matrix


  return(list(
    sheet_diff = mat_new,
    mat_changed = mat_diff,
    mat_diff_text = mat_diff_text,
    mat_diff_decrease = mat_diff_decrease,
    mat_diff_increase = mat_diff_increase
  ))
}

comparify_nums <- function(x) {
  as.numeric(x) + sign(as.numeric(x)) / 1000
}

#' Stripped down version of sheet_comp
#'
#' Compares for perfect match, returns single matrix
#'
#' @inheritParams sheet_comp
#'
#' @return logical matrix
#'
sheet_comp_basic <- function(t1, t2) {
  if (!(all(dim(t1) == dim(t2)))) {
    cli::cli_abort("Dataframes `t1` and `t2` must have the same dimensions")
  }

  mat1 <- as.matrix(t1)
  mat2 <- as.matrix(t2)

  ## cut out extraneous NAs now
  mat1 <- mat1[1:max(which(!apply(mat1, 1, function(x) {
    all(is.na(x))
  }))), ]
  mat2 <- mat2[1:max(which(!apply(mat2, 1, function(x) {
    all(is.na(x))
  }))), ]

  ## translate NAs for better comparison
  mat1[is.na(mat1)] <- "**NA**"
  mat2[is.na(mat2)] <- "**NA**"

  ## find differences
  mat_diff <- (mat1 != mat2)
  return(mat_diff)
}
