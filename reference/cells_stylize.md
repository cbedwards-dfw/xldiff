# Apply style to worksheet based on one or more excel-style cell ranges

Apply style to worksheet based on one or more excel-style cell ranges

## Usage

``` r
cells_stylize(wb, sheet, style, block.ranges, stack = TRUE)
```

## Arguments

- wb:

  openxlsx workbook object

- sheet:

  character corresponding to sheet name of openxlsx workbook object
  `wb`.

- style:

  `openxlsx` cell style, created with
  [`openxlsx::createStyle()`](https://rdrr.io/pkg/openxlsx/man/createStyle.html).
  This can include text size, bolding or italics, text wrapping,
  foreground color, text color, etc. See
  [`?openxlsx::createStyle`](https://rdrr.io/pkg/openxlsx/man/createStyle.html)
  for details.

- block.ranges:

  One or more cell ranges specified in excel format (e.g.
  `c("A1:D5, "B6", "A8:D8")`)

- stack:

  Should style be appended to existing styles (`TRUE`) or replace
  existing styles (`FALSE`). Defaults to `TRUE`.
