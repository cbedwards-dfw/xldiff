# **\[experimental\]** Get column widths of openxlsx2 Workbook sheet

Code by Jan Marvin. This function will likely be superceded by a
function in openxlsx2 in the future.

## Usage

``` r
wb_get_col_widths(wb, sheet = openxlsx2::current_sheet())
```

## Arguments

- wb:

  openxlsx2 workbook object

- sheet:

  sheet name, defaults to current sheet

## Value

Dataframe with \$col (column names) and \$width (column widths)

## Examples

``` r
library(openxlsx2)
wb <- wb_workbook() |>
  wb_add_worksheet("Sheet1") |>
  wb_add_data(x = mtcars) |>
  wb_set_col_widths(cols = 2:4, widths = 12)

current_widths <- wb_get_col_widths(wb, sheet = "Sheet1")
current_widths
#>     col  width
#> 1     B 12.711
#> 1.1   C 12.711
#> 1.2   D 12.711
```
