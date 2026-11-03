# Blog 08 - Experiment 3: Hypothesis Testing Through Simulation
# Goal: Explain the null distribution, rejection regions, and p-values.

library(ggplot2)

# 1. Choose the population model and hypothesis test.
# H0: mean monthly earnings = $5,000.
# H1: mean monthly earnings are not $5,000 (two-sided test).
set.seed(640803)
null_mean <- 5000
population_sd <- 1000
n <- 100
null_reps <- 10000
alpha <- 0.05

# 2. Create the output folders inside the RStudio project.
data_dir <- here::here("data")
figures_dir <- here::here("figures")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# 3. Simulate the t-statistic when the null hypothesis is TRUE.
# Each repetition draws a NEW independent sample of 100 people.
# The sample standard deviation is used in the t-statistic.
sample_means <- numeric(null_reps)
sample_sds <- numeric(null_reps)
null_t <- numeric(null_reps)

for (i in 1:null_reps) {
  null_sample <- rnorm(n, mean = null_mean, sd = population_sd)
  sample_means[i] <- mean(null_sample)
  sample_sds[i] <- sd(null_sample)
  null_t[i] <- (sample_means[i] - null_mean) / (sample_sds[i] / sqrt(n))
}

# 4. Use the simulated null distribution to find a rejection region.
# For a two-sided 5% test, the outer 5% of |t| values are extreme.
critical_value <- as.numeric(quantile(abs(null_t), probs = 1 - alpha))

# 5. Generate a separate observed sample for the demonstration.
# Its true mean is $5,200; the test still asks whether the mean is $5,000.
study_true_mean <- 5200
observed_sample <- rnorm(n, mean = study_true_mean, sd = population_sd)
observed_mean <- mean(observed_sample)
observed_sd <- sd(observed_sample)
observed_t <- (observed_mean - null_mean) / (observed_sd / sqrt(n))

observed_data <- data.frame(
  observation_id = 1:n,
  monthly_earnings = observed_sample
)
write.csv(observed_data,
          here::here("data", "exp3_observed_sample.csv"),
          row.names = FALSE)

# 6. Calculate the two-sided simulated p-value.
# Count null statistics at least as extreme as the observed |t|.
# The +1 correction avoids reporting a p-value of exactly zero.
number_as_extreme <- sum(abs(null_t) >= abs(observed_t))
p_value <- (number_as_extreme + 1) / (null_reps + 1)
reject_null <- p_value < alpha

# 7. Save the null simulation and the numerical summary.
null_data <- data.frame(
  simulation_id = 1:null_reps,
  sample_mean = sample_means,
  sample_sd = sample_sds,
  t_statistic = null_t,
  absolute_t = abs(null_t)
)
null_data$rejection_region <- ifelse(
  null_data$absolute_t > critical_value,
  "Rejection region", "Non-rejection region"
)
null_data$p_value_region <- ifelse(
  null_data$absolute_t >= abs(observed_t),
  "At least as extreme", "Less extreme"
)

write.csv(null_data,
          here::here("data", "exp3_null_test_statistics.csv"),
          row.names = FALSE)

summary_data <- data.frame(
  null_hypothesis_mean = null_mean,
  population_sd = population_sd,
  sample_size = n,
  null_simulations = null_reps,
  significance_level = alpha,
  simulated_critical_absolute_t = critical_value,
  study_true_mean = study_true_mean,
  observed_sample_mean = observed_mean,
  observed_sample_sd = observed_sd,
  observed_t_statistic = observed_t,
  number_of_null_statistics_as_extreme = number_as_extreme,
  simulated_two_sided_p_value = p_value,
  reject_null_at_5_percent = reject_null
)
write.csv(summary_data,
          here::here("data", "exp3_summary.csv"),
          row.names = FALSE)

# 8. Figure 1: Simulated null distribution and 5% rejection regions.
plot_null <- ggplot(null_data, aes(x = t_statistic)) +
  geom_histogram(aes(fill = rejection_region), bins = 65,
                 color = "white") +
  geom_vline(xintercept = c(-critical_value, critical_value),
             color = "#D95F02", linetype = "dashed", linewidth = 0.9) +
  geom_vline(xintercept = observed_t, color = "#1565C0",
             linewidth = 1) +
  scale_fill_manual(values = c(
    "Non-rejection region" = "#A9B9CC",
    "Rejection region" = "#D95F02"
  )) +
  labs(
    title = "Experiment 3: Null Distribution and Rejection Regions",
    subtitle = paste(null_reps, "simulations under H0: mean = $5,000"),
    x = "Simulated t-statistic under H0",
    y = "Number of simulations",
    fill = "Region",
    caption = "Orange = 5% rejection tails; dashed = critical values; blue = observed t"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp3_null_distribution.png"),
       plot = plot_null, width = 10, height = 6, dpi = 300)

# 9. Figure 2: Highlight the two tails used to calculate the p-value.
plot_pvalue <- ggplot(null_data, aes(x = t_statistic)) +
  geom_histogram(aes(fill = p_value_region), bins = 65,
                 color = "white") +
  geom_vline(xintercept = c(-abs(observed_t), abs(observed_t)),
             color = "#0D9488", linetype = "dashed", linewidth = 0.9) +
  scale_fill_manual(values = c(
    "Less extreme" = "#A9B9CC",
    "At least as extreme" = "#0D9488"
  )) +
  labs(
    title = "Experiment 3: What Does a Two-Sided p-Value Mean?",
    subtitle = paste("Observed t =", round(observed_t, 2),
                     "| Simulated p-value =", round(p_value, 4)),
    x = "Simulated t-statistic under H0",
    y = "Number of simulations",
    fill = "Compared with observed |t|",
    caption = "Green = null statistics with |t| >= observed |t|"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp3_pvalue_tails.png"),
       plot = plot_pvalue, width = 10, height = 6, dpi = 300)

# 10. Figure 3: Distribution of sample means under H0.
plot_means <- ggplot(null_data, aes(x = sample_mean)) +
  geom_histogram(bins = 45, fill = "#9575CD", color = "white") +
  geom_vline(xintercept = null_mean, color = "#C62828", linewidth = 1) +
  geom_vline(xintercept = observed_mean, color = "#1565C0",
             linetype = "dashed", linewidth = 1) +
  labs(
    title = "Experiment 3: Sample Means Under the Null Hypothesis",
    subtitle = paste(null_reps, "independent samples of", n, "people"),
    x = "Sample mean monthly earnings (dollars)",
    y = "Number of simulations",
    caption = "Red = H0 mean ($5,000); dashed blue = observed study sample mean"
  ) +
  theme_minimal(base_size = 12)

ggsave(here::here("figures", "exp3_null_sample_means.png"),
       plot = plot_means, width = 10, height = 6, dpi = 300)
