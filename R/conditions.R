#' Classes of the errors and warnings of the censored statistics
#'
#' Every error and warning the package raises has a class from this table,
#' so a caller can handle one without matching its message. The classes
#' follow one pattern: \code{tobit_mean_error_<what>} for an error and
#' \code{tobit_mean_warning_<what>} for a warning, and every error also has
#' the class \code{"tobit_mean_error"} (every warning
#' \code{"tobit_mean_warning"}) before R's own \code{"error"} (or
#' \code{"warning"}) and \code{"condition"}. The messages are unchanged
#' from 0.1.0, so \code{tryCatch(..., error = )} and code that matches the
#' message keep working.
#'
#' @eval tobit_condition_rd()
#' @format A data.frame with one row per class: \code{class}, \code{type}
#'   (\code{"error"} or \code{"warning"}), \code{message} (the message, or
#'   \code{NA} for \code{"tobit_mean_error_internal"}, whose message names the
#'   check that failed), and \code{meaning}
#' @family Censored Descriptive Statistics
#' @examples
#' tobit_condition_classes
#' tryCatch(
#'   mean_tobit(1:3, lower = 2, upper = 2),
#'   tobit_mean_error_limits_not_ordered = function(e) conditionMessage(e)
#' )
#' @export
tobit_condition_classes <-
  rbind(
    data.frame(
      class="tobit_mean_error_mu_not_scalar", type="error", message="'mu' must be a scalar",
      meaning="The mean given to a constructor such as as_mean_tobit() is not one value."
    ),
    data.frame(
      class="tobit_mean_error_sd_not_scalar", type="error", message="'sd' must be a scalar",
      meaning="The standard deviation given to a constructor such as as_mean_tobit() is not one value."
    ),
    data.frame(
      class="tobit_mean_error_mu_not_numeric", type="error", message="'mu' must be numeric",
      meaning="The mean given to a constructor such as as_mean_tobit() is not a number."
    ),
    data.frame(
      class="tobit_mean_error_sd_not_numeric", type="error", message="'sd' must be numeric",
      meaning="The standard deviation given to a constructor such as as_mean_tobit() is not a number."
    ),
    data.frame(
      class="tobit_mean_error_sd_without_mu", type="error", message="'sd' must be NA when 'mu' is NA",
      meaning="A standard deviation was given with a missing mean."
    ),
    data.frame(
      class="tobit_mean_error_status_invalid", type="error",
      message="'status' must be NULL or one of tobit_status_codes$status",
      meaning="The status given to a constructor such as as_mean_tobit() is not one of tobit_status_codes."
    ),
    data.frame(
      class="tobit_mean_error_convert_not_na", type="error",
      message="mean_tobit can only be converted to a geomean_tobit if it is NA",
      meaning="A mean_tobit with a value was given to as_geomean_tobit()."
    ),
    data.frame(
      class="tobit_mean_error_x_is_mean_tobit", type="error", message="'x' may not have class 'mean_tobit'",
      meaning="A result of the package was given as the values."
    ),
    data.frame(
      class="tobit_mean_error_lower_not_numeric", type="error", message="lower must be a numeric",
      meaning="The lower limit is not numeric."
    ),
    data.frame(
      class="tobit_mean_error_lower_missing", type="error", message="lower may not have missing values",
      meaning="The lower limit has a missing value."
    ),
    data.frame(
      class="tobit_mean_error_lower_length", type="error", message="lower must be a scalar or the same length as x",
      meaning="The lower limit is neither one value nor one per value."
    ),
    data.frame(
      class="tobit_mean_error_upper_not_numeric", type="error", message="upper must be a numeric",
      meaning="The upper limit is not numeric."
    ),
    data.frame(
      class="tobit_mean_error_upper_missing", type="error", message="upper may not have missing values",
      meaning="The upper limit has a missing value."
    ),
    data.frame(
      class="tobit_mean_error_upper_length", type="error", message="upper must be a scalar or the same length as x",
      meaning="The upper limit is neither one value nor one per value."
    ),
    data.frame(
      class="tobit_mean_error_limits_not_ordered", type="error", message="each lower must be less than upper",
      meaning="A lower limit is not below its upper limit."
    ),
    data.frame(
      class="tobit_mean_error_x_not_finite", type="error",
      message="'x' must be finite unless it is censored at a finite limit",
      meaning="A value that is not censored, or a limit a censored value takes, is not finite."
    ),
    data.frame(
      class="tobit_mean_error_geomean_nonpositive", type="error",
      message="'x' and 'lower' cannot both be <= 0 at the same time",
      meaning="geomean_tobit() has a value and its lower limit both at or below zero."
    ),
    data.frame(
      class="tobit_mean_error_geomean_upper_nonpositive", type="error",
      message="some 'upper' values were at or below zero",
      meaning="geomean_tobit() has an upper limit at or below zero."
    ),
    data.frame(
      class="tobit_mean_error_internal", type="error", message=NA_character_,
      meaning="A check inside the package failed; its message names the check. Please report it as a bug."
    ),
    data.frame(
      class="tobit_mean_warning_sd_ignored", type="warning",
      message="'sd' is ignored for object conversion (sd is taken from the object)",
      meaning="A standard deviation was given to the conversion of a result, which keeps its own."
    ),
    data.frame(
      class="tobit_mean_warning_message_ignored", type="warning",
      message="'message' is ignored for object conversion (message is taken from the object)",
      meaning="A message was given to the conversion of a result, which keeps its own."
    ),
    data.frame(
      class="tobit_mean_warning_status_ignored", type="warning",
      message="'status' is ignored for object conversion (status is taken from the object)",
      meaning="A status was given to the conversion of a result, which keeps its own."
    ),
    data.frame(
      class="tobit_mean_warning_x_negative", type="warning",
      message="some 'x' values were below zero, setting to zero",
      meaning="geomean_tobit() set values below zero to zero."
    ),
    data.frame(
      class="tobit_mean_warning_lower_negative", type="warning",
      message="some 'lower' values were below zero, setting to zero",
      meaning="geomean_tobit() set lower limits below zero to zero."
    )
  )

