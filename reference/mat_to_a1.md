# Provide Excel addresses from matrix of logicals

Useful when working with functions that need excel formats (e.g.
`openxlsx2` functions). Does not try to simplify blocks of TRUEs into
block addresses.

## Usage

``` r
mat_to_a1(mat)
```

## Arguments

- mat:

  matrix of logical values

## Value

vector of characters containing addresses in excel "A1" format.

## Examples

``` r
mat <- matrix(FALSE, ncol = 4, nrow = 3)
mat[1, 1] <- TRUE
mat[2, 3] <- TRUE
mat
#>       [,1]  [,2]  [,3]  [,4]
#> [1,]  TRUE FALSE FALSE FALSE
#> [2,] FALSE FALSE  TRUE FALSE
#> [3,] FALSE FALSE FALSE FALSE
mat_to_a1(mat)
#> [1] "A1" "C2"
```
