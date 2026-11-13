# The tests are run via the main code to confirm that the internals are working
# as expected when there is a simple, direct test for the internal function from
# the main code.

test_that("negLogLik_tobit", {
  # Upper-censored values contribute P(X >= upper), lower-censored values
  # P(X <= lower), and observed values the density.
  expect_error(
    negLogLik_tobit(distribution="foo")
  )
  expect_error(
    negLogLik_tobit(x=1:2, lower_limit=1:3),
    regexp="length(x) == length(lower_limit) is not TRUE",
    fixed=TRUE
  )
  expect_error(
    negLogLik_tobit(x=1:2, lower_limit=1:2, upper_limit=3:5),
    regexp="length(x) == length(upper_limit) is not TRUE",
    fixed=TRUE
  )
  expect_error(
    negLogLik_tobit(x=1:2, lower_limit=1:2, upper_limit=3:4, mask_lower=c(TRUE, FALSE, FALSE)),
    regexp="length(x) == length(mask_lower) is not TRUE",
    fixed=TRUE
  )
  expect_error(
    negLogLik_tobit(x=1:2, lower_limit=1:2, upper_limit=3:4, mask_lower=c(TRUE, FALSE), mask_between=c(FALSE, FALSE, FALSE)),
    regexp="length(x) == length(mask_between) is not TRUE",
    fixed=TRUE
  )
  expect_error(
    negLogLik_tobit(x=1:2, lower_limit=1:2, upper_limit=3:4, mask_lower=c(TRUE, FALSE), mask_between=c(FALSE, FALSE), mask_upper=c(FALSE, FALSE, FALSE)),
    regexp="length(x) == length(mask_upper) is not TRUE",
    fixed=TRUE
  )
  expect_error(
    negLogLik_tobit(
      x=1:2, lower_limit=1:2, upper_limit=3:4,
      mask_lower=c(FALSE, TRUE), mask_between=c(FALSE, TRUE), mask_upper=c(FALSE, TRUE)
    ),
    regexp="mask_lower, mask_between, and mask_upper may not overlap"
  )
  expect_error(
    negLogLik_tobit(
      x=1:2, lower_limit=1:2, upper_limit=3:4,
      mask_lower=c(TRUE, TRUE), mask_between=c(FALSE, TRUE), mask_upper=c(FALSE, TRUE)
    ),
    regexp="mask_lower, mask_between, and mask_upper may not overlap"
  )
  expect_error(
    negLogLik_tobit(
      param=c(1, log(2), 1),
      x=1:3,
      lower_limit=rep(1.5, 3), upper_limit=rep(4, 3),
      mask_lower=c(TRUE, FALSE, FALSE),
      mask_between=c(FALSE, TRUE, FALSE),
      mask_upper=c(FALSE, FALSE, TRUE)
    ),
    regexp="param must have exactly 2 values"
  )
  expect_equal(
    negLogLik_tobit(
      param=c(2, 3),
      x=1:3,
      lower_limit=rep(1.5, 3), upper_limit=rep(4, 3),
      mask_lower=c(TRUE, FALSE, FALSE),
      mask_between=c(FALSE, TRUE, FALSE),
      mask_upper=c(FALSE, FALSE, TRUE),
      distribution="t"
    ),
    -sum(
      c(
        log(exp(2)) + dt(exp(2)*2 - 3, df=3, log=TRUE),
        pt(exp(2)*1.5 - 3, df=3, log.p=TRUE),
        pt(exp(2)*4 - 3, df=3, lower.tail=FALSE, log.p=TRUE)
      )
    )
  )
  expect_equal(
    negLogLik_tobit(
      param=c(1, log(2)),
      x=1:3,
      lower_limit=rep(1.5, 3), upper_limit=rep(4, 3),
      mask_lower=c(TRUE, FALSE, FALSE),
      mask_between=c(FALSE, TRUE, FALSE),
      mask_upper=c(FALSE, FALSE, TRUE)
    ),
    -sum(
      c(
        log(exp(1)) + dt(exp(1)*2 - log(2), df=3, log=TRUE),
        pt(exp(1)*1.5 - log(2), df=3, log.p=TRUE),
        pt(exp(1)*4 - log(2), df=3, lower.tail=FALSE, log.p=TRUE)
      )
    )
  )
})

test_that("negLogLik_tobit for the normal distribution", {
  # param = c(log(1/sigma), mu/sigma) with mu = 2, sigma = 0.5
  expect_equal(
    negLogLik_tobit(
      param=c(log(2), 4),
      x=1:3,
      lower_limit=rep(1.5, 3), upper_limit=rep(2.5, 3),
      mask_lower=c(TRUE, FALSE, FALSE),
      mask_between=c(FALSE, TRUE, FALSE),
      mask_upper=c(FALSE, FALSE, TRUE),
      distribution="norm"
    ),
    -sum(
      c(
        dnorm(2, mean=2, sd=0.5, log=TRUE),
        pnorm(1.5, mean=2, sd=0.5, log.p=TRUE),
        pnorm(2.5, mean=2, sd=0.5, lower.tail=FALSE, log.p=TRUE)
      )
    )
  )
})

test_that("tobit_standardization", {
  # Censored values are replaced by their limits: c(5, 5, 6, 10)
  expect_equal(
    tobit_standardization(
      x=c(1, 5, 6, 12), lower=rep(5, 4), upper=rep(10, 4),
      mask_lower=c(TRUE, TRUE, FALSE, FALSE), mask_upper=c(FALSE, FALSE, FALSE, TRUE)
    ),
    list(center=mean(c(5, 5, 6, 10)), scale=sd(c(5, 5, 6, 10)))
  )
  # All equal after replacement uses a unit scale
  expect_equal(
    tobit_standardization(
      x=c(4, 5), lower=c(5, 5), upper=c(Inf, Inf),
      mask_lower=c(TRUE, FALSE), mask_upper=c(FALSE, FALSE)
    ),
    list(center=5, scale=1)
  )
})

test_that("tobit_optim_error", {
  expect_equal(
    tobit_optim_error(simpleError("foo")),
    list(convergence=-1L, message="foo")
  )
})

test_that("tobit_sd_from_scale", {
  expect_equal(tobit_sd_from_scale(2, distribution="norm", df=1), 2)
  expect_equal(tobit_sd_from_scale(2, distribution="t", df=10), 2*sqrt(10/8))
  expect_equal(tobit_sd_from_scale(2, distribution="t", df=2), NA_real_)
  # df is not used (or checked) for the normal distribution
  expect_equal(tobit_sd_from_scale(2, distribution="norm", df=NA), 2)
  expect_error(
    tobit_sd_from_scale(2, distribution="foo", df=10),
    regexp="'arg' should be one of"
  )
  msg_df <- "'df' must be a single, positive, non-NA number"
  expect_error(tobit_sd_from_scale(2, distribution="t", df=NA), regexp=msg_df)
  expect_error(tobit_sd_from_scale(2, distribution="t", df=0), regexp=msg_df)
  expect_error(tobit_sd_from_scale(2, distribution="t", df=c(3, 4)), regexp=msg_df)
})
