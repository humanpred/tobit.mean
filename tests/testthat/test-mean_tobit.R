test_that("mean_tobit", {
  expect_equal(
    mean_tobit(1:10, distribution="norm"),
    structure(
      5.5, sd = sd(1:10),
      message = "All values between lower and upper, standard mean/sd calculated",
      class = "mean_tobit"
    )
  )

  expect_equal(
    mean_tobit(1:10, distribution="norm", lower = 5),
    structure(
      5.276756, sd = 0.4221968,
      message = "Successful convergence.  message from optim(): CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH",
      class = "mean_tobit"
    ),
    tolerance = 0.00001
  )

  expect_equal(
    mean_tobit(1:10, distribution="norm", lower = 2),
    structure(
      5.252022, sd = 0.4324225,
      message = "Successful convergence.  message from optim(): CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH",
      class = "mean_tobit"
    ),
    tolerance = 0.00001
  )
})
