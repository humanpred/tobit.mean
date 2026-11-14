#' Status codes of a censored mean
#'
#' The \code{"status"} attribute of the results of \code{mean_tobit()},
#' \code{geomean_tobit()}, and \code{sd_tobit()} is one of these codes.  It
#' says how the result was reached, so a caller can act on it without reading
#' the \code{"message"} attribute, whose text may change.
#'
#' @eval tobit_status_rd()
#' @format A data.frame with one row per code: \code{status} (the code) and
#'   \code{meaning}
#' @family Censored Descriptive Statistics
#' @examples
#' tobit_status_codes
#' attr(mean_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm"), "status")
#' @export
tobit_status_codes <-
  rbind(
    data.frame(
      status="no_values",
      meaning="No values were given; the mean is NA."
    ),
    data.frame(
      status="all_na",
      meaning="All values were NA; the mean is NA."
    ),
    data.frame(
      status="na_not_removed",
      meaning="Some values were NA and na.rm is FALSE; the mean is NA."
    ),
    data.frame(
      status="uncensored",
      meaning="No value was censored; the mean and standard deviation are the ordinary ones."
    ),
    data.frame(
      status="all_above_upper",
      meaning="Every value was censored at the upper limit; the mean is NA."
    ),
    data.frame(
      status="all_below_lower",
      meaning="Every value was censored at the lower limit; the mean is NA."
    ),
    data.frame(
      status="none_between",
      meaning="Every value was censored, some at the lower limit and some at the upper; the mean is NA."
    ),
    data.frame(
      status="single_value",
      meaning=paste(
        "Some values were censored and all values were equal; the mean is that value and the standard",
        "deviation is NA."
      )
    ),
    data.frame(
      status="converged",
      meaning="The censored model was fit and stats::optim() converged."
    ),
    data.frame(
      status="not_converged",
      meaning="stats::optim() did not converge; the mean is NA."
    ),
    data.frame(
      status="optim_error",
      meaning="stats::optim() stopped with an error; the mean is NA."
    )
  )

#' The documentation of the status codes, from the codes themselves
#'
#' @return Roxygen lines: a section listing \code{tobit_status_codes}
#' @keywords internal
#' @noRd
tobit_status_rd <- function() {
  c(
    "@section Codes:",
    "\\describe{",
    sprintf("  \\item{\\code{\"%s\"}}{%s}", tobit_status_codes$status, tobit_status_codes$meaning),
    "}"
  )
}
