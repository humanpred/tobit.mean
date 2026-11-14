test_that("tobit_status_codes is one row per code, each with a meaning", {
  expect_named(tobit_status_codes, c("status", "meaning"))
  expect_type(tobit_status_codes$status, "character")
  expect_false(anyDuplicated(tobit_status_codes$status) > 0)
  expect_true(all(grepl("^[a-z_]+$", tobit_status_codes$status)))
  expect_true(all(nzchar(tobit_status_codes$meaning)))
})

test_that("the documentation lists every status code", {
  rd <- tobit_status_rd()
  expect_equal(rd[1:2], c("@section Codes:", "\\describe{"))
  expect_equal(rd[length(rd)], "}")
  expect_equal(
    rd[-c(1, 2, length(rd))],
    sprintf("  \\item{\\code{\"%s\"}}{%s}", tobit_status_codes$status, tobit_status_codes$meaning)
  )
})

test_that("mean_tobit() reaches every status code, and each is the one its case gives", {
  cases <-
    list(
      no_values=function() mean_tobit(numeric(0)),
      all_na=function() mean_tobit(c(NA, NA)),
      na_not_removed=function() mean_tobit(c(NA, 1:10), lower=5, na.rm=FALSE),
      uncensored=function() mean_tobit(1:10),
      all_above_upper=function() mean_tobit(1:3, upper=1),
      all_below_lower=function() mean_tobit(1:3, lower=3),
      none_between=function() mean_tobit(c(1, 10), lower=1, upper=10),
      single_value=function() mean_tobit(c(1, 1, 1), lower=c(1, 0, 0)),
      converged=function() mean_tobit(1:10, lower=5, distribution="norm"),
      not_converged=function() mean_tobit(1:10, lower=5, distribution="norm", control=list(maxit=1)),
      optim_error=function() mean_tobit(1:10, lower=5, distribution="norm", gr=function(...) stop("no gradient"))
    )
  # A new code fails here until a case reaches it.
  expect_setequal(names(cases), tobit_status_codes$status)
  for (code in names(cases)) {
    result <- cases[[code]]()
    expect_s3_class(result, "mean_tobit")
    expect_equal(attr(result, "status", exact=TRUE), code, info=code)
  }
})

test_that("the status of a fit that did not converge or stopped says which, and the mean is NA", {
  not_converged <- mean_tobit(1:10, lower=5, distribution="norm", control=list(maxit=1))
  expect_true(is.na(as.numeric(not_converged)))
  optim_error <- mean_tobit(1:10, lower=5, distribution="norm", gr=function(...) stop("no gradient"))
  expect_true(is.na(as.numeric(optim_error)))
  expect_match(attr(optim_error, "message", exact=TRUE), "no gradient", fixed=TRUE)
})

test_that("geomean_tobit() and sd_tobit() carry the status of the mean", {
  expect_equal(attr(geomean_tobit(c(2, 2, 3, 5, 6, 8), lower=2, distribution="norm"), "status"), "converged")
  expect_equal(attr(geomean_tobit(1:10), "status", exact=TRUE), "uncensored")
  expect_equal(attr(geomean_tobit(numeric(0)), "status", exact=TRUE), "no_values")
  expect_equal(attr(geomean_tobit(c(1, 2), upper=1), "status", exact=TRUE), "all_above_upper")
  expect_equal(attr(sd_tobit(1:10, lower=5, distribution="norm"), "status", exact=TRUE), "converged")
  expect_equal(attr(as_sd_tobit(mean_tobit(1:3, lower=3)), "status", exact=TRUE), "all_below_lower")
  expect_equal(attr(as_sd_tobit(geomean_tobit(1:10)), "status", exact=TRUE), "uncensored")
  expect_equal(attr(as_geomean_tobit(mean_tobit(c(NA, NA))), "status", exact=TRUE), "all_na")
})

test_that("the constructors keep a known status and refuse another", {
  expect_equal(
    as_mean_tobit(1, 2, "foo", "converged"),
    structure(1, sd=2, message="foo", status="converged", class="mean_tobit")
  )
  expect_equal(
    as_geomean_tobit(1, 2, "foo", "converged"),
    structure(1, sd=2, message="foo", status="converged", class=c("geomean_tobit", "mean_tobit"))
  )
  expect_equal(
    as_sd_tobit(1, 2, "foo", "converged"),
    structure(2, mu=1, message="foo", status="converged", class="sd_tobit")
  )
  # Without a status, there is no attribute, as before.
  expect_null(attr(as_mean_tobit(1, 2, "foo"), "status", exact=TRUE))
  msg <- "'status' must be NULL or one of tobit_status_codes$status"
  expect_error(as_mean_tobit(1, 2, "foo", "unknown"), regexp=msg, fixed=TRUE)
  expect_error(as_mean_tobit(1, 2, "foo", c("converged", "converged")), regexp=msg, fixed=TRUE)
  expect_error(as_mean_tobit(1, 2, "foo", NA_character_), regexp=msg, fixed=TRUE)
  expect_error(as_mean_tobit(1, 2, "foo", 1), regexp=msg, fixed=TRUE)
})

test_that("a status given to a conversion is ignored with a warning, as a message is", {
  expect_warning(
    result <- as_sd_tobit(as_mean_tobit(1, 2, "foo", "converged"), status="uncensored"),
    regexp="'status' is ignored"
  )
  expect_equal(attr(result, "status", exact=TRUE), "converged")
  expect_warning(
    result <- as_geomean_tobit(as_mean_tobit(NA, NA, "foo", "all_na"), status="uncensored"),
    regexp="'status' is ignored"
  )
  expect_equal(attr(result, "status", exact=TRUE), "all_na")
})
