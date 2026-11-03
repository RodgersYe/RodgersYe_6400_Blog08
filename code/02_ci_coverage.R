# Blog 08 - Experiment 2: Coverage of 95% bootstrap confidence intervals
# Use the same population as Experiment 1.
# Draw 1,000 samples and run up to 10,000 bootstraps each.

library(ggplot2)

# Set up the experiment using the same population as Experiment 1.
# Draw 1,000 samples, with up to 10,000 bootstrap runs each.
set.seed(640802)
true_mean <- 5000
true_sd <- 1000
n <- 100
num_simulations <- 1000
bootstrap_counts <- c(100, 1000, 10000)
max_bootstrap <- max(bootstrap_counts)

# Set the output folders using here::here().
data_dir <- here::here("data")
figures_dir <- here::here("figures")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# Prepare space for the original data and CI results.
# Each column holds a new independent sample of n people.
all_samples <- matrix(NA_real_, nrow = n, ncol = num_simulations)
sample_means <- numeric(num_simulations)
ci_lower <- matrix(NA_real_, nrow = num_simulations,
                   ncol = length(bootstrap_counts))
ci_upper <- matrix(NA_real_, nrow = num_simulations,
                   ncol = length(bootstrap_counts))
covered <- matrix(FALSE, nrow = num_simulations,
                  ncol = length(bootstrap_counts))

# Draw independent samples and calculate bootstrap CIs.
# For each sample, generate 10,000 bootstrap means.
# Compare CI coverage using 100, 1,000, and 10,000 means.
for (i in 1:num_simulations) {
  new_sample <- rnorm(n, mean = true_mean, sd = true_sd)
  all_samples[, i] <- new_sample
  sample_means[i] <- mean(new_sample)

  bootstrap_draws <- matrix(
    sample(new_sample, size = n * max_bootstrap, replace = TRUE),
    nrow = n
  )
  bootstrap_means <- colMeans(bootstrap_draws)

  for (j in 1:length(bootstrap_counts)) {
    reps <- bootstrap_counts[j]
    ci <- quantile(bootstrap_means[1:reps], probs = c(0.025, 0.975))
    ci_lower[i, j] <- as.numeric(ci[1])
    ci_upper[i, j] <- as.numeric(ci[2])
    covered[i, j] <- (ci_lower[i, j] <= true_mean &
                       true_mean <= ci_upper[i, j])
  }
}

# 5. Save all simulated ORIGINAL observations to a CSV file.
# Each independent sample is saved with its own simulation_id.
simulated_data <- data.frame(
  simulation_id = rep(1:num_simulations, each = n),
  observation_id = rep(1:n, times = num_simulations),
  monthly_earnings = as.vector(all_samples)
)
write.csv(simulated_data,
          here::here("data", "exp2_original_samples.csv"),
          row.names = FALSE)

# 6. Save the CI results and coverage summary for all three sizes.
# This gives 1,000 CIs for EACH bootstrap repetition count.
coverage_data <- data.frame()
summary_data <- data.frame()

for (j in 1:length(bootstrap_counts)) {
  reps <- bootstrap_counts[j]
  one_group <- data.frame(
    simulation_id = 1:num_simulations,
    bootstrap_repetitions_per_sample = reps,
    sample_mean = sample_means,
    ci_lower = ci_lower[, j],
    ci_upper = ci_upper[, j],
    contains_true_mean = covered[, j]
  )
  one_group$coverage_label <- ifelse(
    one_group$contains_true_mean, "Covers true mean", "Misses true mean"
  )
  coverage_data <- rbind(coverage_data, one_group)

  number_covered <- sum(covered[, j])
  one_summary <- data.frame(
    true_population_mean = true_mean,
    true_population_sd = true_sd,
    sample_size = n,
    number_of_simulations = num_simulations,
    bootstrap_repetitions_per_sample = reps,
    confidence_level = 0.95,
    number_covered = number_covered,
    number_missed = num_simulations - number_covered,
    observed_coverage_rate = number_covered / num_simulations,
    average_ci_width = mean(ci_upper[, j] - ci_lower[, j])
  )
  summary_data <- rbind(summary_data, one_summary)
}

coverage_data$bootstrap_label <- factor(
  coverage_data$bootstrap_repetitions_per_sample, levels = bootstrap_counts,
  labels = c("100 resamples", "1,000 resamples", "10,000 resamples")
)
summary_data$bootstrap_label <- factor(
  summary_data$bootstrap_repetitions_per_sample, levels = bootstrap_counts,
  labels = c("100 resamples", "1,000 resamples", "10,000 resamples")
)

write.csv(coverage_data,
          here::here("data", "exp2_coverage_results.csv"),
          row.names = FALSE)
