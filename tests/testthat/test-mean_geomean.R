# Reference values are maximum likelihood estimates from
# survival::survreg(Surv(t1, t2, type = "interval2") ~ 1) with
# rel.tolerance = 1e-12, where censored values are open-ended intervals at
# their limit.  For dist = "t" (parms = df = length(x)), the standard deviation
# is scale*sqrt(df/(df - 2)).  The tolerance reflects stats::optim()'s default
# convergence criterion.
tol_mle <- 1e-5

expect_tobit <- function(object, mu, sd, message = NULL, tolerance = tol_mle) {
  expect_s3_class(object, "mean_tobit")
  expect_equal(as.numeric(object), mu, tolerance = tolerance)
  expect_equal(attr(object, "sd", exact = TRUE), sd, tolerance = tolerance)
  if (!is.null(message)) {
    expect_equal(attr(object, "message", exact = TRUE), message)
  }
}

msg_converged <- "Successful convergence.  message from stats::optim(): CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"

test_that("mean_tobit without censoring is the ordinary mean and sd", {
  expect_equal(
    mean_tobit(1:10, distribution="norm"),
    structure(
      5.5, sd = stats::sd(1:10),
      message = "All values between lower and upper, standard mean/sd calculated",
      class = "mean_tobit"
    )
  )
  # The distribution does not matter without censoring
  expect_equal(mean_tobit(1:10, distribution="t"), mean_tobit(1:10, distribution="norm"))
})

test_that("mean_tobit matches survreg for the normal distribution", {
  expect_tobit(
    mean_tobit(1:10, lower=5, distribution="norm"),
    mu=5.276773312, sd=3.188993582, message=msg_converged
  )
  expect_tobit(
    mean_tobit(1:10, upper=7, distribution="norm"),
    mu=5.800342405, sd=3.311776726, message=msg_converged
  )
  expect_tobit(
    mean_tobit(1:10, lower=3, upper=8, distribution="norm"),
    mu=5.5, sd=4.651107723, message=msg_converged
  )
  # Per-element limits
  expect_tobit(
    mean_tobit(c(0.5, 1, 2, 3, 4, 6), lower=c(1, 1, 1, 2.5, 0, 0), distribution="norm"),
    mu=2.309658957, sd=2.479604377, message=msg_converged
  )
})

test_that("mean_tobit matches survreg for the t distribution and reports its sd", {
  expect_tobit(
    mean_tobit(1:10, lower=5, distribution="t"),
    mu=5.323688428, sd=3.450330040, message=msg_converged
  )
  expect_tobit(
    mean_tobit(1:10, lower=3, upper=8, distribution="t"),
    mu=5.5, sd=5.016194530, message=msg_converged
  )
})

test_that("mean_tobit defaults to the t distribution and checks distribution", {
  expect_equal(
    mean_tobit(1:10, lower=5),
    mean_tobit(1:10, lower=5, distribution="t")
  )
  expect_error(
    mean_tobit(1:10, lower=5, distribution="foo"),
    regexp="'arg' should be one of"
  )
})

test_that("mean_tobit sd is NA for the t distribution with df <= 2", {
  result <- mean_tobit(c(1, 2), lower=1.5, distribution="t")
  expect_false(is.na(as.numeric(result)))
  expect_true(is.na(attr(result, "sd", exact=TRUE)))
  # With df = 3 the sd is estimable
  expect_false(is.na(attr(mean_tobit(c(1, 2, 3), lower=1.5, distribution="t"), "sd", exact=TRUE)))
})

test_that("mean_tobit include_equal arguments control censoring at the limit", {
  # With include_equal=FALSE, 5 is observed and 1 to 4 are censored below 5
  expect_tobit(
    mean_tobit(1:10, lower=5, include_equal=FALSE, distribution="norm"),
    mu=5.734342486, sd=2.707546943
  )
  expect_equal(
    mean_tobit(1:10, lower=5, include_equal_lower=FALSE, distribution="norm"),
    mean_tobit(1:10, lower=5, include_equal=FALSE, distribution="norm")
  )
  # 7 is observed and 8 to 10 are censored above 7
  expect_tobit(
    mean_tobit(1:10, upper=7, include_equal_upper=FALSE, distribution="norm"),
    mu=5.446710726, sd=2.887928701
  )
})

