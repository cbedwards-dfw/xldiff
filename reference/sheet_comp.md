# Compare two dataframes of spreadsheets

Primary funtion for `xldiff` package. When cell values change between
dataframe `t1` and dataframe `t2`, the corresponding `$sheetdiff` entry
will show \[the first value\] `--> ` \[the second value\]. Note that
because these changes are presenting as characters, changes in numbers
with many digits can produce difficult-to-read cells. The
`digits.signif` can be used to determine how many significant digits
should be used when identifying changes to numeric values, and how many
digits should be presented in the "arrow" cells. `proprotional_diff`
allows toggling between identifying changes based on absolute value
(`FALSE`) or proportional changes (`TRUE`). For example,
`proportional.diff = TRUE` and `digits.signif = 2` will flag numeric
changes of at least 1%.

## Usage

``` r
sheet_comp(t1, t2, digits.signif = 4, proportional.diff = FALSE)
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

- proportional.diff:

  Should flagging of numeric changes be based on absolute differences or
  the ratio of values, sheet2/sheet? If TRUE, uses `digits.signif` to
  identify proportional threshold. `proportional.diff = TRUE` and
  `digits.signif`

## Value

List of comparison data frames, including logical matrices used in
formatting cells to highlight changes.

- `$sheet.diff`: cell entries for comparison

- `$mat.changed` logical matrix where `TRUE` corresponds to a cell that
  changed

- `$mat.diff.decrease`: logical matrix where `TRUE` corresponds to a
  cell of numeric values that decreased = `mat.diff.increase`: as above,
  but for increases.

## Examples

``` r
if (FALSE) { # \dontrun{
## using palmerpenguins data to simulate spreadsheets
library(palmerpenguins)
t1 = t2 = head(penguins)
## change island variable to characters for easier modification
t2$island = t1$island = as.character(t1$island)
## change several entries in the second version
t2$island[3] = "Scotland"
t2$flipper_length_mm[1] = 18
sheet_comp(t1, t2, digits.signif = 4)
} # }
```
