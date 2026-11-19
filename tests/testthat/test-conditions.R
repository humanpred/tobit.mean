test_that("tobit_condition_classes is one row per class, named by one pattern", {
  classes <- tobit_condition_classes
  expect_named(classes, c("class", "type", "message", "meaning"))
  expect_false(anyDuplicated(classes$class) > 0)
  expect_true(all(grepl("^tobit_mean_(error|warning)_[a-z_]+$", classes$class)))
  expect_equal(classes$type, ifelse(grepl("^tobit_mean_error_", classes$class), "error", "warning"))
  expect_true(all(nzchar(classes$meaning)))
  # Every class has its fixed message but the internal one, whose message
  # names the check that failed.
  expect_equal(is.na(classes$message), classes$class == "tobit_mean_error_internal")
})

test_that("the documentation lists every condition class", {
  rd <- tobit_condition_rd()
  expect_equal(rd[1:2], c("@section Classes:", "\\describe{"))
  expect_equal(rd[length(rd)], "}")
  body <- rd[-c(1, 2, length(rd))]
  expect_length(body, nrow(tobit_condition_classes))
  for (i in seq_along(body)) {
    expect_true(startsWith(body[i], sprintf("  \\item{\\code{%s}}{", tobit_condition_classes$class[i])))
  }
})

# The first condition of class `class` that `expr` raises (other warnings
# are muffled), or the error it stops with
tobit_condition_of <- function(expr, class) {
  acc <- new.env(parent=emptyenv())
  acc$found <- NULL
  tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        if (inherits(w, class) && is.null(acc$found)) {
          acc$found <- w
        }
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      if (is.null(acc$found)) {
        acc$found <- e
      }
    }
  )
  acc$found
}

test_that("every class is raised through the real code path, with its message", {
  converged <- as_mean_tobit(1, 2, "foo", "converged")
  cases <-
    list(
      tobit_mean_error_mu_not_scalar=quote(as_mean_tobit(1:2, 2, "foo")),
      tobit_mean_error_sd_not_scalar=quote(as_mean_tobit(2, 1:2, "foo")),
      tobit_mean_error_mu_not_numeric=quote(as_mean_tobit("A", 2, "foo")),
      tobit_mean_error_sd_not_numeric=quote(as_mean_tobit(2, "A", "foo")),
      tobit_mean_error_sd_without_mu=quote(as_mean_tobit(NA, 2, "foo")),
      tobit_mean_error_status_invalid=quote(as_mean_tobit(1, 2, "foo", "unknown")),
      tobit_mean_error_convert_not_na=quote(as_geomean_tobit(as_mean_tobit(1, 2, "foo"))),
      tobit_mean_error_x_is_mean_tobit=quote(mean_tobit(as_mean_tobit(1, 1))),
      tobit_mean_error_lower_not_numeric=quote(mean_tobit(1:3, lower="A")),
      tobit_mean_error_lower_missing=quote(mean_tobit(1:3, lower=NA_real_)),
      tobit_mean_error_lower_length=quote(mean_tobit(1:3, lower=1:2)),
      tobit_mean_error_upper_not_numeric=quote(mean_tobit(1:3, upper="A")),
      tobit_mean_error_upper_missing=quote(mean_tobit(1:3, upper=NA_real_)),
      tobit_mean_error_upper_length=quote(mean_tobit(1:3, upper=1:2)),
      tobit_mean_error_limits_not_ordered=quote(mean_tobit(1:3, lower=2, upper=2)),
      tobit_mean_error_x_not_finite=quote(mean_tobit(c(1, Inf, 3), lower=0)),
      tobit_mean_error_geomean_nonpositive=quote(geomean_tobit(c(0, 1, 2), lower=0)),
      tobit_mean_error_geomean_upper_nonpositive=quote(geomean_tobit(c(1, 2), lower=-1, upper=0)),
      tobit_mean_error_internal=quote(negLogLik_tobit(c(0, 0), x=1:3, lower_limit=1:2, upper_limit=1:3,
                                                      mask_lower=rep(FALSE, 3), mask_between=rep(TRUE, 3),
                                                      mask_upper=rep(FALSE, 3), distribution="norm")),
      tobit_mean_warning_sd_ignored=quote(as_sd_tobit(converged, sd=1)),
      tobit_mean_warning_message_ignored=quote(as_sd_tobit(converged, message="bar")),
      tobit_mean_warning_status_ignored=quote(as_sd_tobit(converged, status="uncensored")),
      tobit_mean_warning_x_negative=quote(geomean_tobit(c(-1, 2, 3), lower=0.5)),
      tobit_mean_warning_lower_negative=quote(geomean_tobit(c(1, 2, 3), lower=c(-1, 0.5, 0.5)))
    )
  # A new class fails here until a case raises it.
  expect_setequal(names(cases), tobit_condition_classes$class)
  for (class in names(cases)) {
    cond <- tobit_condition_of(eval(cases[[class]]), class)
    type <- tobit_condition_classes$type[tobit_condition_classes$class == class]
    simple <- if (type == "error") "simpleError" else "simpleWarning"
    expect_equal(class(cond), c(class, paste0("tobit_mean_", type), simple, type, "condition"), info=class)
    message <- tobit_condition_classes$message[tobit_condition_classes$class == class]
    if (!is.na(message)) {
      expect_identical(conditionMessage(cond), message, info=class)
    }
  }
  expect_identical(
    conditionMessage(tobit_condition_of(eval(cases$tobit_mean_error_internal), "tobit_mean_error_internal")),
    "length(x) == length(lower_limit) is not TRUE"
  )
})

