# ============================================================================
# DATABRICKS R SCRIPT: SPORTS VIEWING DATA & CHART GENERATOR
# ============================================================================
# Purpose: Generate sports viewing data and create ggplot visualizations
# Output: Spark temp views + PNG chart files in /dbfs/FileStore/charts/
# ============================================================================

library(SparkR)
library(dplyr)
library(ggplot2)

cat("============================================================================\n")
cat("SPORTS VIEWING ANALYTICS - R DATA & CHART GENERATOR\n")
cat("============================================================================\n\n")

# ============================================================================
# SECTION 1: CREATE SUMMARY DATA
# ============================================================================
cat("1. Creating Summary Data...\n")

summary_df <- data.frame(
  TotalViewingMinutes = 125840000,
  UniqueViewers = 8450000,
  AvgMinutesPerViewer = 14.9,
  TotalAssets = 1250
)

# Register as Spark temp view for Python access
createOrReplaceTempView(createDataFrame(summary_df), "summary_data")

cat("   ✓ Summary data created\n")
print(summary_df)
cat("\n")

# ============================================================================
# SECTION 2: CREATE MONTHLY COMPETITION DATA
# ============================================================================
cat("2. Creating Monthly Competition Data...\n")

# Define competitions and months
competitions <- c('LaLiga', 'Premier League', 'UCL', 'AFC Qualifiers', 
                 'Formula 1', 'FIFA Arab Cup', 'Serie A', 'Bundesliga',
                 'Ligue 1', 'Europa League', 'FA Cup', 'Copa del Rey')

months <- c('2025-January', '2025-February', '2025-March', '2025-April', 
           '2025-May', '2025-June', '2025-July', '2025-August',
           '2025-September', '2025-October', '2025-November', '2025-December')

# Create monthly data frame
set.seed(42)  # For reproducibility
monthly_df <- data.frame(
  YearMonth = rep(months, each = length(competitions)),
  Competition = rep(competitions, times = length(months)),
  ViewingMinutes = sample(500000:2000000, length(months) * length(competitions), replace = TRUE),
  UniqueViewers = sample(300000:1500000, length(months) * length(competitions), replace = TRUE),
  MinutesPerViewer = runif(length(months) * length(competitions), min = 12, max = 25)
)

# Add seasonal boost for football competitions in Q4
monthly_df$ViewingMinutes <- ifelse(
  monthly_df$Competition %in% c('LaLiga', 'Premier League', 'UCL', 'Serie A', 'Bundesliga', 'Ligue 1') &
  monthly_df$YearMonth %in% c('2025-September', '2025-October', '2025-November', '2025-December'),
  monthly_df$ViewingMinutes * 1.3,
  monthly_df$ViewingMinutes
)

monthly_df$UniqueViewers <- ifelse(
  monthly_df$Competition %in% c('LaLiga', 'Premier League', 'UCL', 'Serie A', 'Bundesliga', 'Ligue 1') &
  monthly_df$YearMonth %in% c('2025-September', '2025-October', '2025-November', '2025-December'),
  monthly_df$UniqueViewers * 1.25,
  monthly_df$UniqueViewers
)

# Recalculate MinutesPerViewer
monthly_df$MinutesPerViewer <- monthly_df$ViewingMinutes / monthly_df$UniqueViewers

# Register as temp view
createOrReplaceTempView(createDataFrame(monthly_df), "monthly_data")

cat("   ✓ Monthly competition data created (", nrow(monthly_df), " rows)\n")
cat("   Sample data:\n")
print(head(monthly_df, 10))
cat("\n")

# ============================================================================
# SECTION 3: CREATE SPORTS DATA
# ============================================================================
cat("3. Creating Sports Data...\n")

sports_df <- data.frame(
  Sport = c('Football', 'Motorsports', 'Basketball', 'Tennis', 'Rugby'),
  ViewingMinutes = c(45000000, 12000000, 8500000, 6200000, 4100000),
  UniqueViewers = c(3200000, 850000, 620000, 480000, 310000),
  MinutesPerViewer = c(14.1, 14.1, 13.7, 12.9, 13.2)
)

createOrReplaceTempView(createDataFrame(sports_df), "sports_data")

cat("   ✓ Sports data created\n")
print(sports_df)
cat("\n")

# ============================================================================
# SECTION 4: CREATE DEVICE DATA
# ============================================================================
cat("4. Creating Device Data...\n")

