# clinthresh 0.2.2

Companion software for the review "Statistically Significant, Clinically Meaningful, or Neither? Clinical Thresholds and Equivalence Testing in Sports Medicine Rehabilitation" (Current Physical Medicine and Rehabilitation Reports).

* Reading mode (`read_ci()`, web app default): for a published result, reports the range of thresholds for which each conclusion holds, with no test against a threshold chosen after the result was seen.
* Planning mode (`tost_ci()`, `tost_se()`, `tost_means()`, `tost_prop()`): equivalence, minimum-effect and non-inferiority tests against a threshold fixed in advance; one error rate, alpha = 0.025 per one-sided test, matching the reported 95% CI.
* `classify_ci()` places an interval in one of five patterns; `report_sentence()` writes the interpretation; `plot_equivalence()` plots several results against their bounds.
* Sample sizes for equivalence and non-inferiority trials (`n_equivalence()`, `n_noninferiority()`, `power_equivalence()`); SWC, SEM and MDC for performance tests (`swc()`, `sem_icc()`, `mdc()`); small-telescopes bounds (`small_telescope()`); proportion reaching a threshold (`proportion_reaching()`).
* `mcid_reference`: published thresholds with sources and DOIs, each labeled within-patient, between-group or either.
* Web app (https://zpapadakis.github.io/clinthresh/): works from a reported CI, group means and SDs, a paired difference, event counts (risk difference and risk ratio) or pasted raw data; plots are labeled with the effect measure and units; the worked examples of the review load with one click. `run_app()` opens a Shiny version from R.
