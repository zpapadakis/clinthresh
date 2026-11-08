# clinthresh

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24022248.svg)](https://doi.org/10.5281/zenodo.24022248) [![Web app](https://img.shields.io/badge/web%20app-open-1f6f8b)](https://zpapadakis.github.io/clinthresh/)

**Clinical thresholds, equivalence tests and replicability tools for sports medicine research**

A non-significant P value does not show that two treatments are equivalent, and a significant one does not show that an effect matters. `clinthresh` helps clinicians, authors and reviewers read a result against a threshold of clinical importance instead of against zero. It works from the numbers printed in an abstract, so you do not need the raw data.

It accompanies the invited review *Statistically Significant, Clinically Meaningful, or Neither? Clinical Thresholds, Equivalence Testing, and Replicability in Sports Medicine Rehabilitation* (Current Physical Medicine and Rehabilitation Reports, 2027).

## No R? Use the web app

**[Open the free web app](https://zpapadakis.github.io/clinthresh/)** to interpret a published result (from the reported CI, group means and SDs, a paired difference, event counts, or your own pasted data), test non-inferiority, plan a trial, compute SWC and MDC, or browse the threshold table. It runs entirely in your browser; nothing you type is sent anywhere. Each result comes with a sentence for your results and one for your methods, and the worked examples from the review load with one click. (`run_app()` opens the same tools as a Shiny app from R.)

## Install

```r
# install.packages("remotes")
remotes::install_github("zpapadakis/clinthresh")
```

## What it does

| Question | Function |
|---|---|
| I am reading a published trial: for which thresholds does each conclusion hold? (no test against a post hoc threshold) | `read_ci()`, `classify_ci()` |
| I fixed a threshold in my protocol: test equivalence, importance or non-inferiority | `tost_ci()` |
| I have an estimate and a standard error | `tost_se()` |
| I have group means and SDs (or a paired difference) | `tost_means()` |
| I have event counts in two groups | `tost_prop()` |
| Write the interpretation for me | `report_sentence()` |
| Plot several results against their bounds | `plot_equivalence()` |
| How many participants does an equivalence or non-inferiority trial need? | `n_equivalence()`, `n_noninferiority()`, `power_equivalence()` |
| What change in a performance test is worthwhile, and can the test detect it? | `swc()`, `sem_icc()`, `mdc()` |
| What bound should a replication be tested against? | `small_telescope()` |
| What proportion of patients reached the MCID? | `proportion_reaching()` |
| What thresholds have been published for KOOS, IKDC, VISA-P, LEFS, FAAM, ASES, DASH, pain NRS, ODI? | `mcid_reference` |
| Point-and-click version | `run_app()` |

## Reading a published trial versus planning one

Tests against a threshold keep their error rate only when the threshold was fixed before the data were seen, as in a protocol. A clinician reading a finished trial sees the result first, so `read_ci()` gives no P value against a threshold. It reports the range of thresholds for which each conclusion holds and, if you supply a threshold published independently of the trial, the pattern of the interval against it. The web app does the same in its default reading mode; planning mode runs the tests.

## Example: a "negative" ACL trial that is really informative

The KANON trial reported a 2-year KOOS4 difference of -0.2 points (early minus optional reconstruction; 95% CI -6.8 to 6.5; P = 0.96). Is that "no evidence of a difference" or "evidence of no important difference"?

```r
library(clinthresh)
read_ci(lower = -6.8, upper = 6.5, estimate = -0.2, threshold = 8)
#> Reading a published result (no test against a post hoc threshold)
#>   Estimate -0.20 (95% CI -6.80 to 6.50)
#>   Equivalence holds for symmetric bounds >= 6.80
#>   Importance holds for thresholds <= none (interval includes zero)
#>   Non-inferiority holds for margins >= 6.80
#>   Against a threshold of 8.00: Practically equivalent
```

The two strategies are practically equivalent for any bound of 6.8 KOOS4 points or more, which includes the 8 to 10 points the KOOS developers proposed for each subscale. A reader who considers a 5-point difference important should read the trial as inconclusive.

## Example: planning a trial

```r
tost_ci(lower = -6.8, upper = 6.5, sesoi = 8, estimate = -0.2)  # only for a bound fixed in advance
n_equivalence(sesoi = 8, sd = 20)          # 133 per group for 80% power (alpha = 0.025 per side)
small_telescope(25, type = "paired", sd = 3.26)   # bound for replicating a 25-athlete crossover: 1.04 cm
```

## The five patterns

Since version 0.1.8 every test defaults to alpha = 0.025 per one-sided test, so zero, clinical importance, equivalence and non-inferiority are all judged with the 95% interval a paper prints (the CONSORT convention for equivalence and non-inferiority trials). With one error rate, a result that is equivalent within a bound is always non-inferior at a margin of the same size, and the five patterns cannot overlap. Set `alpha = 0.05` to reproduce bioequivalence or TOSTER defaults (90% interval). `classify_ci()` places an interval in one of five patterns:

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

Papadakis Z. clinthresh: clinical thresholds, equivalence tests and replicability tools for sports medicine research. R package version 0.1.9. 2026. https://doi.org/10.5281/zenodo.24022248

## Worked examples

The data, analysis plan, code and output for the worked examples in the review are on the Open Science Framework: https://doi.org/10.17605/OSF.IO/ZQM24

## How this software was made

The author developed the R package and the web app with the help of an AI assistant (Claude, Anthropic). The author specified the methods, tested the functions against the worked examples in the review and checked the equivalence tests against the TOSTER package (version 0.8.6), which gives the same P values to four significant figures, and is responsible for the software. Please report errors through the issue tracker.

## License

MIT
