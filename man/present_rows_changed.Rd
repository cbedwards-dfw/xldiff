% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/present_rows_changed.R
\name{present_rows_changed}
\alias{present_rows_changed}
\title{Summarize the rows changed between two dataframes}
\usage{
present_rows_changed(
  t1,
  t2,
  digits.signif = 4,
  trim.cols = TRUE,
  diff.only = TRUE
)
}
\arguments{
\item{t1}{First dataframe}

\item{t2}{Second dataframe, same dimensions as first.}

\item{digits.signif}{When flagging changes, comparison is presented in character form. How many significant digits do we present for numerical entries? Numeric, defaults to 4.}

\item{trim.cols}{Remove unchanged columns? Useful with wide dataframes when viewing results in the console. Defaults to TRUE.}

\item{diff.only}{Show only the changed values? defaults to TRUE.}
}
\value{
A diff of the two dataframes, similar to \verb{$sheet.diff} part of the return of sheet_comp. Includes a \code{row_number} column, and remaining columns have been labeled to match excel column naming conventions.
}
\description{
When given two dataframes, uses sheet_comp to compare the two dataframes, then
presents the rows that have changed: prints the row numbers to the console, and then
returns the "diff" of those rows, with column names matching excel column naming conventions.
}
