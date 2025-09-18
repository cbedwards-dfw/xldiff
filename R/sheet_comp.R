#' Compare two dataframes of spreadsheets
#'
#' Primary funtion for `xldiff` package. When cell values change between dataframe `t1` and
#' dataframe `t2`, the corresponding `$sheetdiff` entry will show \[the first value\] `--> ` \[the second value\].
#' Note that because these changes are presenting as characters, changes in numbers with many digits can produce difficult-to-read cells.
#' The `digits.signif` can be used to determine how many significant digits should be used when identifying changes to numeric values,
#' and how many digits should be presented in the "arrow" cells. `proprotional_diff` allows toggling between identifying changes based on
#' absolute value (`FALSE`) or proportional changes (`TRUE`). For example, `proportional_diff = TRUE` and `digits.signif = 2` will flag numeric changes of at least 1%.
#'
#' @param t1 First dataframe
#' @param t2 Second dataframe, same dimensions as first.
#' @param digits.signif When comparing numeric values, what decimal do we want to round to before flagging changes? Also used to limit printing of changes? Numeric, defaults to 4.
#' @param proportional_diff Should flagging of numeric changes be based on absolute differences or the ratio of values, sheet2/sheet? If TRUE, uses `digits.signif` to identify proportional threshold. `proportional_diff = TRUE` and `digits.signif`
#'
#' @return List of comparison data frames, including logical matrices used in formatting cells to
#' highlight changes.
#'    - `$sheet.diff`: cell entries for comparison
#'    - `$mat.changed` logical matrix where `TRUE` corresponds to a cell that changed
#'    - `$mat.diff.decrease`: logical matrix where `TRUE` corresponds to a cell of numeric values that decreased
#'    = `mat.diff.increase`: as above, but for increases.
#' @export
#'
#' @examples
#' \dontrun{
#' ## using palmerpenguins data to simulate spreadsheets
#' library(palmerpenguins)
#' t1 = t2 = head(penguins)
#' ## change island variable to characters for easier modification
#' t2$island = t1$island = as.character(t1$island)
#' ## change several entries in the second version
#' t2$island[3] = "Scotland"
#' t2$flipper_length_mm[1] = 18
#' sheet_comp(t1, t2, digits.signif = 4)
#' }
sheet_comp = function(t1, t2, digits.signif = 4, proportional_diff = FALSE){
  if(!(all(dim(t1) == dim(t2)))){
    cli::cli_abort("Dataframes `t1` and `t2` must have the same dimensions")
  }
  if(!is.numeric(digits.signif)){
    cli::cli_abort("`digits.signif` must be positive integer.")
  }
  if(digits.signif<0){
    cli::cli_abort("`digits.signif` must be positive integer")
  }
  if(floor(digits.signif)!=digits.signif){
    cli::cli_abort("`digits.signif` must be positive integer.")
  }



  mat1 = as.matrix(t1)
  mat2 = as.matrix(t2)

  ## cut out extraneous NAs now
  mat1 = mat1[1:max(which(!apply(mat1, 1, function(x){all(is.na(x))}))),]
  mat2 = mat2[1:max(which(!apply(mat2, 1, function(x){all(is.na(x))}))),]

  ## translate NAs for better comparison
  mat1[is.na(mat1)] = "**NA**"
  mat2[is.na(mat2)] = "**NA**"

  ## find differences
  mat.diff = (mat1 != mat2)
  ## find which values can be treated as numbers and which can't
  mat.numbers = suppressWarnings(!is.na(as.numeric(mat1)) & !is.na(as.numeric(mat2)))
  mat.numbers.percents = suppressWarnings(!is.na(as.numeric(gsub("%$", "", mat1))) &
                                            !is.na(as.numeric(gsub("%$", "", mat2))))
  mat.numbers.percents = mat.numbers.percents & !mat.numbers
  comparify_nums = function(x){
    as.numeric(x) + sign(as.numeric(x))/1000
  }


  if(proportional_diff){
    mat.denominator.zero = suppressWarnings(!is.na(as.numeric(mat1)) &
                                              !is.na(as.numeric(mat2)) &
                                              mat1 == 0)
    mat.diff[mat.numbers] =
      suppressWarnings(round(comparify_nums(mat2[mat.numbers]) /
                               comparify_nums(mat1[mat.numbers]),
                             digits.signif) != 1)
    mat.diff[mat.numbers.percents] = suppressWarnings(
      round(comparify_nums(gsub("%$", "", mat2)[mat.numbers.percents]) /
              comparify_nums(gsub("%$", "", mat1)[mat.numbers.percents]),
            digits.signif) != 1)
    # handling cases when denominator is 0
     mat.denominator.zero = suppressWarnings(!is.na(as.numeric(mat1)) &
                                               !is.na(as.numeric(mat2)) &
                                               mat1 == 0)
     mat.diff[mat.denominator.zero] =
       round(as.numeric(mat2[mat.denominator.zero]), digits.signif) != 0
     ## handles cases when denominator is 0 and %s.
     mat.denominator.zero =

       suppressWarnings(!is.na(as.numeric(gsub("%$", "", mat1))) &
                        !is.na(as.numeric(gsub("%$", "", mat2))) &
                        !mat.numbers &
                        as.numeric(gsub("%$", "", mat1) != 0)

     )
     mat.diff[mat.denominator.zero] =
       round(as.numeric(gsub("%$", "", mat2)[mat.denominator.zero]), digits.signif) == 0

  } else {
    ## for numeric entries, update mat.diff with rounded comparison
    mat.diff[mat.numbers] = round(as.numeric(mat1[mat.numbers]), digits.signif) !=
      round(as.numeric(mat2[mat.numbers]), digits.signif)

    mat.diff[mat.numbers.percents] = suppressWarnings(
      round(as.numeric(gsub("%$", "", mat1)[mat.numbers.percents]), digits.signif) !=
        round(as.numeric(gsub("%$", "", mat2)[mat.numbers.percents]), digits.signif)
    )
  }

  ## find indices for changes that are text and are numeric
  ind.diff.text = which(mat.diff & !mat.numbers)
  ind.diff.num = which(mat.diff & mat.numbers)
  ind.diff.num.percents = which(mat.diff & mat.numbers.percents)

  mat.new = mat1
  mat.new[ind.diff.text] = paste0(mat1[ind.diff.text]," --> ",
                                  mat2[ind.diff.text])
  mat.new[ind.diff.num] = paste0(signif(as.numeric(mat1[ind.diff.num]), digits.signif)," --> ",
                                 signif(as.numeric(mat2[ind.diff.num]), digits.signif))
  mat.new[ind.diff.num.percents] = suppressWarnings(
    paste0(signif(as.numeric(gsub("%$", "", mat1)[ind.diff.num.percents]),
                  digits.signif),"% --> ",
           signif(as.numeric(as.numeric(gsub("%$", "", mat2))[ind.diff.num.percents]),digits.signif), "%")
  )
  mat.new[mat.new == "**NA**"] = NA

  ## store matrices for style differences
  mat.diff.text = mat.diff & !mat.numbers
  mat.diff.decrease = mat.diff.increase = matrix(FALSE,
                                                 nrow = nrow(mat1),
                                                 ncol = ncol(mat1))
  mat.diff.decrease[ind.diff.num] = mat1[ind.diff.num] > mat2[ind.diff.num]
  mat.diff.increase[ind.diff.num] = mat1[ind.diff.num] < mat2[ind.diff.num]

  if(length(ind.diff.num.percents)>0){
    mat.diff.decrease[ind.diff.num.percents] = gsub("%$", "", mat1[ind.diff.num.percents]) >
      gsub("%$", "", mat2[ind.diff.num.percents])
    mat.diff.increase[ind.diff.num.percents] = gsub("%$", "", mat1[ind.diff.num.percents]) <
      gsub("%$", "", mat2[ind.diff.num.percents])
  }
  ## clear extraneous NAs from bottom of each matrix


  return(list(sheet.diff = mat.new,
              mat.changed = mat.diff,
              mat.diff.text = mat.diff.text,
              mat.diff.decrease = mat.diff.decrease,
              mat.diff.increase = mat.diff.increase))
}

#' Stripped down version of sheet_comp
#'
#' @inheritParams sheet_comp
#'
#' @return logical matrix
#'
sheet_comp_basic <-  function(t1, t2){
  if(!(all(dim(t1) == dim(t2)))){
    cli::cli_abort("Dataframes `t1` and `t2` must have the same dimensions")
  }

  mat1 = as.matrix(t1)
  mat2 = as.matrix(t2)

  ## cut out extraneous NAs now
  mat1 = mat1[1:max(which(!apply(mat1, 1, function(x){all(is.na(x))}))),]
  mat2 = mat2[1:max(which(!apply(mat2, 1, function(x){all(is.na(x))}))),]

  ## translate NAs for better comparison
  mat1[is.na(mat1)] = "**NA**"
  mat2[is.na(mat2)] = "**NA**"

  ## find differences
  mat.diff = (mat1 != mat2)
  return(mat.diff)
}
