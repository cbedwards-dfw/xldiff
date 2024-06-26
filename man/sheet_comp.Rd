% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sheet_comp.R
\name{sheet_comp}
\alias{sheet_comp}
\title{Compare two dataframes of spreadsheets}
\usage{
sheet_comp(t1, t2, digits.signif = 4)
}
\arguments{
\item{t1}{First dataframe}

\item{t2}{Second dataframe, same dimensions as first.}

\item{digits.signif}{When flagging changes, comparison is presented in character form. How many significant digits do we present for numerical entries? Numeric, defaults to 4.}
}
\value{
List of comparison data frames, including logical matrices used in formatting cells to
highlight changes.
\itemize{
\item \verb{$sheet.diff}: cell entries for comparison
\item \verb{$mat.changed} logical matrix where \code{TRUE} corresponds to a cell that changed
\item \verb{$mat.diff.decrease}: logical matrix where \code{TRUE} corresponds to a cell of numeric values that decreased
= \code{mat.diff.increase}: as above, but for increases.
}
}
\description{
Primary funtion for \code{xldiff} package. When cell values change between dataframe \code{t1} and
dataframe \code{t2}, the corresponding \verb{$sheetdiff} entry will show [the first value] \verb{--> } [the second value].
Note that because these changes are presenting as characters, changes in numbers with many digits can produce difficult-to-read cells.
The \code{digits.signif} can be used to determine how many significant digits should be presented in the "arrow" cells.
}
\examples{
\dontrun{
## using palmerpenguins data to simulate spreadsheets
library(palmerpenguins)
t1 = t2 = head(penguins)
## change island variable to characters for easier modification
t2$island = t1$island = as.character(t1$island)
## change several entries in the second version
t2$island[3] = "Scotland"
t2$flipper_length_mm[1] = 18
sheet_comp(t1, t2, digits.signif = 4)
}
}
