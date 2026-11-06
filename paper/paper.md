---
title: 'clinthresh: clinical thresholds and equivalence tests for sports medicine research'
tags:
  - R
  - equivalence testing
  - minimal clinically important difference
  - sports medicine
  - rehabilitation
authors:
  - name: Zacharias Papadakis
    orcid: 0000-0001-8437-8067
    affiliation: 1
affiliations:
  - name: Human Performance Laboratory, Department of Health Sciences and Clinical Practice, Barry University, Miami Shores, Florida, United States
    index: 1
date: 5 November 2026
bibliography: paper.bib
---

# Summary

`clinthresh` is an R package and web application for reading and designing sports medicine and rehabilitation studies against a threshold of clinical importance rather than against zero. From the estimate and confidence interval printed in an abstract, it runs an equivalence test with the two one-sided tests (TOST) procedure [@schuirmann1987; @lakens2017], places the interval into one of five patterns (clinically important, real but of unclear importance, real but trivial, practically equivalent, or inconclusive), and writes a sentence that can be pasted into a manuscript. It also computes the smallest worthwhile change, the standard error of measurement and the minimal detectable change [@hopkins2000; @devet2006], the small-telescopes bound for replication studies [@simonsohn2015], sample sizes for equivalence and non-inferiority trials, and the proportion of patients who reach an individual threshold. A reference table lists published thresholds for outcomes common in sports medicine, each with its source.

# Statement of need

Trials in sports medicine are small, and many conclude that two treatments are "equally effective" because a test against zero was not significant [@altman1995; @murphy2025]. Equivalence and non-inferiority tests answer the question these authors are asking, but they are rarely used, partly because existing software expects raw data or group summaries and partly because the threshold of clinical importance is seldom stated. `clinthresh` fills that gap for clinicians, students, editors and reviewers who have only a published interval, and for investigators who need to plan a trial around the smallest effect that matters. The web application lets readers without R do the same calculations. The package complements TOSTER [@lakens2018], which is the better choice when raw data are available.

# Acknowledgements

The author thanks the sports and exercise science replication community, whose work motivated this package.

# References
