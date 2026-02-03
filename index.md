# xldiff

The goal of xldiff is to facilitate comparing excel sheets to look for
changes, inspired by `diff` tools. `xldiff` was originally developed to
help compare inputs and outputs for different runs of the FRAM salmon
model, which stores both inputs and outputs in excel files. However, the
comparison tools here can be used more broadly to compare different
files with the same structure, for example monthly reports summarizing
survey information, service use, or finances.

xldiff is part of the [FRAMverse
R-Universe](https://framverse.r-universe.dev/packages)

## Installation

You can install the development version of xldiff from R-Universe like
so:

``` r
install.packages("xldiff", repos = "https://framverse.r-universe.dev")
```

If you have Rtools and [remotes](https://remotes.r-lib.org) or
[pak](https://pak.r-lib.org/) installed, you can install from source
code like so:

``` r
pak::pkg_install("cbedwards-dfw/xldiff")
#OR
remotes::install_github("cbedwards-dfw/xldiff")
```

To install the development version, which may include new features that
have been added but not thoroughly tested:

``` r
pak::pkg_install("cbedwards-dfw/xldiff@dev")
```

## Example

### Creating our files

We can carry out simple comparisons of excel files with the
[`excel_diff()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff.md)
function. To begin with, we must have two excel sheets that are
generally similar, but for which some cells have differing values. To
walk through our example, we first must create two such excel sheets.
Here we use the first 20 rows of the `penguins` data in the
`palmerpenguins` package
(<https://allisonhorst.github.io/palmerpenguins/>).

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

With our two files in hand, we can use `excel_diff` to compare them. We
need to specify the two files we are comparing, the name of the new file
that will show the comparison, and the sheet we are comparing.

``` r
library(xldiff)

excel_diff(file_1 = "example-penguins-1.xlsx",
          file_2 = "example-penguins-2.xlsx",
          results_name = "penguin-file-comparison.xlsx",
          sheet_name = "penguins"
)
```

This produces an excel file that shows and highlights changes in cells.

![](reference/figures/MAN/filev1.PNG)

We can also run a diff that displays in the “Viewer” section of Rstudio
by using
[`excel_diff_table()`](https://cbedwards-dfw.github.io/xldiff/reference/excel_diff_table.md):

``` r
excel_diff(file_1 = "example-penguins-1.xlsx",
          file_2 = "example-penguins-2.xlsx",
          sheet_name = "penguins"
)
```

![](reference/figures/MAN/excel_diff_table.png)
