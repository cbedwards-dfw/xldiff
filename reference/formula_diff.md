# Compare two sheets to see if formula use changed

Identifies if one or more cells changed from having a formula to not
between two excel sheets.

## Usage

``` r
formula_diff(file_1, file_2, sheet_name)
```

## Arguments

- file_1:

  Filename (including path) for first file to compare

- file_2:

  Filename (including path) for second file to compare

- sheet_name:

  Character string of sheet to compare. Can provide vector of character
  strings to produce comparisons of multiple sheets.

## Value

invisibly returns dataframe of the cell address and before/after
formulas for cases in which a formula was present in both files but
differed.

## Examples

``` r
if (FALSE) { # \dontrun{
formula_diff(
  file_1 = "CohoPugetSoundTAMMInputTemplate2025.xlsx",
  file_2 = "CohoPugetSoundTAMMInputs 2025 v1.5.xlsx",
  sheet_name = "Input_Harvestnew"
)
} # }
```
