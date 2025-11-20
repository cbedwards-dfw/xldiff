# Summarize the rows changed between two dataframes

When given two dataframes, uses sheet_comp to compare the two
dataframes, then presents the rows that have changed: prints the row
numbers to the console, and then returns the "diff" of those rows, with
column names matching excel column naming conventions.

## Usage

``` r
present_rows_changed(
  t1,
  t2,
  digits.signif = 4,
  trim.cols = TRUE,
  diff.only = TRUE
)
```

## Arguments

- t1:

  First dataframe

- t2:

  Second dataframe, same dimensions as first.

- digits.signif:

  When comparing numeric values, what decimal do we want to round to
  before flagging changes? Also used to limit printing of changes?
  Numeric, defaults to 4.

- trim.cols:

  Remove unchanged columns? Useful with wide dataframes when viewing
  results in the console. Defaults to TRUE.

- diff.only:

  Show only the changed values? defaults to TRUE.

## Value

A diff of the two dataframes, similar to `$sheet.diff` part of the
return of sheet_comp. Includes a `row_number` column, and remaining
columns have been labeled to match excel column naming conventions.
