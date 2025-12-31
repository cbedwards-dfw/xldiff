#' Provide Excel addresses from matrix of logicals
#'
#' Useful when working with functions that need excel formats (e.g. `openxlsx2` functions).
#' Does not try to simplify blocks of TRUEs into block addresses.
#'
#' @param mat matrix of logical values
#'
#' @return vector of characters containing addresses in excel "A1" format.
#' @export
#'
#' @examples
#' mat = matrix(FALSE, ncol = 4, nrow = 3)
#' mat[1,1] = TRUE
#' mat[2,3] = TRUE
#' mat
#' mat_to_a1(mat)
mat_to_a1 <- function(mat){
  if(!is.matrix(mat) || !is.logical(mat)) {
    cli::cli_abort("`mat` must be a matrix of logical values!")
  }

  inds = as.matrix(which(mat, arr.ind = TRUE))

  if(nrow(inds)>0){
    a1_vec <- as.character(apply(inds, 1, function(x){openxlsx2::wb_dims(rows = x[1], cols = x[2])}
    )
    )
  }else{
    a1_vec = NULL
  }
  return(a1_vec)
}
