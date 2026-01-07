# Diff excel sheet and return tibble

Compares sheet from two excel files and returns a tibble of the diff.

## Usage

``` r
excel_diff_tibble(
  file_1,
  file_2,
  sheet_name,
  proportional_threshold = 0.001,
  absolute_threshold = NULL,
  digits_show = 6,
  trim_cols = FALSE,
  diff_only = FALSE
)
```

## Arguments

- file_1:

  Filename (including path) for first file to compare

- file_2:

  Filename (including path) for second file to compare

- sheet_name:

  Character string of a single excel sheet to compare between the files.
  (Unlike `excel_diff`, only one sheet can be compared at a time)

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

- trim_cols:

  Remove unchanged columns? Useful with wide dataframes when viewing
  results in the console. Defaults to FALSE.

- diff_only:

  Show only the changed values? defaults to FALSE.

## See also

[`excel_diff()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff.md),
[`excel_diff_table()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff_table.md)
