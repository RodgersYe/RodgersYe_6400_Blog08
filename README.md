# Bootstrap, Confidence Interval Coverage, and Hypothesis Testing in R

This repository contains **three reproducible R simulation experiments** about bootstrap distributions, 95% confidence interval (CI) coverage, and hypothesis testing. All examples use **synthetic monthly earnings (USD)**; **no real participant data or external datasets are required**.

**Start with the R scripts in [`code/`](code/).** They generate the data in [`data/`](data/) and plots in [`figures/`](figures/). The CSV and PNG files are **outputs**, not inputs.

## 1. Experiments at a glance

| Experiment | What it demonstrates | Simulation design | Run this script |
| --- | --- | --- | --- |
| **1. Bootstrap distribution** | How 100, 1,000, and 10,000 resamples affect a bootstrap distribution and its 95% percentile CI | One sample of 100 values from Normal(mean = $5,000, SD = $1,000); resample **the same sample** | [`01_bootstrap_distribution.R`](code/01_bootstrap_distribution.R) |
| **2. CI coverage** | How often a 95% bootstrap CI contains the true mean across repeated samples | 1,000 independent samples of size 100 from the same population; 100, 1,000, or 10,000 bootstrap resamples per sample | [`02_ci_coverage.R`](code/02_ci_coverage.R) |
| **3. Hypothesis testing** | How a simulated null distribution gives a two-sided rejection region and *p*-value | 10,000 null simulations of size 100 under H₀: μ = $5,000; compare with a separate simulated sample drawn with mean $5,200 | [`03_hypothesis_testing.R`](code/03_hypothesis_testing.R) |

**Key distinction:** Experiments 1–2 bootstrap *with replacement from observed samples*. Experiment 3 simulates *new samples under the null hypothesis*; it is not a bootstrap test.

## 2. Reproduce the experiments

