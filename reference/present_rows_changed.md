# Summarize the rows changed between two dataframes

When given two dataframes, uses sheet_comp to compare the two
dataframes, then presents the rows that have changed: prints the row
numbers to the console, and then returns the "diff" of those rows.
Optionally, can ignore columns that have not changed and can show only
changed values.

## Usage

``` r
present_rows_changed(
  t1,
  t2,
  proportional_threshold = 0.001,
  absolute_threshold = NULL,
  digits_show = 6,
  trim_cols = FALSE,
  diff_only = FALSE
)
```

## Arguments

- t1:

  First dataframe

- t2:

  Second dataframe, same dimensions as first.

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

## Value

A diff of the two dataframes, similar to `$sheet_diff` part of the
return of sheet_comp. Includes a `row_number` column, and remaining
columns have been labeled to match excel column naming conventions.

## Details

Alternatively, look at the `diffdf` package!
