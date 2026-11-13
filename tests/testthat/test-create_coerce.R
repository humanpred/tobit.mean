test_that("as_mean_tobit", {
  expect_equal(
    as_mean_tobit(1, 2, "foo"),
    structure(
      1,
      sd=2,
      message="foo",
      class="mean_tobit"
    )
  )
  expect_error(
    as_mean_tobit(1:2, 2, "foo"),
    regexp="'mu' must be a scalar"
  )
  expect_error(
    as_mean_tobit(2, 1:2, "foo"),
    regexp="'sd' must be a scalar"
  )
  expect_equal(
    as_mean_tobit(NA, NA_character_, "foo"),
    as_mean_tobit(NA_real_, NA_real_, "foo")
  )
  expect_error(
    as_mean_tobit("A", 2, "foo"),
    regexp="'mu' must be numeric"
  )
  expect_error(
    as_mean_tobit(2, "A", "foo"),
    regexp="'sd' must be numeric"
  )
  # sd may be NA when it cannot be estimated, but not when mu is NA
  expect_equal(
    as_mean_tobit(2, NA, "foo"),
    structure(2, sd=NA_real_, message="foo", class="mean_tobit")
  )
  expect_error(
    as_mean_tobit(NA, 2, "foo"),
    regexp="'sd' must be NA when 'mu' is NA"
  )
})

test_that("as_geomean_tobit", {
  expect_equal(
    as_geomean_tobit(1, 2, "foo"),
    structure(
      1,
      sd=2,
      message="foo",
      class=c("geomean_tobit", "mean_tobit")
    )
  )
  expect_error(
    as_geomean_tobit(as_mean_tobit(1, 2, "foo")),
    regexp="mean_tobit can only be converted to a geomean_tobit if it is NA"
  )
  expect_equal(
    as_geomean_tobit(as_mean_tobit(NA_real_, NA, "foo")),
    as_geomean_tobit(NA_real_, NA, "foo")
  )
  expect_warning(
    result <- as_geomean_tobit(as_mean_tobit(NA, NA, "foo"), sd=1),
    regexp="'sd' is ignored"
  )
  expect_equal(
    result,
    as_geomean_tobit(NA, NA, "foo")
  )
  expect_warning(
    result <- as_geomean_tobit(as_mean_tobit(NA, NA, "foo"), message="foo"),
    regexp="'message' is ignored"
  )
  expect_equal(
    result,
    as_geomean_tobit(NA, NA, "foo")
  )
})

test_that("as_cv_tobit", {
  expect_equal(
    as_cv_tobit(as_mean_tobit(1, 2)),
    200
  )
  expect_equal(
    as_cv_tobit(as_geomean_tobit(1, stats::sd(log(1:2)))),
    100*sqrt(exp(stats::sd(log(1:2))^2)-1)
  )
})

test_that("as_sd_tobit", {
  expect_equal(
    as_sd_tobit(1, 2, "foo"),
    structure(
      2,
      mu=1,
      message="foo",
      class="sd_tobit"
    )
  )
  expect_equal(
    as_sd_tobit(as_mean_tobit(1, 2, "foo")),
    structure(
      2,
      mu=1,
      message="foo",
      class=c("sd_tobit", "mean_tobit")
    )
  )
  expect_equal(
    as_sd_tobit(as_geomean_tobit(1, 2, "foo")),
    structure(
      2,
      mu=1,
      message="foo",
      class=c("sd_tobit", "geomean_tobit", "mean_tobit")
    )
  )
})

test_that("as_cv_tobit for sd_tobit objects", {
  # Arithmetic: 100*sd/mu
  expect_equal(as_cv_tobit(as_sd_tobit(4, 2)), 50)
  expect_equal(as_cv_tobit(as_sd_tobit(as_mean_tobit(4, 2))), 50)
  # Geometric: uses the log-scale sd regardless of mu
  expect_equal(
    as_cv_tobit(as_sd_tobit(as_geomean_tobit(4, 0.5))),
    as_cv_tobit(as_geomean_tobit(4, 0.5))
  )
  expect_equal(as_cv_tobit(as_geomean_tobit(4, 0.5)), 100*sqrt(exp(0.25) - 1))
  # NA sd gives NA CV
  expect_equal(as_cv_tobit(as_mean_tobit(4, NA)), NA_real_)
})

test_that("as_sd_tobit conversions", {
  # NA inputs are coerced to numeric NA
  expect_equal(
    as_sd_tobit(NA, NA),
    structure(NA_real_, mu=NA_real_, class="sd_tobit")
  )
  sd_obj <- as_sd_tobit(as_mean_tobit(1, 2, "foo"))
  expect_equal(as_sd_tobit(sd_obj), sd_obj)
  expect_warning(
    result <- as_sd_tobit(sd_obj, message="bar"),
    regexp="'message' is ignored"
  )
  expect_equal(result, sd_obj)
  expect_warning(
    result <- as_sd_tobit(as_mean_tobit(1, 2, "foo"), message="bar"),
    regexp="'message' is ignored"
  )
  expect_equal(result, sd_obj)
  expect_warning(
    result <- as_sd_tobit(as_geomean_tobit(1, 2, "foo"), sd=3),
    regexp="'sd' is ignored"
  )
  expect_equal(result, as_sd_tobit(as_geomean_tobit(1, 2, "foo")))
})
