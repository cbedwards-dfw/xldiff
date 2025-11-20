# Minimal spreadsheet comparison function

Compares a single sheet between two files, supports providing additional
formatting in the form of the optional `extra_format_fun` argument. For
more complex use cases (e.g., multiple sheet, pre-comparison formatting
to compare only specific regions, etc) `excel_diff` can be used as a
simple template for writing your own function. Small numeric differences
between cell values can be the result of happenstance ("decimal dust") -
the `digits.signif` and `proportional.diff` arguments can control
behavior to ignore minor numeric differences.

## Usage

``` r
excel_diff(
  file.1,
  file.2,
  results.name,
  sheet.name,
  digits.signif = 3,
  proportional.diff = TRUE,
  extra_format_fun = NULL,
  ...
)
```

## Arguments

- file.1:

  Filename (including path) for first file to compare

- file.2:

  Filename (including path) for second file to compare

- results.name:

  Name (including path) for file to save comparison to. Must end in
  ".xlsx"

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

- extra_format_fun:

  Optional function to apply additional formatting, allowing users to
  specify additional calls of
  [`addStyle()`](https://rdrr.io/pkg/openxlsx/man/addStyle.html) (or
  other openxslx functions, like setting column width). First argument
  must be the workbook object this function makes changes to; second
  argument must be the name of the worksheet this function makes changes
  to

- ...:

  Additional arguments passed to `extra_format_fun`

## Examples

``` r
if (FALSE) { # \dontrun{
filename.1 = "Documents/WDFW FRAM team work/NOF material/NOF 2024/FRAM/Chin1124.xlsx"
filename.2 = "Documents/WDFW FRAM team work/NOF material/NOF 2024/NOF 2/Chin2524.xlsx"

excel_diff(file.1 = filename.1,
          file.2 = filename.2,
          results.name = "Documents/WDFW FRAM team work/NOF material/NOF 2024/test1.xlsx",
          sheet.name = "ER_ESC_Overview_New"
)

## create function to add in some additional formatting:
extra_form_fun = function(wb, sheet){
 ## add bold and increased size for the first two rows.
 openxlsx::addStyle(wb, sheet,
                    style = openxlsx::createStyle(fontSize = 16, textDecoration = "Bold"),
                    rows = 1:2, cols = 1:8, gridExpand = TRUE,
                    stack = TRUE)
 ## add thin inner cell borders
 add_cell_borders(wb, sheet,
                  block.ranges = c("B3:H34") )
 ## add thick outer borders
 add_cell_borders(wb, sheet,
                  block.ranges = c("A2", "B1:D2", "E1:H2",
                                   "A3:A34", "B3:D34", "E3:H34",
                                   "D36:H37"),
                  border.thickness = "medium")
}

excel_diff(file.1 = filename.1,
          file.2 = filename.2,
          results.name = "Documents/WDFW FRAM team work/NOF material/NOF 2024/test2.xlsx",
          sheet.name = "ER_ESC_Overview_New",
          extra_format_fun = extra_form_fun
)
} # }
```
