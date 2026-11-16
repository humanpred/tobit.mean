# Internal calculation functions ####

#' Estimate the log-likelihood for the gamma/delta transformed convex parameters
#' for tobit regression
#'
#' @details \code{beta = delta/gamma} and \code{sigma^2 = gamma^-2}.  The
#'   estimation is based on the convex reformulation of the likelihood function
#'   described in Olsen 1978.
#'
#' @param param c(gamma, delta) see details
#' @param x The vector of values
#' @param lower_limit,upper_limit The vector lower and upper limits for censoring
#' @param mask_lower,mask_between,mask_upper Boolean masks indicating if the
#'   value is below the lower limit, a point value, or above the upper limit
#' @param distribution The distribution to use.  For \code{"t"}, the degrees of
#'   freedom are \code{length(x)}.
#' @return The negative log-likelihood as a numeric scalar
#' @references Olsen RJ. Note on the Uniqueness of the Maximum Likelihood
#'   Estimator for the Tobit Model. Econometrica. 1978;46(5):1211-1215.
#'   \doi{10.2307/1911445}
#' @keywords internal
negLogLik_tobit <- function(param, x,
                            lower_limit, upper_limit,
                            mask_lower, mask_between, mask_upper,
                            distribution=c("t", "norm")) {
  # Input checks
  distribution <- match.arg(distribution)
  stopifnot(length(x) == length(lower_limit))
  stopifnot(length(x) == length(upper_limit))
  stopifnot(length(x) == length(mask_lower))
  stopifnot(length(x) == length(mask_between))
  stopifnot(length(x) == length(mask_upper))

  l_x <- length(x)
  stopifnot(
    "mask_lower, mask_between, and mask_upper may not overlap"=
      (sum(mask_lower) + sum(mask_between) + sum(mask_upper)) == l_x
  )
  stopifnot("param must have exactly 2 values"=length(param) == 2)
  # Parameter extraction
  gamma <- exp(param[1])
  delta <- param[2]

  xtrans_between <- gamma*x[mask_between] - delta
  xtrans_lower <- gamma*lower_limit[mask_lower] - delta
  xtrans_upper <- gamma*upper_limit[mask_upper] - delta
  loglik_i <-
    if (distribution == "norm") {
      c(
        log(gamma) + stats::dnorm(xtrans_between, log=TRUE),
        stats::pnorm(xtrans_lower, log.p=TRUE),
        stats::pnorm(xtrans_upper, lower.tail=FALSE, log.p=TRUE)
      )
    } else if (distribution == "t") {
      c(
        log(gamma) + stats::dt(xtrans_between, df=l_x, log=TRUE),
        stats::pt(xtrans_lower, df=l_x, log.p=TRUE),
        stats::pt(xtrans_upper, df=l_x, lower.tail=FALSE, log.p=TRUE)
      )
    } else {
      stop("Invalid distribution, please report this as a bug: ", distribution) # nocov
    }
  # Calculate the negative likelihood so that we can minimize the function
  return(-sum(loglik_i))
}

#' Check inputs x, lower, upper, and na.rm for the mean_tobit set of functions
#'
#' @inheritParams mean_tobit
#' @return A list with names of 'x', 'lower', and 'upper'.  If the result will
#'   be NA (due to all \code{NA} values or some \code{NA} values and
#'   \code{na.rm=FALSE}, then 'x' has class \code{mean_tobit} and can be
#'   considered the final result.  Otherwise, \code{NA} values have been removed
#'   from \code{x} and \code{lower} and \code{upper} are the same length as
#'   \code{x} with the correct elements removed based on the \code{NA} status of
#'   \code{x}.
#' @family mean_tobit Input Checks
#' @keywords internal
#' @noRd
mean_tobit_check_x_lower_upper <- function(x, lower, upper, na.rm) {
  x_clean <- mean_tobit_check_values(x=x, na.rm=na.rm)
  if (inherits(x_clean, what="mean_tobit")) {
    return(list(x=x_clean))
  }
  # No values in x_clean are NA, anymore
  mask_na <- is.na(x)
  stopifnot("lower must be a numeric"=is.numeric(lower))
  stopifnot("lower may not have missing values"=all(!is.na(lower)))
  stopifnot("lower must be a scalar or the same length as x"=length(lower) %in% c(1, length(x)))
  stopifnot("upper must be a numeric"=is.numeric(upper))
  stopifnot("upper may not have missing values"=all(!is.na(upper)))
  stopifnot("upper must be a scalar or the same length as x"=length(upper) %in% c(1, length(x)))
  stopifnot("each lower must be less than upper"=all(lower < upper))
  if (length(lower) != 1) {
    lower <- lower[!mask_na]
  } else {
    lower <- rep(lower, length(x_clean))
  }
  if (length(upper) != 1) {
    upper <- upper[!mask_na]
  } else {
    upper <- rep(upper, length(x_clean))
  }
  list(x=x_clean, lower=lower, upper=upper)
}

