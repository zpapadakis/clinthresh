# clinthresh

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24022248.svg)](https://doi.org/10.5281/zenodo.24022248) [![Web app](https://img.shields.io/badge/web%20app-open-1f6f8b)](https://zpapadakis.github.io/clinthresh/)

**Clinical thresholds, equivalence tests and replicability tools for sports medicine research**

A non-significant P value does not show that two treatments are equivalent, and a significant one does not show that an effect matters. `clinthresh` helps clinicians, authors and reviewers read a result against a threshold of clinical importance instead of against zero. It works from the numbers printed in an abstract, so you do not need the raw data.

It accompanies the invited review *Statistically Significant, Clinically Meaningful, or Neither? Clinical Thresholds, Equivalence Testing, and Replicability in Sports Medicine Rehabilitation* (Current Physical Medicine and Rehabilitation Reports, 2027).

## No R? Use the web app

**[Open the free web app](https://zpapadakis.github.io/clinthresh/)** to interpret a published result, test non-inferiority, plan a trial, compute SWC and MDC, or browse the threshold table. It runs entirely in your browser; nothing you type is sent anywhere. (`run_app()` opens the same tools as a Shiny app from R.)

## Install

```r
# install.packages("remotes")
remotes::install_github("zpapadakis/clinthresh")
```

## What it does

| Question | Function |
|---|---|
| Does this published result show a clinically important effect, a trivial one, equivalence, or nothing conclusive? | `tost_ci()`, `classify_ci()` |
| I have an estimate and a standard error | `tost_se()` |
| Write the interpretation for me | `report_sentence()` |
| Plot several results against their bounds | `plot_equivalence()` |
| How many participants does an equivalence or non-inferiority trial need? | `n_equivalence()`, `n_noninferiority()`, `power_equivalence()` |
| What change in a performance test is worthwhile, and can the test detect it? | `swc()`, `sem_icc()`, `mdc()` |
| What bound should a replication be tested against? | `small_telescope()` |
| What proportion of patients reached the MCID? | `proportion_reaching()` |
| What thresholds have been published for KOOS, IKDC, VISA-P, LEFS, FAAM, ASES, DASH, pain NRS, ODI? | `mcid_reference` |
| Point-and-click version | `run_app()` |

## Example: a "negative" ACL trial that is really informative

The KANON trial reported a 2-year KOOS4 difference of 0.2 points (95% CI -6.5 to 6.8; P = 0.96). Is that "no evidence of a difference" or "evidence of no important difference"?

```r
library(clinthresh)
tost_ci(lower = -6.5, upper = 6.8, sesoi = 8)
#> Equivalence test (TOST)
#>   Estimate: 0.150 (95% CI -6.50 to 6.80), P = 0.96
#>   Bounds: -8.00 to 8.00
#>   90% CI: -5.43 to 5.73; TOST P = 0.01
#>   Pattern: Practically equivalent
```

Against an 8-point threshold, the trial supports equivalence: early reconstruction gave no clinically important advantage in KOOS4.

## Example: planning a trial

```r
n_equivalence(sesoi = 8, sd = 20)          # 108 per group for 80% power
small_telescope(25, type = "paired", sd = 3.26)   # bound for replicating a 25-athlete crossover: 1.04 cm
```

## The five patterns

`classify_ci()` judges zero with the reported (usually 95%) interval and the bounds with the 90% interval, which matches a TOST at alpha = 0.05:

1. **Clinically important**: the whole interval lies beyond a bound.
2. **Real, importance unclear**: excludes zero but crosses a bound.
3. **Real but trivial**: excludes zero and stays inside the bounds.
4. **Practically equivalent**: includes zero and stays inside the bounds.
5. **Inconclusive**: includes zero and crosses a bound.

## Caveats

Results computed from summary statistics are approximations (the standard error is recovered from a rounded confidence interval). Thresholds depend on population, anchor and method; check the source in `mcid_reference` before using one, and justify your threshold before you look at the data. With raw data, the [TOSTER](https://cran.r-project.org/package=TOSTER) package offers a fuller set of equivalence tests.

## Contributing thresholds

The reference table is meant to grow. Open an issue or pull request with the instrument, population, value, method and a citation with DOI. Each row is checked against its source before it is added.

## Citation

If you use the package or the app, please cite both the review and the software:

```r
citation("clinthresh")
```

Papadakis Z. Statistically significant, clinically meaningful, or neither? clinical thresholds, equivalence testing, and replicability in sports medicine rehabilitation. *Curr Phys Med Rehabil Rep*. 2027.

Papadakis Z. clinthresh: clinical thresholds, equivalence tests and replicability tools for sports medicine research. R package version 0.1.0. 2026. https://doi.org/10.5281/zenodo.24022248

## Worked examples

The data, analysis plan, code and output for the worked examples in the review are on the Open Science Framework: https://doi.org/10.17605/OSF.IO/ZQM24

## How this software was made

The R code and the web app were written with the help of an AI assistant (Claude, Anthropic) under the author's direction. The author specified the methods, tested the functions against the worked examples in the review, and is responsible for the software. Please report errors through the issue tracker.

## License

MIT
