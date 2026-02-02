# Dev version

- updated `excel_diff()` to
   - accept cell ranges to compare
   - buffer cell ranges so that the two sheets are comparable
   - optionally re-arrange rows to increase matchingness (address problem
   when spacer rows are added/removed)
   

# xldiff 0.2.0

- Updated `excel_diff()` to use openslxs2 package. Sheets now automatically show original formatting (except highlighting)
- `excel_diff()` can now compare multiple sheets. `sheet_name` now takes multiple sheets to compare. If
sheet names differ between files, `sheet_name_file_2` is a vector of sheet names in file 2, which should have the same length as `sheet_name`.
- `excel_diff_tibble()`: new function that returns a tibble instead of a table. Mostly a wrapper for `present_rows_changed()`, but in format equivalent to other `excel_diff*` functions.
- Updated `sheet_comp()` and all downstream functions (e.g., `excel_diff()`, `excel_diff_table()`) to use arguments `proportional_threshold` and optional argument
`absolute_threshold` to identify what level of changes to ignore. Argument `digits_show` controls how many significant digits should be shown when presenting the diffs. 
- `formula_status_diff()` has been relabeled to `formula_diff()`, identifies when formulas have changed (not just when is.formula has changed). Now invisibly returns dataframe of changed cell addresses and before/after formulas. Can compare multiple sheets at once
- all function arguments (and internal variables) use snake case, making them more consistent with other FRAMVERSE packages
- added internal input checking functions in `integrity.R`.
- `add_cell_borders()` and `cell_stylize()` are the only remaining functions that depend on package openxlsx. These functions are now deprecated, and package openxlsx is now in "Suggests" instead of "Imports". Unclear if either of these deprecated functions will have a useful home in the future -- they do not add anything here, but are used in parts of TAMMsupport. 

# xldiff 0.1.0

