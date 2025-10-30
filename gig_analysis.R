# Gig Economy Impact Analysis - Minimal Working Example
# For Revelio Labs Application

source("requirements.R")

# Set seed for reproducibility
set.seed(123)

# 1. CREATE SYNTHETIC DATA ----------------------------------------------------
cat("Creating synthetic employment data...\n")

# Generate realistic worker data
n_workers <- 2000  # Smaller sample for demo
workers <- tibble(
  worker_id = 1:n_workers,
  age = sample(25:55, n_workers, replace = TRUE),
  education = sample(c("High School", "College", "Graduate"), n_workers, 
                     replace = TRUE, prob = c(0.4, 0.4, 0.2)),
  region = sample(c("Northeast", "South", "Midwest", "West"), n_workers, replace = TRUE)
)

# Generate 8 quarters of data (2 years)
periods <- 8
employment_data <- expand_grid(
  worker_id = 1:n_workers,
  quarter = 1:periods
) %>%
  left_join(workers, by = "worker_id") %>%
  mutate(
    # Simulate gig work probability (increasing over time)
    gig_prob = 0.1 + 0.05 * quarter + 0.1 * (education == "High School"),
    is_gig_worker = runif(n()) < gig_prob,
    
    # Generate income with gig work penalty and higher volatility
    base_income = case_when(
      education == "High School" ~ 12000,
      education == "College" ~ 15000, 
      education == "Graduate" ~ 18000
    ),
    
    # Gig workers earn less with more volatility
    quarterly_income = ifelse(
      is_gig_worker,
      base_income * 0.8 + rnorm(n(), 0, 2000),  # Lower, more volatile
      base_income + rnorm(n(), 0, 1000)         # Higher, more stable
    ),
    
    # Add time trend
    quarterly_income = quarterly_income * (1 + 0.01 * quarter),
    
    date = ymd("2022-01-01") + months(3 * (quarter - 1))
  )

cat("Created data for", n_workers, "workers over", periods, "quarters\n")

# 2. BASIC ANALYSIS -----------------------------------------------------------
cat("\n=== BASIC ANALYSIS ===\n")

# Gig work prevalence
gig_summary <- employment_data %>%
  group_by(quarter) %>%
  summarise(
    gig_rate = mean(is_gig_worker),
    avg_income = mean(quarterly_income),
    income_sd = sd(quarterly_income)
  )

print(gig_summary)

# Income comparison
income_comparison <- employment_data %>%
  group_by(is_gig_worker) %>%
  summarise(
    mean_income = mean(quarterly_income),
    income_volatility = sd(quarterly_income),
    n_observations = n()
  )

cat("\nIncome Comparison:\n")
print(income_comparison)

# 3. ECONOMETRIC ANALYSIS ----------------------------------------------------
cat("\n=== ECONOMETRIC ANALYSIS ===\n")

# Simple fixed effects model
model <- feols(quarterly_income ~ is_gig_worker + factor(quarter) | worker_id, 
               data = employment_data)

cat("Fixed Effects Model Results:\n")
print(summary(model))

# 4. VISUALIZATIONS ----------------------------------------------------------
cat("\nCreating visualizations...\n")

# Plot 1: Gig work growth
p1 <- ggplot(gig_summary, aes(x = quarter, y = gig_rate)) +
  geom_line(color = "steelblue", size = 1.5) +
  geom_point(color = "steelblue", size = 2) +
  labs(
    title = "Growth of Gig Economy Participation",
    subtitle = "Percentage of workers in gig arrangements",
    x = "Quarter",
    y = "Gig Work Rate"
  ) +
  theme_minimal()

ggsave("gig_growth.png", p1, width = 8, height = 5)

# Plot 2: Income distribution
p2 <- employment_data %>%
  sample_n(1000) %>%  # Sample for clarity
  ggplot(aes(x = is_gig_worker, y = quarterly_income, fill = is_gig_worker)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("FALSE" = "darkgreen", "TRUE" = "darkred")) +
  labs(
    title = "Income Distribution: Gig vs Traditional Workers",
    subtitle = "Gig workers show lower median income and higher variance",
    x = "Gig Worker",
    y = "Quarterly Income"
  ) +
  theme_minimal()

ggsave("income_comparison.png", p2, width = 8, height = 5)

# Plot 3: Interactive trend
p3 <- plot_ly(gig_summary, x = ~quarter, y = ~gig_rate * 100, 
              type = 'scatter', mode = 'lines+markers',
              line = list(color = 'blue', width = 4),
              marker = list(size = 8)) %>%
  layout(title = 'Gig Economy Growth (2022-2023)',
         xaxis = list(title = 'Quarter'),
         yaxis = list(title = 'Gig Workers (%)'))

htmlwidgets::saveWidget(p3, "gig_trend_interactive.html")

cat("Analysis complete! Check the generated PNG files and HTML.\n")