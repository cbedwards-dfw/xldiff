
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xldiff

<!-- badges: start -->
<!-- badges: end -->

The goal of xldiff is to facilitate comparing excel sheets for changes,
inspired by `diff` tools.

## Installation

You can install the development version of xldiff like so:

``` r
remotes::install_github()
```

## Example

We can carry out simple comparisons of excel files with the
`excel_diff()` function. To begin with, we must have two excel sheets
that are generally similar, but in which some number of cells have
changed. `xldiff` was originally developed to help compare inputs and
outputs for different runs of the FRAM model, which stores both inputs
and outputs in excel files. However, this can be used more broadly to
compare different files with the same structure, for example monthly
reports summarizing survey information, service use, or finances.

### Creating our files

To walk through an example, we first create two excel files that differ
in a few cells. Here we use the first 20 rows of the `penguins` data in
the `palmerpenguins` package
(\[<https://allisonhorst.github.io/palmerpenguins/>\]).

``` r
library(palmerpenguins)
library(writexl)

# create our two data frames
dat1 = dat2 = penguins[1:20,]
## convert $island to character for easier modification
dat1$island = dat2$island = as.character(dat1$island)
## change several entries in dat2.
dat2$island[10] = "Scotland"
dat2$body_mass_g[6] = 365
dat2$bill_depth_mm[20] = 25



## write to excel files, in sheet named "penguins". See ?writexl::writexlsx.
write_xlsx(list(penguins = dat1),
           path = "example-penguins-1.xlsx")
write_xlsx(list(penguins = dat2),
           path = "example-penguins-2.xlsx")
```

### Basic example

With our two files in hand, we can begin our use of the `xldiff`
package:

``` r
library(xldiff)

excel_diff(file.1 = "example-penguins-1.xlsx",
          file.2 = "example-penguins-2.xlsx",
          results.name = "penguin-file-comparison.xlsx",
          sheet.name = "penguins"
)
```

This produces an excel file that shows and highlights changes in cells.

![](man/figures/MAN/filev1.PNG)

### Adding formatting

However, we notice that aside from highlighting cells with changes, the
rest of the document lacks formatting. Particularly with more complex
spreadsheets (e.g. the FRAM input and outputs this tool was developed
for), it can be easier to contextualize changes if the “diff” file has
formatting. `excel_diff()` supports this with the optional argument
`extra_format_fun`. `xldiff` uses the `openxlsx` package to handle excel
file formatting, and `extra_format_fun` should be a user-created
function which applies excel formatting using the functions of the
`openxlsx` (commonly `createStyle`, `addStyle`, `setColWidths` and
`setRowHeights`). The first two arguments of `extra_format_fun` must be
the workbook object and sheet name that any contained `openxlsx`
functions make changes to.

As a simple example, we might choose to increase the font size and bold
the first row, add a thick border around the first row and the entire
block of used cells, and add thinner borders surrounding each individual
cell in the block of used cells. We will also choose to increase column
width, as otherwise cells with changes in them can become hard to read
given the extra content. To facilitate applying borders to groups of
cells, `xldiff` includes the function `add_cell_borders`, which takes
one or more excel-style cell ranges and applies borders either around
the block or within the block (depending on the value of argument
`every.cell`).

Here we write our formatting function. For details on how to format
`openxlsx` workbooks, see the openxlsx documentation.

``` r
library(openxlsx)
format_fun = function(wb, sheet){
  ## add bold and increased size for the first two rows.
  addStyle(wb, sheet,
                     style = openxlsx::createStyle(fontSize = 12, textDecoration = "Bold"),
                     rows = 1, cols = 1:8, gridExpand = TRUE,
                     stack = TRUE)
  ## add thin inner cell borders
  add_cell_borders(wb, sheet,
                   block.ranges = c("A2:H21"),
                   border.thickness = "thin", every.cell = TRUE)
  ## add thick outer borders
  add_cell_borders(wb, sheet,
                    block.ranges = c("A1:H1", "A1:H21"),
                   border.thickness = "medium")
  setColWidths(wb, sheet, cols = 1:8, widths = c(14, 20, 14, 14, 14, 14, 14))
}
```

When we call `excel_diff` with this new formatting function, our output
file is prettier, and (hopefully) easier to read.

``` r
excel_diff(file.1 = "example-penguins-1.xlsx",
           file.2 = "example-penguins-2.xlsx",
           results.name = "penguin-file-comparison2.xlsx",
           sheet.name = "penguins",
           extra_format_fun = format_fun
)
```

![](man/figures/MAN/filev1.PNG)

### Tips when adding formatting with `extra_format_fun =`

- with `openxlsx`’s `addStyle()`, the optional argument `stack = TRUE`
  adds the specified style on top of existing styles. This can be
  helpful when handling complex and overlapping formatting (e.g., when
  specifying that an entire block has a background color, while
  individual cells within it are bolded, and several vertical borders
  split the block, you only need to specify those three types of style,
  not all their possible combinations).
- `xldiff` includes the helper function `cell_range_translate()` which
  takes an excel cell range (e.g. “B2:H6”) and returns a dataframe with
  the rows and columns of each cell in that range. This can then be fed
  into the `row` and `col` arguments of `openxlsx` functions.
- The cell highlighting for changed cells is added *after* the custom
  formatting, so setting foreground color to blocks for cells will not
  interfere with this highlight.

## Advanced use

For more complicated uses, `sheet_comp()` and `add_changed_formats()`
provide the building blocks for writing custom scripts or functions. For
example, when reading in a file with numerical values for which we only
care about relatively large changes, it may be useful to round those
entries before carrying out comparisons, so that our sheet is full of
largely meaningless changes.

In these cases, it may be useful to use `excel_diff` as a starting
template. Use `print(excel_diff)` to view the underlying code.
