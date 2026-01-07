# Compare two dataframes of spreadsheets

Primary funtion for `xldiff` package. When cell values change between
dataframe `t1` and dataframe `t2`, the corresponding `$sheet_diff` entry
will show \[the first value\] `--> ` \[the second value\]. Note that
because these changes are presenting as characters, changes in numbers
with many digits can produce difficult-to-read cells. The
`proportional_threshold` (or optionally `absolute_threshold`) can be
used to determine how big a change should be to be flagged.
`digits_show` controls how many significant digits should be used when
showing the diffs. For example, `proportional_threshold = 0.01` and
`digits_show = 5` will flag changes of at least 1%, and when those
changes are present, the flagged cell will simplify the numbers to 5
significant digits when showing `## -> ##`.

## Usage

``` r
sheet_comp(
  t1,
  t2,
  proportional_threshold = 0.001,
  absolute_threshold = NULL,
  digits_show = 6
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

## Value

List of comparison data frames, including logical matrices used in
formatting cells to highlight changes.

- `$sheet_diff`: cell entries for comparison

- `$mat_changed` logical matrix where `TRUE` corresponds to a cell that
  changed

- `$mat_diff_decrease`: logical matrix where `TRUE` corresponds to a
  cell of numeric values that decreased = `mat_diff_increase`: as above,
  but for increases.

## Examples

``` r
if (FALSE) { # \dontrun{
## using palmerpenguins data to simulate spreadsheets
library(palmerpenguins)
t1 <- t2 <- head(penguins)
## change island variable to characters for easier modification
t2$island <- t1$island <- as.character(t1$island)
## change several entries in the second version
t2$island[3] <- "Scotland"
t2$flipper_length_mm[1] <- 18
sheet_comp(t1, t2)
} # }
```
