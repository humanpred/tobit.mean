#' Calculate a censored mean
#'
#' @param x A numeric vector
#' @param lower,upper The lower and upper bounds for censoring \code{x}
#' @param include_equal,include_equal_lower,include_equal_upper Should the
#'   bounds consider \code{x <= lower} and \code{x >= upper} (if \code{TRUE}) or
#'   \code{x < lower} and \code{x > upper} (if \code{FALSE}) to be censored?
#'   (\code{include_equal} is overridden by setting \code{include_equal_lower}
#'   or \code{include_equal_upper}.)
#' @param distribution What distribution (Student \code{"t"}, the default, or
#'   normal, \code{"norm"}) should be used.  If \code{"t"}, the degrees of
#'   freedom are the number of non-\code{NA} values in \code{x}, and the
#'   reported standard deviation is that of the fitted t distribution
#'   (\code{scale*sqrt(df/(df - 2))}), which is \code{NA} when there are two or
#'   fewer values.
#' @param na.rm A logical value indicating whether \code{NA} values should be
#'   stripped from \code{x} before the computation proceeds.
#' @inheritDotParams stats::optim
#' @details When no values are censored, the ordinary \code{mean()} and
#'   \code{sd()} are returned.  When there are no uncensored values, the mean
#'   cannot be estimated and \code{NA} is returned.  When all values are equal
#'   (and some, but not all, are censored), the mean is that value and the
#'   standard deviation is \code{NA}.
#'
#'   Values of \code{x} must be finite unless they are censored at a finite
#'   limit (for example, \code{-Inf} with \code{lower = 0}).
#' @return A 'mean_tobit' object which is a number with attributes for the
#'   standard deviation (sd), convergence information in the "message"
#'   attribute, and how the result was reached in the "status" attribute, one
#'   of \code{tobit_status_codes$status}.
#' @references Tobin J. Estimation of Relationships for Limited Dependent
#'   Variables. Econometrica. 1958;26(1):24-36. \doi{10.2307/1907382}
#'
#'   Olsen RJ. Note on the Uniqueness of the Maximum Likelihood Estimator for
#'   the Tobit Model. Econometrica. 1978;46(5):1211-1215.
#'   \doi{10.2307/1911445}
#' @family Censored Descriptive Statistics
#' @examples
#' # Values at or below 2 are censored (for example, below a limit of
#' # quantification)
#' mean_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm")
#' @export
mean_tobit <- function(x,
                       lower=-Inf, upper=Inf,
                       include_equal=TRUE, include_equal_lower=include_equal, include_equal_upper=include_equal,
                       distribution=c("t", "norm"),
                       na.rm=TRUE, ...) {
  distribution <- match.arg(distribution)
  x_lower_and_upper <-
    mean_tobit_check_x_lower_upper(
      x=x,
      lower=lower,
      upper=upper,
      na.rm=na.rm
    )
  x <- x_lower_and_upper$x
  if (inherits(x, what="mean_tobit")) {
    # na.rm or all NA values triggered a result without more math required
    return(x)
  }
  lower <- x_lower_and_upper$lower
  upper <- x_lower_and_upper$upper
  mask_upper <-
    if (include_equal_upper) {
      x >= upper
    } else {
      x > upper
    }
  mask_lower <-
    if (include_equal_lower) {
      x <= lower
    } else {
      x < lower
    }
  # A value can satisfy both masks only if lower >= upper, which is refused
  # above, so every value is in exactly one mask.
  mask_between <- !(mask_upper | mask_lower)
  stopifnot(
    "'x' must be finite unless it is censored at a finite limit"=
      all(is.finite(x[mask_between])) &&
      all(is.finite(lower[mask_lower])) &&
      all(is.finite(upper[mask_upper]))
  )
  if (all(mask_between)) {
    ret <-
      as_mean_tobit(
        mu=mean(x), sd=stats::sd(x),
        message="All values between lower and upper, standard mean/sd calculated", status="uncensored"
      )
  } else if (all(mask_upper)) {
    ret <- as_mean_tobit(mu=NA_real_, sd=NA_real_, message="all values above upper", status="all_above_upper")
  } else if (all(mask_lower)) {
    ret <- as_mean_tobit(mu=NA_real_, sd=NA_real_, message="all values below lower", status="all_below_lower")
  } else if (!any(mask_between)) {
    ret <-
      as_mean_tobit(mu=NA_real_, sd=NA_real_, message="no values between lower and upper", status="none_between")
  } else if (all(x == x[1])) {
    ret <- as_mean_tobit(mu=x[1], sd=NA_real_, message="single unique value", status="single_value")
  } else {
    std <- tobit_standardization(x=x, lower=lower, upper=upper, mask_lower=mask_lower, mask_upper=mask_upper)
    ret_prep <-
      tryCatch(
        stats::optim(
          par=c(0, 0),
          fn=negLogLik_tobit,
          method="L-BFGS-B",
          x=(x - std$center)/std$scale,
          lower_limit=(lower - std$center)/std$scale,
          upper_limit=(upper - std$center)/std$scale,
          mask_lower=mask_lower,
          mask_between=mask_between,
          mask_upper=mask_upper,
          distribution=distribution,
          ...
        ),
        error=tobit_optim_error
      )
    if (ret_prep$convergence == 0) {
      # Successful convergence; param = c(log(gamma), delta) with
      # gamma = 1/scale and delta = mu/scale (see negLogLik_tobit()) on the
      # standardized data
      scale_std <- exp(-ret_prep$par[1])
      scale_est <- std$scale*scale_std
      mu_est <- std$center + std$scale*ret_prep$par[2]*scale_std
      sd_est <- tobit_sd_from_scale(scale=scale_est, distribution=distribution, df=length(x))
      ret <-
        as_mean_tobit(
          mu=mu_est,
          sd=sd_est,
          message=
            paste(
              "Successful convergence.  message from stats::optim():",
              ret_prep$message
            ),
          status="converged"
        )
    } else {
      # Unsuccessful convergence
      ret <-
        as_mean_tobit(
          mu=NA_real_,
          sd=NA_real_,
          message=
            paste(
              "Failed convergence.  message from stats::optim():",
              ret_prep$message
            ),
          status=if (isTRUE(ret_prep$error)) "optim_error" else "not_converged"
        )
    }
  }
  ret
}

