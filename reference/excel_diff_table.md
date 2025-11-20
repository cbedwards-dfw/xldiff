# Diff excel sheets and show table

Similar to excel_diff, but returns flextable that can be displayed and
navigated in the Rstudio viewer. Only shows rows that have changed. For
every row with changes, provides a row of before and after, highlighting
changed vlaues (red for the value in file.1, green for the value in
file.2)."ROWS" column identifies excel row number and columns identify
excel column names. Defaults to flagging changes of at least 0.1% from
`file.1` to `file.2` (`proportional.diff = TRUE`, `digits.signif = 3`).

## Usage

``` r
excel_diff_table(
  file.1,
  file.2,
  sheet.name,
  digits.signif = 3,
  proportional.diff = TRUE
)
```

## Arguments

- file.1:

  Filename (including path) for first file to compare

- file.2:

  Filename (including path) for second file to compare

- sheet.name:

  character string of sheet to compare. If the sheets have different
  names (or to compare two sheets in one file), can take a character
  vector of length two, with the sheet names from the first and second
  file in order. In this case, the results file will use the first of
  the sheet names.

- digits.signif:

  Numeric, controls the amount of difference a number needs to have to
  be identified as differing between the two sheets. When
  `proportional.diff = TRUE`, defines proportional change that triggers
  a "diff" status, where the number is the number of digits of the
  proportion (2 = 1% difference, 3 = 0.1% difference, 4 = 0.01%
  difference). When `proportional.diff = FALSE`, defines the absolute
  difference that triggers a difference, in digits of round (1 = 0.1
  difference, 2 = 0.01 difference, 3 = 0.001).

- proportional.diff:

  Should minor differences between cells be judged on an absolute basis
  (`FALSE`) or a proportional basis (`TRUE`). `FALSE` is useful for
  identifying a level of decimal dust that we don't want to worry about
  when diff-ing (e.g., "If the differences is in the 1000ths place or
  smaller, I don't care"). `TRUE` is useful when a sheet contains values
  of varying magnitudes, as it allows specifying proprotional changes
  that should be ignored when diffing (e.g., "If the value changed by
  less than 0.1%, I don't care).

## Value

flextable object.

## Examples

``` r
if (FALSE) { # \dontrun{
excel_diff_table(file.1 = "C:/Repos/test file 1.xlsx",
file.2 = "C:/Repos/test file 2.xlsx",
sheet = "Sheet1")
} # }
```
