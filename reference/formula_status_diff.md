# Compare two sheets to see if formula use changed

Identifies if one or more cells changed from having a formula to not
between two excel sheets.

## Usage

``` r
formula_status_diff(file.1, file.2, sheet.name)
```

## Arguments

- file.1:

  Filename (including path) for first file to compare

- file.2:

  Filename (including path) for second file to compare

- sheet.name:

  character string of sheet to compare. If the sheets have different
  names (or to compare two sheets in one file), can take a character
  vector of length two, with the sheet names from the first and second
  file in order. In this case, the results file will use the first of
  the sheet names.

## Value

Nothing

## Examples

``` r
if (FALSE) { # \dontrun{
formula_status_diff(file.1 = "CohoPugetSoundTAMMInputTemplate2025.xlsx",
   file.2 = "CohoPugetSoundTAMMInputs 2025 v1.5.xlsx",
   sheet.name = "Input_Harvestnew")
} # }
```