write.csv(summary_data,
          here::here("data", "exp2_summary.csv"),
          row.names = FALSE)

# 7. Figure 1: Sampling distribution of the ORIGINAL sample means.
original_means_data <- data.frame(sample_mean = sample_means)
plot_sample_means <- ggplot(original_means_data, aes(x = sample_mean)) +
  geom_histogram(bins = 35, fill = "#9575CD", color = "white") +
  geom_vline(xintercept = true_mean, color = "#C62828", linewidth = 1) +
  labs(
    title = "Experiment 2: Sampling Distribution of the Mean",
    subtitle = paste("Means from", num_simulations, "independent samples"),
    x = "Sample mean (dollars)",
    y = "Number of independent samples",
    caption = "Red line = true population mean ($5,000)"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp2_sample_means_histogram.png"),
       plot = plot_sample_means, width = 9, height = 5.5, dpi = 300)

# 8. Figure 2: Show the first 80 CIs using 10,000 bootstrap resamples.
plot_count <- 80
plot_data <- coverage_data[
  coverage_data$bootstrap_repetitions_per_sample == max_bootstrap &
    coverage_data$simulation_id <= plot_count, ]

plot_coverage <- ggplot(plot_data) +
  geom_segment(aes(x = ci_lower, xend = ci_upper,
                   y = simulation_id, yend = simulation_id,
                   color = coverage_label), linewidth = 0.85) +
  geom_point(aes(x = sample_mean, y = simulation_id,
                 color = coverage_label), size = 1.4) +
  geom_vline(xintercept = true_mean, color = "#333333",
             linetype = "dashed", linewidth = 0.9) +
  scale_color_manual(values = c("Covers true mean" = "#1B9E77",
                                "Misses true mean" = "#D95F02")) +
  scale_y_reverse() +
  labs(
    title = "Experiment 2: Do 95% Confidence Intervals Cover the Truth?",
    subtitle = paste("First", plot_count, "intervals shown; overall coverage =",
                     round(100 * summary_data$observed_coverage_rate[3], 1), "%"),
    x = "Population mean and confidence interval (dollars)",
    y = "Independent simulation number",
    color = "95% CI result",
    caption = "10,000 resamples per CI; dashed line = true mean ($5,000)"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp2_confidence_interval_coverage.png"),
       plot = plot_coverage, width = 10, height = 10, dpi = 300)

# 9. Figure 3: Compare all three observed coverage rates.
plot_comparison <- ggplot(summary_data,
                          aes(x = bootstrap_label,
                              y = 100 * observed_coverage_rate)) +
  geom_hline(yintercept = 95, linetype = "dashed",
             color = "#C62828", linewidth = 0.9) +
  geom_point(color = "#1565C0", size = 3.5) +
  geom_text(aes(label = paste0(round(100 * observed_coverage_rate, 2), "%")),
            vjust = -0.8, size = 4) +
  coord_cartesian(ylim = c(85, 100)) +
  labs(
    title = "Experiment 2: Coverage Rate by Bootstrap Repetitions",
    subtitle = paste(num_simulations, "independent original samples in each group"),
    x = "Bootstrap resamples per original sample",
    y = "Observed coverage rate (%)",
    caption = "Red dashed line = target coverage (95%)"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp2_coverage_comparison.png"),
       plot = plot_comparison, width = 9, height = 5.5, dpi = 300)

# 10. Figure 4: Compare the first 40 CIs across the three settings.
comparison_count <- 40
plot_ci_data <- coverage_data[coverage_data$simulation_id <= comparison_count, ]

plot_ci_comparison <- ggplot(plot_ci_data) +
  geom_segment(aes(x = ci_lower, xend = ci_upper,
                   y = simulation_id, yend = simulation_id,
                   color = coverage_label), linewidth = 0.8) +
  geom_point(aes(x = sample_mean, y = simulation_id),
             color = "#1565C0", size = 1.1) +
  geom_vline(xintercept = true_mean, color = "#333333",
             linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = c("Covers true mean" = "#1B9E77",
                                "Misses true mean" = "#D95F02")) +
  scale_y_reverse() +
  facet_wrap(~bootstrap_label, nrow = 1) +
  labs(
    title = "Experiment 2: Confidence Intervals Across Bootstrap Settings",
    subtitle = "Same first 40 original samples in every panel",
    x = "95% CI for population mean (dollars)",
    y = "Independent simulation number",
    color = "CI result",
    caption = "Dashed line = true mean; blue dot = sample mean"
  ) +
  theme_minimal(base_size = 11)

ggsave(here::here("figures", "exp2_ci_comparison.png"),
       plot = plot_ci_comparison, width = 14, height = 7.5, dpi = 300)