device_df <- data.frame(
  Device = c('TV', 'Mobile', 'Tablet', 'Desktop'),
  ViewingMinutes = c(52000000, 38000000, 18000000, 17840000),
  UniqueViewers = c(2800000, 3200000, 1450000, 1000000),
  MinutesPerViewer = c(18.6, 11.9, 12.4, 17.8)
)

createOrReplaceTempView(createDataFrame(device_df), "device_data")

cat("   ✓ Device data created\n")
print(device_df)
cat("\n")

# ============================================================================
# SECTION 5: CREATE CHARTS DIRECTORY
# ============================================================================
cat("5. Setting up charts directory...\n")

# Create directory for saving charts
system("mkdir -p /dbfs/FileStore/charts", intern = TRUE, ignore.stderr = TRUE)

cat("   ✓ Charts directory ready: /dbfs/FileStore/charts/\n\n")

# ============================================================================
# SECTION 6: CREATE GGPLOT CHARTS
# ============================================================================
cat("6. Creating ggplot visualizations...\n\n")

# Define color palette
chart_colors <- c('#028090', '#00A896', '#02C39A', '#F0B67F', '#FE5F55', '#5C6B73')

# ----------------------------------------------------------------------------
# CHART 1: SPORTS PIE CHART
# ----------------------------------------------------------------------------
cat("   a) Creating Sports Distribution Pie Chart...\n")

sports_pie <- ggplot(sports_df, aes(x = "", y = UniqueViewers, fill = Sport)) +
  geom_bar(stat = "identity", width = 1, color = "white", size = 1.2) +
  coord_polar("y", start = 0) +
  geom_text(aes(label = paste0(Sport, "\n", 
                                round(UniqueViewers/sum(UniqueViewers)*100, 1), "%")),
            position = position_stack(vjust = 0.5), 
            size = 5, fontface = "bold", color = "white") +
  scale_fill_manual(values = chart_colors[1:5]) +
  theme_void() +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 12),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 20)),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  labs(title = "Viewership Distribution by Sport")

ggsave("/dbfs/FileStore/charts/sports_pie.png", sports_pie, 
       width = 10, height = 6, dpi = 150, bg = "white")

cat("      ✓ Saved: sports_pie.png\n")

# ----------------------------------------------------------------------------
# CHART 2: DEVICE LOLLIPOP CHART
# ----------------------------------------------------------------------------
cat("   b) Creating Device Viewership Lollipop Chart...\n")

device_sorted <- device_df %>% arrange(UniqueViewers)

device_lollipop <- ggplot(device_sorted, aes(x = reorder(Device, UniqueViewers), 
                                              y = UniqueViewers)) +
  geom_segment(aes(x = Device, xend = Device, y = 0, yend = UniqueViewers),
               color = "#028090", size = 5, alpha = 0.4) +
  geom_point(color = "#00A896", size = 12, alpha = 0.8) +
  geom_text(aes(label = format(UniqueViewers, big.mark = ",")), 
            hjust = -0.3, size = 5, fontface = "bold", color = "#1F2937") +
  coord_flip() +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_blank(),
    axis.text.y = element_text(size = 13, face = "bold"),
    axis.text.x = element_text(size = 11),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 20)),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E5E7EB", size = 0.5),
    plot.margin = margin(20, 40, 20, 20)
  ) +
  labs(
    title = "Unique Viewers by Device", 
    x = "Unique Viewers"
  ) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15)))

ggsave("/dbfs/FileStore/charts/device_lollipop.png", device_lollipop, 
       width = 10, height = 8, dpi = 150, bg = "white")

cat("      ✓ Saved: device_lollipop.png\n")

# ----------------------------------------------------------------------------
# CHART 3: TOP COMPETITIONS BAR CHART
# ----------------------------------------------------------------------------
cat("   c) Creating Top Competitions Bar Chart...\n")

top_comps <- monthly_df %>%
  group_by(Competition) %>%
  summarise(TotalViewers = sum(UniqueViewers)) %>%
  arrange(desc(TotalViewers)) %>%
  head(8)

comp_bar <- ggplot(top_comps, aes(x = reorder(Competition, TotalViewers), 
                                   y = TotalViewers)) +
  geom_bar(stat = "identity", fill = "#028090", color = "white", size = 1) +
  geom_text(aes(label = format(TotalViewers, big.mark = ",")), 
            hjust = -0.1, size = 4.5, fontface = "bold", color = "#1F2937") +
  coord_flip() +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_blank(),
    axis.text.y = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(size = 11),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 20)),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E5E7EB", size = 0.5),
    plot.margin = margin(20, 40, 20, 20)
  ) +
  labs(
    title = "Top 8 Competitions by Total Viewership", 
    x = "Total Unique Viewers"
  ) +
  scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.15)))

