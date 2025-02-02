# tobit.mean

<!-- badges: start -->
[![R-CMD-check](https://github.com/humanpred/tobit.mean/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/humanpred/tobit.mean/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/humanpred/tobit.mean/graph/badge.svg)](https://app.codecov.io/gh/humanpred/tobit.mean)
[![CRAN status](https://www.r-pkg.org/badges/version/tobit.mean)](https://CRAN.R-project.org/package=tobit.mean)
<!-- badges: end -->

The goal of tobit.mean is to calculate descriptive statistics of censored vectors.

## Installation

You can install the development version of tobit.mean from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("humanpred/tobit.mean")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tobit.mean)
tobit.mean::mean_tobit(c(0, 1, 4, 10), lower = 0.5, distribution = "t")
```