#' Calculate the censored standard deviation
#'
#' Since the standard deviation is almost always desired with the mean, it is
#' more efficient to use \code{as_sd_tobit()} on the mean object instead of
#' calculating the standard deviation separately.
#'
#' @inheritDotParams mean_tobit
#' @return A "sd_tobit" class object
#' @family Censored Descriptive Statistics
#' @examples
#' sd_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm")
#' @export
sd_tobit <- function(...) {
  as_sd_tobit(mean_tobit(...))
}

#' Calculate the censored geometric mean
#'
#' The geometric mean is calculated as the exponential of the censored mean of
#' \code{log(x)}.
#'
#' @inheritParams mean_tobit
#' @inheritDotParams mean_tobit
#' @return A "geomean_tobit" class object (which also has the "mean_tobit"
#'   class) which is a number with attributes for the standard deviation of
#'   \code{log(x)} (sd), convergence information in the "message" attribute,
#'   and how the result was reached in the "status" attribute, one of
#'   \code{tobit_status_codes$status}.
#' @family Censored Descriptive Statistics
#' @examples
#' geomean_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm")
#' @export
geomean_tobit <- function(x, lower=0, upper=Inf, na.rm=TRUE, ...) {
  x_lower_and_upper <-
    mean_tobit_check_x_lower_upper(
      x=x,
      lower=lower,
      upper=upper,
      na.rm=na.rm
    )
  x <- x_lower_and_upper$x
  if (inherits(x, what="mean_tobit")) {
    # na.rm or all NA values triggered a result without more math required
    return(as_geomean_tobit(x))
  }
  lower <- x_lower_and_upper$lower
  upper <- x_lower_and_upper$upper
  mask_lower_x_problem <- x <= 0 & lower <= 0
  if (any(mask_lower_x_problem)) {
    stop("'x' and 'lower' cannot both be <= 0 at the same time")
  }
  mask_negative_x <- x < 0
  if (any(mask_negative_x)) {
    warning("some 'x' values were below zero, setting to zero")
    x[mask_negative_x] <- 0
  }
  mask_negative_lower <- lower < 0
  if (any(mask_negative_lower)) {
    warning("some 'lower' values were below zero, setting to zero")
    lower[mask_negative_lower] <- 0
  }
  if (any(upper <= 0)) {
    stop("some 'upper' values were at or below zero")
  }
  ret_prep <- mean_tobit(x=log(x), lower=log(lower), upper=log(upper), na.rm=na.rm, ...)
  as_geomean_tobit(
    mu=exp(as.numeric(ret_prep)),
    sd=attr(ret_prep, "sd", exact=TRUE),
    message=attr(ret_prep, "message", exact=TRUE),
    status=attr(ret_prep, "status", exact=TRUE)
  )
}