test_that("mean_tobit handles NA values", {
  expect_equal(
    mean_tobit(c(NA, 1:10), lower=5, distribution="norm"),
    mean_tobit(1:10, lower=5, distribution="norm")
  )
  # Per-element limits drop the elements matching NA values of x
  expect_equal(
    mean_tobit(c(NA, 1:10), lower=c(100, rep(5, 10)), distribution="norm"),
    mean_tobit(1:10, lower=5, distribution="norm")
  )
  expect_equal(
    mean_tobit(c(NA, 1:10), lower=5, na.rm=FALSE),
    as_mean_tobit(NA_real_, NA_real_, "Some values were NA, and na.rm=FALSE")
  )
  expect_equal(
    mean_tobit(c(NA, NA)),
    as_mean_tobit(NA_real_, NA_real_, "All values were NA")
  )
  expect_equal(
    mean_tobit(numeric(0)),
    as_mean_tobit(NA_real_, NA_real_, "No values were given")
  )
})

test_that("mean_tobit degenerate censoring patterns", {
  expect_equal(
    mean_tobit(1:3, upper=1),
    as_mean_tobit(NA_real_, NA_real_, "all values above upper")
  )
  expect_equal(
    mean_tobit(1:3, lower=3),
    as_mean_tobit(NA_real_, NA_real_, "all values below lower")
  )
  expect_equal(
    mean_tobit(c(1, 10), lower=1, upper=10),
    as_mean_tobit(NA_real_, NA_real_, "no values between lower and upper")
  )
  expect_equal(
    mean_tobit(c(1, 1, 1), lower=c(1, 0, 0)),
    as_mean_tobit(1, NA_real_, "single unique value")
  )
  expect_equal(
    mean_tobit(5),
    as_mean_tobit(5, NA_real_, "All values between lower and upper, standard mean/sd calculated")
  )
})

test_that("mean_tobit reports failed convergence", {
  result <- mean_tobit(1:10, lower=5, distribution="norm", control=list(maxit=1))
  expect_s3_class(result, "mean_tobit")
  expect_true(is.na(as.numeric(result)))
  expect_true(is.na(attr(result, "sd", exact=TRUE)))
  expect_match(
    attr(result, "message", exact=TRUE),
    "^Failed convergence\\.  message from stats::optim\\(\\): "
  )
})

test_that("mean_tobit is stable for data with a small spread and a large offset", {
  # Without standardization, the optimizer stepped to non-finite likelihoods
  # here and stats::optim() raised an error.
  expect_tobit(
    mean_tobit(
      c(4.997, 5.005, 5.014, 5.006, 5.005, 5.012, 5.011, 5.001),
      lower=5.011718, distribution="norm"
    ),
    mu=5.010303394339, sd=0.002111172294, message=msg_converged,
    tolerance=1e-4
  )
  # Shifting and scaling the data shifts and scales the estimate
  base <- mean_tobit(1:10, lower=5, upper=8, distribution="norm")
  shifted <- mean_tobit(1e5 + (1:10)/1e3, lower=1e5 + 5/1e3, upper=1e5 + 8/1e3, distribution="norm")
  expect_equal(as.numeric(shifted), 1e5 + as.numeric(base)/1e3, tolerance=1e-10)
  expect_equal(attr(shifted, "sd", exact=TRUE), attr(base, "sd", exact=TRUE)/1e3, tolerance=1e-4)
})

test_that("mean_tobit requires finite x unless censored at a finite limit", {
  msg <- "'x' must be finite unless it is censored at a finite limit"
  expect_error(mean_tobit(c(1, Inf, 3), lower=0), regexp=msg)
  expect_error(mean_tobit(c(-Inf, 2, 3), lower=-Inf, upper=2.5), regexp=msg)
  expect_error(mean_tobit(c(1, 2, Inf), lower=1.5, upper=Inf), regexp=msg)
  # -Inf censored at a finite lower limit is an ordinary censored value
  expect_equal(
    mean_tobit(c(-Inf, 2, 3, 4), lower=1, distribution="norm"),
    mean_tobit(c(0, 2, 3, 4), lower=1, distribution="norm")
  )
})

