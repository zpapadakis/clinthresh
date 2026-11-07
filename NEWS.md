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