ggsave("/dbfs/FileStore/charts/competition_bar.png", comp_bar, 
       width = 10, height = 6, dpi = 150, bg = "white")

cat("      ✓ Saved: competition_bar.png\n")

# ----------------------------------------------------------------------------
# CHART 4: COMPETITION LINE CHART (TOP 6)
# ----------------------------------------------------------------------------
cat("   d) Creating Competition Trends Line Chart...\n")

top_6_comps <- monthly_df %>%
  group_by(Competition) %>%
  summarise(TotalViewers = sum(UniqueViewers)) %>%
  arrange(desc(TotalViewers)) %>%
  head(6) %>%
  pull(Competition)

monthly_top6 <- monthly_df %>% 
  filter(Competition %in% top_6_comps) %>%
  mutate(MonthNum = match(YearMonth, months))

comp_line <- ggplot(monthly_top6, aes(x = MonthNum, y = UniqueViewers, 
                                       color = Competition, group = Competition)) +
  geom_line(size = 2.5) +
  geom_point(size = 6) +
  scale_color_manual(values = chart_colors) +
  scale_x_continuous(
    breaks = 1:12, 
    labels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 11),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 20)),
    legend.position = "right",
    legend.title = element_text(size = 13, face = "bold"),
    legend.text = element_text(size = 11),
    legend.background = element_rect(fill = "white", color = "#E5E7EB"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E7EB", size = 0.5),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  labs(
    title = "Competition Viewership Trends Over Time", 
    x = "Month", 
    y = "Unique Viewers"
  ) +
  scale_y_continuous(labels = scales::comma)

ggsave("/dbfs/FileStore/charts/competition_line.png", comp_line, 
       width = 12, height = 6, dpi = 150, bg = "white")

cat("      ✓ Saved: competition_line.png\n")

# ----------------------------------------------------------------------------
# CHART 5: SPORTS STACKED BAR (OPTIONAL ADDITIONAL CHART)
# ----------------------------------------------------------------------------
cat("   e) Creating Sports Comparison Chart...\n")

sports_comparison <- sports_df %>%
  select(Sport, ViewingMinutes, UniqueViewers) %>%
  tidyr::pivot_longer(cols = c(ViewingMinutes, UniqueViewers), 
                      names_to = "Metric", 
                      values_to = "Value")

sports_comparison$Metric <- factor(
  sports_comparison$Metric,
  levels = c("ViewingMinutes", "UniqueViewers"),
  labels = c("Viewing Minutes", "Unique Viewers")
)

# Normalize for comparison
sports_comparison <- sports_comparison %>%
  group_by(Metric) %>%
  mutate(NormalizedValue = Value / max(Value) * 100)

sports_comp_chart <- ggplot(sports_comparison, 
                            aes(x = reorder(Sport, NormalizedValue), 
                                y = NormalizedValue, 
                                fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  scale_fill_manual(values = c("#028090", "#00A896")) +
  coord_flip() +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_blank(),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 20)),
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(size = 12, face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  labs(
    title = "Sports Performance Comparison (Normalized)",
    x = "Relative Performance (%)"
  )

ggsave("/dbfs/FileStore/charts/sports_comparison.png", sports_comp_chart, 
       width = 10, height = 6, dpi = 150, bg = "white")

cat("      ✓ Saved: sports_comparison.png\n")

# ============================================================================
# SECTION 7: SUMMARY
# ============================================================================
cat("\n============================================================================\n")
cat("R SCRIPT EXECUTION COMPLETE!\n")
cat("============================================================================\n\n")

cat("✅ Data Created:\n")
cat("   - summary_data (Spark temp view)\n")
cat("   - monthly_data (Spark temp view) - ", nrow(monthly_df), " rows\n")
cat("   - sports_data (Spark temp view) - ", nrow(sports_df), " rows\n")
cat("   - device_data (Spark temp view) - ", nrow(device_df), " rows\n\n")

cat("✅ Charts Created:\n")
cat("   - sports_pie.png\n")
cat("   - device_lollipop.png\n")
cat("   - competition_bar.png\n")
cat("   - competition_line.png\n")
cat("   - sports_comparison.png\n\n")

cat("📂 Charts Location: /dbfs/FileStore/charts/\n\n")

cat("▶️  Next Step: Run the Python script to create the PowerPoint presentation\n")
cat("============================================================================\n")
