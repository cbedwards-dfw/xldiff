# Minimal spreadsheet comparison function

Compares a single sheet between two files, creating a new file that uses
the formatting of the existing sheets (except highlighting) and
highlights cells that differed. Small numeric differences between cell
values can be the result of happenstance ("decimal dust") - the
`digits_signif` and `proportional.diff` arguments can control behavior
to ignore minor numeric differences.

## Usage

``` r
excel_diff(
  file_1,
  file_2,
  results_name,
  sheet_name,
  sheet_name_file_2 = NULL,
  proportional_threshold = 0.001,
  absolute_threshold = NULL,
  digits_show = 6,
  extra_width = 0.2
)
```

## Arguments

- file_1:

  Filename (including path) for first file to compare

- file_2:

  Filename (including path) for second file to compare

- results_name:

  Name (including path) for file to save comparison to. Must end in
  ".xlsx"

- sheet_name:

  Character string of sheet to compare. Can provide vector of character
  strings to produce comparisons of multiple sheets.

- sheet_name_file_2:

  OPTIONAL. Matching sheet names to `sheet_name` but for file 2. Use
  only if the two files have matching sheets with different names.
  Defaults to NULL.

- proportional_threshold:

  Sets a threshold of proportional change below which differences should
  be ignored. For example, a value of 0.1 means any changes less than
  10% will not be flagged as having changed. `proportional_threshold`
  will override this value and behavior if it is provided. Numeric,
  defaults to 0.001 (0.1% change).

- absolute_threshold:

  Optional. Sets a threshold of absolute change below which differences
  should be ignored. For example, a value of 0.1 means any changes less
  than 0.1 will not be flagged as having changed. If provided, will
  override `proportional_threshold`. Numeric, defaults to NULL.

- digits_show:

  When there is a change in number values, how many digits should be
  shown in `## ---> ##`? Numeric, defaults to 6. Recommend not making
  this so small that flagged changes don't get printed (e.g., if this is
  2 and `proportional_threshold` is 0.001, 0.1% changes will get
  flagged, but only the first two digits will get shown).

- extra_width:

  How much extra width should be added to columns that changed? Helpful
  to improve readability, since changed cells have longer entries.
  Numeric, defaults to 0.4.

## See also

[`excel_diff_table()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff_table.md),
[`excel_diff_tibble()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff_tibble.md)

## Examples

``` r
if (FALSE) { # \dontrun{
filename_1 <- "Chin1124.xlsx"
filename_2 <- "Chin2524.xlsx"

excel_diff(
  file_1 = filename_1,
  file_2 = filename_2,
  results.name = "Chin1124 vs Chin 2524.xlsx",
  sheet_name = "ER_ESC_Overview_New"
)
} # }
```