#' The documentation of the condition classes, from the table itself
#'
#' @return Roxygen lines: a section listing \code{tobit_condition_classes}
#' @keywords internal
#' @noRd
tobit_condition_rd <- function() {
  message <- ifelse(is.na(tobit_condition_classes$message), "", sprintf(" (\"%s\")", tobit_condition_classes$message))
  c(
    "@section Classes:",
    "\\describe{",
    sprintf(
      "  \\item{\\code{%s}}{%s: %s%s}",
      tobit_condition_classes$class, tobit_condition_classes$type, tobit_condition_classes$meaning,
      gsub("([{}\\\\%])", "\\\\\\1", message)
    ),
    "}"
  )
}

#' Raise an error of one of the package's classes
#'
#' @param class A class of \code{tobit_condition_classes} with type
#'   \code{"error"}
#' @param message The message
#' @param call The call the error is reported in: that of the function that
#'   raises it, as \code{stop()} gives
#' @return Does not return
#' @keywords internal
#' @noRd
tobit_abort <- function(class, message, call=sys.call(-1)) {
  tobit_condition_assert(class, "error")
  stop(structure(class=c(class, "tobit_mean_error", "error", "condition"), list(message=message, call=call)))
}

#' Raise a warning of one of the package's classes
#'
#' @inheritParams tobit_abort
#' @return The message, invisibly, as \code{warning()} returns it
#' @keywords internal
#' @noRd
tobit_warn <- function(class, message, call=sys.call(-1)) {
  tobit_condition_assert(class, "warning")
  warning(structure(class=c(class, "tobit_mean_warning", "warning", "condition"), list(message=message, call=call)))
}

#' Raise an error of one of the package's classes unless a check holds
#'
#' As \code{stopifnot()}: the check holds when it is logical, has no
#' \code{NA}, and is all \code{TRUE}.
#'
#' @param check The check
#' @inheritParams tobit_abort
#' @return \code{NULL}, invisibly, when the check holds
#' @keywords internal
#' @noRd
tobit_check <- function(check, class, message) {
  if (!(is.logical(check) && !anyNA(check) && all(check))) {
    tobit_abort(class, message, call=sys.call(-1))
  }
  invisible(NULL)
}

#' Refuse a class that is not in the table
#'
#' @inheritParams tobit_abort
#' @param type \code{"error"} or \code{"warning"}
#' @return \code{NULL}, invisibly
#' @keywords internal
#' @noRd
tobit_condition_assert <- function(class, type) {
  known <- tobit_condition_classes$class[tobit_condition_classes$type == type]
  if (!(length(class) == 1 && class %in% known)) {
    stop(
      structure(
        class=c("tobit_mean_error_internal", "tobit_mean_error", "error", "condition"),
        list(message=paste("Unknown", type, "class, please report this as a bug:", paste(class, collapse=", ")), call=NULL)
      )
    )
  }
  invisible(NULL)
}
