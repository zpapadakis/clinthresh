# clinthresh 0.1.8

* **One error rate.** `tost_ci()`, `tost_se()`, `tost_means()`, `tost_prop()`, `power_equivalence()` and `n_equivalence()` now default to alpha = 0.025 per one-sided test, matching `n_noninferiority()` and the CONSORT convention for equivalence and non-inferiority trials. Every judgment (zero, importance, equivalence, non-inferiority) then uses the 95% interval a paper prints, a result equivalent within a bound is always non-inferior at a margin of the same size, and the five patterns cannot overlap. Use `alpha = 0.05` for bioequivalence or TOSTER defaults.
* `tost_ci()`: when the equivalence level equals the reported level, the reported limits are used as the equivalence interval, so the conclusion can be read straight off the printed interval even when the reported estimate is not its midpoint.
* Web app: each published threshold is labeled within-patient or between-group, and a within-patient threshold applied to a between-group difference triggers a caution.
* Web app: alpha defaults to 0.025 per side; worked examples and notes match Table 2 of the review (vs21). Shiny app updated to match.

# clinthresh 0.1.7

* Web app: worked examples now match the seven rows of Table 2 in the review (hip arthroscopy meta-analysis, insertional Achilles tendinopathy, PRP and hamstring pain, KANON, UKSTAR function and re-rupture, PRP versus no injection, PRP and return to sport) plus the kidney disease example; examples load the reported point estimate.
* Web app: clinical importance and the "clears any threshold up to" value now use the 95% CI (one-sided alpha = 0.025), as in the review; equivalence still uses the 90% CI. Results that are real but of unclear importance also report the one-sided minimum-effect P and the largest threshold the 95% CI clears.
* Web app: the non-inferiority tab loads the UKSTAR point estimate (-1.38).
* Tests: new `test-review-table2.R` checks every row of Table 2.

# clinthresh 0.1.6

* Web app: event-count comparisons now use Newcombe hybrid score intervals (P values still from the Wald z statistic), matching the re-rupture analysis in the review.
* Web app: the kidney disease example uses an illustrative bound of a 50% difference in RMSSD (ln 1.5) and notes that the result is inconclusive for any bound below 0.47 ln units.

# clinthresh 0.1.5

* Web app: the kidney disease worked example now uses a bound of half the typical error between the two baseline days (0.30 ln units), as in the revised review; the result stays inconclusive (equivalent only for bounds of at least 0.47).

# clinthresh 0.1.4

* Web app: worked examples now match the review (KANON, knee replacement, insertional Achilles tendinopathy, hyaluronic acid, UKSTAR, CKD); a clinically important result now reports a one-sided minimum-effect test and the largest threshold it clears.
* `tost_ci()` and `tost_se()` also return one-sided minimum-effect P values (`p_min_effect_above`, `p_min_effect_below`).

# clinthresh 0.1.3

* Web app: one-click worked examples from the review (KANON, de Vos et al., RESTORE, Rutjes et al., UKSTAR ATRS and re-rupture, caffeine crossover, CKD heart rate variability).
* Web app: a ready-to-paste methods sentence for every result, and a "please cite" panel with a copy button.

# clinthresh 0.1.2

* New `tost_means()` (two groups, Welch or pooled; or paired from the mean and SD of the differences) and `tost_prop()` (risk difference in percentage points, Wald).
* Web app: the Interpret tab now accepts a difference and CI, group means and SDs, a paired mean difference, event counts, or pasted raw data, and reports the one-sided P values and the method used.
* Checked against TOSTER 0.8.6 (`tsum_TOST()`, `t_TOST()`, `twoprop_test()`).

# clinthresh 0.1.1

* States in the README, web app and paper draft that the software was developed with the help of an AI assistant.
* Adds the Zenodo and OSF DOIs and the web app link.
* Documents agreement with the TOSTER package for the published examples in the review.

# clinthresh 0.1.0

* First release, accompanying the invited review in Current Physical Medicine and Rehabilitation Reports.
* Equivalence tests from published confidence intervals (`tost_ci()`, `tost_se()`), interval classification (`classify_ci()`), report sentences, plots.
* SWC, SEM, MDC, small-telescopes bound, equivalence and non-inferiority sample sizes, proportion reaching an individual threshold.
* Reference table of 17 sourced thresholds (`mcid_reference`) and a Shiny app (`run_app()`).