test_that("code that caught the errors and warnings, or matched their messages, keeps working", {
  expect_identical(
    tryCatch(mean_tobit(1:3, lower=2, upper=2), error=function(e) conditionMessage(e)),
    "each lower must be less than upper"
  )
  expect_error(mean_tobit(1:3, lower="A"), regexp="lower must be a numeric")
  expect_warning(geomean_tobit(c(-1, 2, 3), lower=0.5), regexp="some 'x' values were below zero")
  # The error is reported in the call that raised it, as stop() and
  # stopifnot() reported it.
  err <- tryCatch(mean_tobit(1:3, lower=2, upper=2), error=function(e) e)
  expect_identical(as.character(conditionCall(err)[[1]]), "mean_tobit_check_x_lower_upper")
  err <- tryCatch(geomean_tobit(c(0, 1, 2), lower=0), error=function(e) e)
  expect_identical(as.character(conditionCall(err)[[1]]), "geomean_tobit")
  # Every error has the package's parent class, and every warning its own,
  # in front of the classes stop() and warning() gave.
  expect_error(mean_tobit(1:3, lower=NA_real_), class="tobit_mean_error")
  expect_warning(geomean_tobit(c(-1, 2, 3), lower=0.5), class="tobit_mean_warning")
  err <- tryCatch(mean_tobit(1:3, lower=NA_real_), error=function(e) e)
  expect_true(inherits(err, "simpleError"))
  warn <- tryCatch(geomean_tobit(c(-1, 2, 3), lower=0.5), warning=function(w) w)
  expect_true(inherits(warn, "simpleWarning"))
})

# Every name and string constant of an expression, at any depth
tobit_code_words <- function(x) {
  if (is.character(x)) {
    return(x)
  }
  if (is.name(x)) {
    return(as.character(x))
  }
  if (is.call(x) || is.pairlist(x) || is.list(x)) {
    return(unlist(lapply(as.list(x), function(y) if (missing(y)) character(0) else tobit_code_words(y))))
  }
  character(0)
}

test_that("no function of the package raises a condition but through the helpers that give it a class", {
  ns <- asNamespace("tobit.mean")
  helpers <- c("tobit_abort", "tobit_warn", "tobit_condition_message")
  raisers <- c("stop", "warning", "stopifnot", "signalCondition", "simpleError", "simpleWarning")
  for (name in setdiff(ls(ns, all.names=TRUE), helpers)) {
    x <- get(name, envir=ns)
    if (is.function(x)) {
      # The body and the default arguments, names and strings alike, so a
      # call through do.call("stop") or match.fun() is found too.
      words <- c(tobit_code_words(body(x)), tobit_code_words(formals(x)))
      expect_identical(intersect(raisers, words), character(0), info=name)
    }
  }
  expect_identical(tobit_code_words(quote(do.call("stop", list("a")))), c("do.call", "stop", "list", "a"))
})

test_that("the helpers take each message from tobit_condition_classes", {
  internal <- "tobit_mean_error_internal"
  # The message raised is the one in the table, for every class with one.
  fixed <- tobit_condition_classes[!is.na(tobit_condition_classes$message), ]
  for (i in seq_len(nrow(fixed))) {
    raise <- if (fixed$type[i] == "error") tobit_abort else tobit_warn
    cond <- tobit_condition_of(raise(fixed$class[i]), fixed$class[i])
    expect_identical(conditionMessage(cond), fixed$message[i], info=fixed$class[i])
  }
  # The internal class has no fixed message: its detail is the message.
  expect_error(
    tobit_check(FALSE, internal, detail="the check"),
    regexp="^the check$", class=internal
  )
  expect_null(tobit_check(TRUE, internal, detail="the check"))
  # Unknown classes, a class of the other type, a detail for a fixed message,
  # and a missing detail are refused as bugs.
  expect_error(
    tobit_abort("tobit_mean_error_unknown"),
    regexp="Unknown error class: tobit_mean_error_unknown, please report this as a bug", class=internal
  )
  expect_error(
    tobit_warn(internal),
    regexp="Unknown warning class: tobit_mean_error_internal", class=internal
  )
  expect_error(
    tobit_abort("tobit_mean_warning_x_negative"),
    regexp="Unknown error class: tobit_mean_warning_x_negative", class=internal
  )
  expect_error(
    tobit_abort(c("tobit_mean_error_mu_not_scalar", "tobit_mean_error_sd_not_scalar")),
    regexp="Unknown error class: tobit_mean_error_mu_not_scalar, tobit_mean_error_sd_not_scalar", class=internal
  )
  three <- c("tobit_mean_error_mu_not_scalar", "tobit_mean_error_sd_not_scalar", "tobit_mean_error_internal")
  expect_error(tobit_abort(three), regexp="Unknown error class", class=internal)
  expect_error(tobit_abort(NA_character_), regexp="Unknown error class: NA", class=internal)
  expect_error(
    tobit_abort("tobit_mean_error_mu_not_scalar", detail="x"),
    regexp="The tobit_mean_error_mu_not_scalar condition has a fixed message and takes no detail", class=internal
  )
  expect_error(
    tobit_abort(internal),
    regexp="The tobit_mean_error_internal condition needs a detail", class=internal
  )
  expect_error(tobit_abort(internal, detail=NA_character_), regexp="needs a detail", class=internal)
  expect_error(tobit_abort(internal, detail=c("a", "b")), regexp="needs a detail", class=internal)
})
