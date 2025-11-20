# Adds cell borders to openxlsx spreadsheet

When calling `sheet_diff()`, creating a new workbook for the diff
contents, and then coloring to highlight changed cells, the original
spreadsheet formatting is lost. To facilitate interpretting the diff, it
can be useful to recreate the major components of the original
formatting, especially cell borders. This function adds cell borders,
and is designed for ease of use when replicating formatting from the
original excel file. Blocks of cells to give borders to can be specified
in the original excel format (e.g. "A1:D5"). For only outside borders
around each block (default), use argument `every.cell = FALSE`. To add
all the cell borders within each block to generate a grid appearance,
set `every.cell = TRUE`. Note that non-border formatting of each cell
will not be maintained, but border formatting will be overwritten. When
adding thin boundaries between inner cells and a thick outer border for
a block of cells, first use `add_cell_borders` to with
`every.cell = TRUE`, and appropriate border arguments (usually
`border.thickness = "thin"`) and then use again with
`every.cell = FALSE` and appropriate border arguments (usually
`border.thickness = "medium"`).

## Usage

``` r
add_cell_borders(
  wb,
  sheet,
  block.ranges,
  sheet.start = "A1",
  every.cell = FALSE,
  border.col = "black",
  border.thickness = "medium"
)
```

## Arguments

- wb:

  openxlsx workbook object

- sheet:

  character corresponding to sheet name of openxlsx workbook object
  `wb`.

- block.ranges:

  One or more cell ranges specified in excel format (e.g.
  `c("A1:D5, "B6", "A8:D8")`)

- sheet.start:

  Optional. If `wb$sheet` corresponds to an excel sheet in which the
  `wb$sheet` entries were read starting on a cell other than "A1" (e.g.
  [`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html)
  with range specified or skip provided), provide the top left cell that
  was read into R in order to handle the offsetting, so that you can
  specify cell ranges based on the original excel file.

- every.cell:

  Do we want borders around each individual cell in each cell block
  (`TRUE`), or just around the outer edges of the block (`FALSE`).
  Defaults to `FALSE`.

- border.col:

  Color for border. See
  [`?openxlsx::createStyle`](https://rdrr.io/pkg/openxlsx/man/createStyle.html)
  for details. Defaults to "black".

- border.thickness:

  Thickness for border. See
  [`?openxlsx::createStyle`](https://rdrr.io/pkg/openxlsx/man/createStyle.html)
  for details. Common choices: "thin", "thick".