test_that("mean_tobit input checks", {
  expect_error(mean_tobit(as_mean_tobit(1, 1)), regexp="'x' may not have class 'mean_tobit'")
  expect_error(mean_tobit(1:3, lower="A"), regexp="lower must be a numeric")
  expect_error(mean_tobit(1:3, lower=NA_real_), regexp="lower may not have missing values")
  expect_error(mean_tobit(1:3, lower=1:2), regexp="lower must be a scalar or the same length as x")
  expect_error(mean_tobit(1:3, upper="A"), regexp="upper must be a numeric")
  expect_error(mean_tobit(1:3, upper=NA_real_), regexp="upper may not have missing values")
  expect_error(mean_tobit(1:3, upper=1:2), regexp="upper must be a scalar or the same length as x")
  expect_error(mean_tobit(1:3, lower=2, upper=2), regexp="each lower must be less than upper")
})

test_that("sd_tobit", {
  expect_equal(
    sd_tobit(1:10, lower=5, distribution="norm"),
    as_sd_tobit(mean_tobit(1:10, lower=5, distribution="norm"))
  )
  expect_equal(
    as.numeric(sd_tobit(1:10, lower=5, distribution="norm")),
    3.188993582,
    tolerance=tol_mle
  )
})

test_that("geomean_tobit matches survreg on the log scale", {
  result <- geomean_tobit(c(2, 2, 3, 5, 6, 8), lower=2, distribution="norm")
  expect_s3_class(result, "geomean_tobit")
  expect_tobit(result, mu=3.2357458781, sd=0.7585050401, message=msg_converged)
  # Equivalent to exponentiating the censored mean of the log values
  log_result <- mean_tobit(log(c(2, 2, 3, 5, 6, 8)), lower=log(2), distribution="norm")
  expect_equal(as.numeric(result), exp(as.numeric(log_result)))
  # No censoring gives the ordinary geometric mean
  expect_equal(
    as.numeric(geomean_tobit(c(1, 10, 100))),
    10
  )
})

test_that("geomean_tobit with zeros below a positive lower limit", {
  expect_equal(
    geomean_tobit(c(0, 0.5, 1, 3, 4, 9), lower=0.8, distribution="norm"),
    geomean_tobit(c(0.1, 0.5, 1, 3, 4, 9), lower=0.8, distribution="norm")
  )
})

test_that("geomean_tobit NA results keep the geomean_tobit class", {
  expect_equal(
    geomean_tobit(c(NA, NA)),
    as_geomean_tobit(NA_real_, NA_real_, "All values were NA")
  )
  expect_equal(
    geomean_tobit(c(1, 2), upper=1),
    as_geomean_tobit(NA_real_, NA_real_, "all values above upper")
  )
})

test_that("geomean_tobit checks for values at or below zero", {
  expect_error(
    geomean_tobit(c(0, 1, 2)),
    regexp="'x' and 'lower' cannot both be <= 0 at the same time"
  )
  expect_warning(
    result <- geomean_tobit(c(-1, 1, 2, 3), lower=0.5, distribution="norm"),
    regexp="some 'x' values were below zero, setting to zero"
  )
  expect_equal(result, geomean_tobit(c(0, 1, 2, 3), lower=0.5, distribution="norm"))
  expect_warning(
    result <- geomean_tobit(c(1, 2, 3), lower=c(-1, 1.5, 1.5), distribution="norm"),
    regexp="some 'lower' values were below zero, setting to zero"
  )
  expect_equal(result, geomean_tobit(c(1, 2, 3), lower=c(0, 1.5, 1.5), distribution="norm"))
  # A non-positive upper limit implies a negative lower limit, which also warns
  expect_error(
    suppressWarnings(geomean_tobit(c(1, 2, 3), lower=-2, upper=0)),
    regexp="some 'upper' values were at or below zero"
  )
})