#' Check the values of x and na.rm for the mean_tobit set of functions
#'
#' @inheritParams mean_tobit
#' @return If \code{x} is all \code{NA} or if some of \code{x} is \code{NA} and
#'   \code{na.rm=FALSE}, then return a 'mean_tobit' class object with an
#'   \code{NA} value.  Otherwise, clean x of \code{NA} values and return the
#'   cleaned \code{x}.
#' @family mean_tobit Input Checks
#' @keywords internal
#' @noRd
mean_tobit_check_values <- function(x, na.rm) {
  if (inherits(x, what="mean_tobit")) {
    stop("'x' may not have class 'mean_tobit'")
  }
  if (length(x) == 0) {
    ret <- as_mean_tobit(mu=NA_real_, sd=NA_real_, message="No values were given", status="no_values")
  } else if (all(is.na(x))) {
    ret <- as_mean_tobit(mu=NA_real_, sd=NA_real_, message="All values were NA", status="all_na")
  } else if (any(is.na(x)) && !na.rm) {
    ret <-
      as_mean_tobit(
        mu=NA_real_, sd=NA_real_, message="Some values were NA, and na.rm=FALSE", status="na_not_removed"
      )
  } else {
    ret <- stats::na.omit(x)
  }
  ret
}

#' Location and scale used to standardize data before the tobit optimization
#'
#' Censored values are replaced by their censoring limit, and the mean and
#' standard deviation of the result are the location and scale.  The tobit
#' likelihood is location-scale equivariant, so fitting \code{(x - center)/scale}
#' and back-transforming gives the same estimate while keeping the optimizer's
#' parameters near \code{c(0, 0)}.
#'
#' @inheritParams negLogLik_tobit
#' @param lower,upper The censoring limits (the same length as \code{x})
#' @return A list with elements \code{center} and \code{scale}
#' @keywords internal
#' @noRd
tobit_standardization <- function(x, lower, upper, mask_lower, mask_upper) {
  x_start <- x
  x_start[mask_lower] <- lower[mask_lower]
  x_start[mask_upper] <- upper[mask_upper]
  scale <- stats::sd(x_start)
  if (!(scale > 0)) {
    # All values equal after replacing censored values with their limits; any
    # positive scale works.
    scale <- 1
  }
  list(center=mean(x_start), scale=scale)
}

#' Convert the fitted scale parameter to a standard deviation
#'
#' @param scale The fitted scale parameter
#' @param distribution The distribution used for fitting (\code{"t"} or
#'   \code{"norm"})
#' @param df The degrees of freedom (used and checked only for the t
#'   distribution)
#' @return The standard deviation; \code{NA} for the t distribution when
#'   \code{df <= 2} because its variance is not finite.
#' @keywords internal
#' @noRd
tobit_sd_from_scale <- function(scale, distribution=c("t", "norm"), df) {
  distribution <- match.arg(distribution)
  if (distribution == "norm") {
    return(scale)
  }
  stopifnot(
    "'df' must be a single, positive, non-NA number"=
      length(df) == 1 && !is.na(df) && df > 0
  )
  if (df > 2) {
    scale*sqrt(df/(df - 2))
  } else {
    NA_real_
  }
}

#' Convert an error from stats::optim() into a failed-convergence result
#'
#' @param e The error condition
#' @return A list shaped like the parts of the \code{stats::optim()} result that
#'   \code{mean_tobit()} uses, with \code{error = TRUE}
#' @keywords internal
#' @noRd
tobit_optim_error <- function(e) {
  list(convergence=-1L, message=conditionMessage(e), error=TRUE)
}
