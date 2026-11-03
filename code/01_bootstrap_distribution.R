# Blog 08 - Experiment 1
# Comparing bootstrap results with different numbers of resamples

library(ggplot2)

# Set up the values for the simulation
# Use the same sample when comparing the bootstrap results
set.seed(640801)
true_mean <- 5000
true_sd <- 1000
n <- 100
bootstrap_counts <- c(100, 1000, 10000)
max_bootstrap <- max(bootstrap_counts)

# Create folders for the data and graphs
data_dir <- here::here("data")
figures_dir <- here::here("figures")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# Generate the original sample of monthly earnings
original_sample <- rnorm(n, mean = true_mean, sd = true_sd)
original_mean <- mean(original_sample)

original_data <- data.frame(
  observation_id = 1:n,
  monthly_earnings = original_sample
)
write.csv(original_data,
          here::here("data", "exp1_original_sample.csv"),
          row.names = FALSE)

# Bootstrap the sample 10,000 times
# I'll use the first 100 and 1,000 results for comparison later
bootstrap_means <- numeric(max_bootstrap)

for (b in 1:max_bootstrap) {
  bootstrap_sample <- sample(original_sample, size = n, replace = TRUE)
  bootstrap_means[b] <- mean(bootstrap_sample)
}

bootstrap_data <- data.frame(
  bootstrap_id = 1:max_bootstrap,
  bootstrap_mean = bootstrap_means
)
write.csv(bootstrap_data,
          here::here("data", "exp1_bootstrap_means.csv"),
          row.names = FALSE)

# Calculate the 95% confidence intervals for each bootstrap size
summary_data <- data.frame()
comparison_data <- data.frame()

for (j in 1:length(bootstrap_counts)) {
  reps <- bootstrap_counts[j]
  current_means <- bootstrap_means[1:reps]
  ci <- quantile(current_means, probs = c(0.025, 0.975))
  lower <- as.numeric(ci[1])
  upper <- as.numeric(ci[2])
  
  # Store the CI results for this group
  one_summary <- data.frame(
    true_population_mean = true_mean,
    true_population_sd = true_sd,
    sample_size = n,
    bootstrap_repetitions = reps,
    original_sample_mean = original_mean,
    confidence_level = 0.95,
    ci_lower = lower,
    ci_upper = upper,
    ci_width = upper - lower,
    contains_true_mean = (lower <= true_mean & true_mean <= upper)
  )
  summary_data <- rbind(summary_data, one_summary)

  # Keep the bootstrap means for the graphs
  one_comparison <- data.frame(
    bootstrap_repetitions = reps,
    bootstrap_mean = current_means
  )
  comparison_data <- rbind(comparison_data, one_comparison)
}

# Label the three groups for plotting
comparison_data$bootstrap_group <- factor(
  comparison_data$bootstrap_repetitions, levels = bootstrap_counts,
  labels = c("100 resamples", "1,000 resamples", "10,000 resamples")
)
summary_data$bootstrap_group <- factor(
  summary_data$bootstrap_repetitions, levels = bootstrap_counts,
  labels = c("100 resamples", "1,000 resamples", "10,000 resamples")
)

write.csv(summary_data,
          here::here("data", "exp1_summary.csv"),
          row.names = FALSE)
write.csv(comparison_data,
          here::here("data", "exp1_bootstrap_comparison.csv"),
          row.names = FALSE)

# Figure 1: Histogram of the original earnings sample
plot_original <- ggplot(original_data, aes(x = monthly_earnings)) +
  geom_histogram(bins = 18, fill = "#90CAF9", color = "white") +
  geom_vline(xintercept = original_mean, color = "#1565C0", linewidth = 0.9) +
  labs(
    title = "Experiment 1: Original Sample",
    subtitle = paste("One simulated sample of", n, "people"),
    x = "Monthly earnings (dollars)",
    y = "Number of people",
    caption = "Blue line = original sample mean"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp1_original_sample_histogram.png"),
       plot = plot_original, width = 9, height = 5.5, dpi = 300)

# Figure 2: Histogram of all 10,000 bootstrap means
# Get the confidence interval from the last group
last_row <- nrow(summary_data)
final_lower <- summary_data$ci_lower[last_row]
final_upper <- summary_data$ci_upper[last_row]

plot_bootstrap <- ggplot(bootstrap_data, aes(x = bootstrap_mean)) +
  geom_histogram(bins = 35, fill = "#64B5F6", color = "white") +
  geom_vline(xintercept = original_mean, color = "#1565C0", linewidth = 1) +
  geom_vline(xintercept = c(final_lower, final_upper),
             color = "#E65100", linetype = "dashed", linewidth = 0.9) +
  labs(
    title = "Experiment 1: Bootstrap Distribution of the Mean",
    subtitle = "10,000 resamples from the SAME original sample",
    x = "Bootstrap sample mean (dollars)",
    y = "Number of bootstrap resamples",
    caption = "Blue = original mean; orange dashed = 95% percentile bootstrap CI"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp1_bootstrap_distribution.png"),
       plot = plot_bootstrap, width = 9, height = 5.5, dpi = 300)

# Figure 3: Compare the three bootstrap distributions
# Use density so the different sample counts are easier to compare
plot_comparison <- ggplot(comparison_data, aes(x = bootstrap_mean)) +
  geom_histogram(aes(y = after_stat(density)), binwidth = 20,
                 fill = "#64B5F6", color = "white") +
  geom_vline(xintercept = original_mean, color = "#1565C0", linewidth = 0.8) +
  geom_vline(data = summary_data, aes(xintercept = ci_lower),
             color = "#E65100", linetype = "dashed", linewidth = 0.7) +
  geom_vline(data = summary_data, aes(xintercept = ci_upper),
             color = "#E65100", linetype = "dashed", linewidth = 0.7) +
  facet_wrap(~bootstrap_group, ncol = 1) +
  labs(
    title = "Experiment 1: How Does the Bootstrap Distribution Change?",
    subtitle = "Same original sample; increasing numbers of bootstrap resamples",
    x = "Bootstrap sample mean (dollars)",
    y = "Density",
    caption = "Blue = original mean; orange dashed = the CI for each panel"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp1_bootstrap_comparison.png"),
       plot = plot_comparison, width = 9, height = 10, dpi = 300)

# Figure 4: Compare the confidence intervals
# The black dashed line shows the true population mean
plot_ci <- ggplot(summary_data) +
  geom_segment(aes(x = ci_lower, xend = ci_upper,
                   y = bootstrap_group, yend = bootstrap_group),
               color = "#E65100", linewidth = 2) +
  geom_point(aes(x = original_sample_mean, y = bootstrap_group),
             color = "#1565C0", size = 2.5) +
  geom_vline(xintercept = true_mean, color = "#333333",
             linetype = "dashed", linewidth = 0.8) +
  labs(
    title = "Experiment 1: 95% Bootstrap Confidence Intervals",
    subtitle = "Compare 100, 1,000, and 10,000 resamples",
    x = "Monthly earnings (dollars)",
    y = "Number of bootstrap resamples",
    caption = "Orange = CI; blue dot = original mean; dashed black = true mean"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp1_ci_comparison.png"),
       plot = plot_ci, width = 9, height = 5.5, dpi = 300)