**Requirements:** R, [`ggplot2`](https://ggplot2.tidyverse.org/) (3.4.0 or newer recommended), and [`here`](https://here.r-lib.org/). RStudio is optional.

1. Clone/download the repository, keeping its folder structure. In RStudio, open `RodgersYe_6400_Blog08.Rproj`; otherwise, run commands from the repository root.
2. Install the packages once in R:

   ```r
   install.packages(c("ggplot2", "here"))
   ```

3. Run all experiments. **In RStudio's R console:**

   ```r
   source("code/01_bootstrap_distribution.R")
   source("code/02_ci_coverage.R")
   source("code/03_hypothesis_testing.R")
   ```

   **Or in a terminal** (from the repository root):

   ```bash
   Rscript code/01_bootstrap_distribution.R
   Rscript code/02_ci_coverage.R
   Rscript code/03_hypothesis_testing.R
   ```

4. Check the results: the scripts create or update **10 CSV files** in `data/` and **11 PNG figures** in `figures/`. For the main numerical findings, open [`exp1_summary.csv`](data/exp1_summary.csv), [`exp2_summary.csv`](data/exp2_summary.csv), and [`exp3_summary.csv`](data/exp3_summary.csv).

Each script is **independent**, generates its own synthetic observations, and uses a fixed random seed (`640801`, `640802`, `640803`, respectively). You can run any experiment on its own. Re-running a script **overwrites its corresponding output files**.

> **Computational note:** Experiment 2 is substantially slower than the others: it computes 10 million bootstrap means (1,000 original samples × 10,000 resamples each).

## 3. Repository structure

```text
RodgersYe_6400_Blog08/
├── README.md                       # This guide
├── README_zh.md                    # Chinese-language guide
├── RodgersYe_6400_Blog08.Rproj     # RStudio project file
├── .gitignore                      # Git ignore settings
├── code/                           # The three reproducible R scripts
├── data/                           # Generated CSV datasets and summaries
└── figures/                        # Generated PNG plots (300 dpi)
```

Files such as `.git/`, `.Rproj.user/`, and `.Rhistory` are local Git/RStudio/R metadata and are **not needed to reproduce the experiments**.

## 4. File guide

All file paths below are relative to the repository root. **`exp1_`, `exp2_`, and `exp3_` identify which experiment produced an output.**

### Experiment 1 — Bootstrap distribution

| File | Purpose |
| --- | --- |
| [`code/01_bootstrap_distribution.R`](code/01_bootstrap_distribution.R) | Generates one original sample, 10,000 bootstrap means, three percentile CIs, and the outputs below. |
| [`data/exp1_original_sample.csv`](data/exp1_original_sample.csv) | The 100 simulated original earnings values. |
| [`data/exp1_bootstrap_means.csv`](data/exp1_bootstrap_means.csv) | All 10,000 bootstrap sample means. |
| [`data/exp1_bootstrap_comparison.csv`](data/exp1_bootstrap_comparison.csv) | Bootstrap means grouped for the 100 / 1,000 / 10,000 comparison. |
| [`data/exp1_summary.csv`](data/exp1_summary.csv) | CI endpoints, interval widths, and coverage of the true mean for each resample count. |
| [`figures/exp1_original_sample_histogram.png`](figures/exp1_original_sample_histogram.png) | Distribution of the original 100 observations. |
| [`figures/exp1_bootstrap_distribution.png`](figures/exp1_bootstrap_distribution.png) | Distribution of 10,000 bootstrap means and its 95% CI. |
| [`figures/exp1_bootstrap_comparison.png`](figures/exp1_bootstrap_comparison.png) | Bootstrap distributions for the three resample counts. |
| [`figures/exp1_ci_comparison.png`](figures/exp1_ci_comparison.png) | Comparison of the three CIs with the original and true means. |

### Experiment 2 — Confidence interval coverage

| File | Purpose |
| --- | --- |
| [`code/02_ci_coverage.R`](code/02_ci_coverage.R) | Generates 1,000 independent original samples, constructs bootstrap CIs, and estimates coverage. |
| [`data/exp2_original_samples.csv`](data/exp2_original_samples.csv) | The 100,000 original observations across 1,000 samples. |
| [`data/exp2_coverage_results.csv`](data/exp2_coverage_results.csv) | One CI and coverage result per original sample and resample setting (3,000 rows). |
| [`data/exp2_summary.csv`](data/exp2_summary.csv) | Coverage rates, covered/missed counts, and average CI widths. |
| [`figures/exp2_sample_means_histogram.png`](figures/exp2_sample_means_histogram.png) | Distribution of the 1,000 *original-sample* means (not bootstrap means). |
| [`figures/exp2_confidence_interval_coverage.png`](figures/exp2_confidence_interval_coverage.png) | The first 80 CIs at 10,000 resamples, showing which cover the true mean. |
| [`figures/exp2_coverage_comparison.png`](figures/exp2_coverage_comparison.png) | Estimated coverage versus the nominal 95% level for all three settings. |
| [`figures/exp2_ci_comparison.png`](figures/exp2_ci_comparison.png) | CIs for the same first 40 original samples across all three settings. |

### Experiment 3 — Hypothesis testing

| File | Purpose |
| --- | --- |
| [`code/03_hypothesis_testing.R`](code/03_hypothesis_testing.R) | Generates the null distribution and a separate observed sample; computes the two-sided simulated test. |
| [`data/exp3_observed_sample.csv`](data/exp3_observed_sample.csv) | The 100 values in the separately generated observed sample. |
| [`data/exp3_null_test_statistics.csv`](data/exp3_null_test_statistics.csv) | Results from 10,000 simulations under H₀. |
| [`data/exp3_summary.csv`](data/exp3_summary.csv) | Simulated critical value, observed t-statistic, *p*-value, and reject/do-not-reject decision. |
| [`figures/exp3_null_distribution.png`](figures/exp3_null_distribution.png) | Null t-statistic distribution, 5% rejection tails, and observed t-statistic. |
| [`figures/exp3_pvalue_tails.png`](figures/exp3_pvalue_tails.png) | Two tails at least as extreme as the observed test statistic. |
| [`figures/exp3_null_sample_means.png`](figures/exp3_null_sample_means.png) | Null-sample means compared with the hypothesized and observed means. |

## 5. Notes for interpretation

- Experiments 1–2 use **95% percentile bootstrap CIs**. The 100- and 1,000-resample comparisons use the first draws from the same 10,000-resample sequence, rather than independent bootstrap runs.
- Experiment 2 estimates **long-run CI coverage** from 1,000 independent original samples. Observed coverage is not guaranteed to equal 95% exactly.
- Experiment 3 uses a **one-sample t-statistic**, a two-sided 5% simulated rejection region, and a Monte Carlo *p*-value with the plus-one correction: `(k + 1) / (10000 + 1)`.
- All data are simulated. The included outputs can be regenerated from the scripts, but exact results may differ across R/RNG or package versions; no `renv.lock` is provided.
