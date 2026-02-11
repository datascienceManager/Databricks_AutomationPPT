Great question! Adding GT or flextable tables from R to Python for PowerPoint is tricky because these packages create complex formatted tables. Here's the **best solution**:

## 🎯 **Solution: Export R Tables as Images**

Since GT and flextable create beautifully formatted tables, the best approach is to save them as PNG images in R, then insert them into PowerPoint via Python (just like we do with ggplot2 charts).

---

## 📊 **Method 1: Using GT Tables**

### R Script - Create and Save GT Table

Add this to your **`databricks_r_data_generator.R`**:

```r
# ============================================================================
# SECTION 6.5: CREATE GT TABLES
# ============================================================================
cat("   f) Creating GT tables...\n")

library(gt)
library(webshot2)  # Required for saving gt tables as images

# Example 1: Sports Performance Table
sports_gt_table <- sports_df %>%
  gt() %>%
  tab_header(
    title = "Sports Performance Summary",
    subtitle = "2025 Full Year Analysis"
  ) %>%
  cols_label(
    Sport = "Sport Category",
    ViewingMinutes = "Total Minutes",
    UniqueViewers = "Unique Viewers",
    MinutesPerViewer = "Avg Min/Viewer"
  ) %>%
  fmt_number(
    columns = c(ViewingMinutes, UniqueViewers),
    decimals = 0,
    use_seps = TRUE
  ) %>%
  fmt_number(
    columns = MinutesPerViewer,
    decimals = 1
  ) %>%
  data_color(
    columns = UniqueViewers,
    palette = c("#E8F4F5", "#028090")
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#028090"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels()
  ) %>%
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_body()
  ) %>%
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(18),
    heading.subtitle.font.size = px(14),
    table.width = pct(100)
  )

# Save as PNG
gtsave(sports_gt_table, 
       filename = "/dbfs/FileStore/charts/sports_gt_table.png",
       vwidth = 800,
       vheight = 400)

cat("      ✓ Saved: sports_gt_table.png\n")

# Example 2: Monthly Competition Comparison Table
monthly_summary <- monthly_df %>%
  group_by(Competition) %>%
  summarise(
    TotalMinutes = sum(ViewingMinutes),
    AvgMonthlyViewers = mean(UniqueViewers),
    PeakMonth = YearMonth[which.max(UniqueViewers)],
    GrowthRate = ((last(UniqueViewers) - first(UniqueViewers)) / first(UniqueViewers) * 100)
  ) %>%
  arrange(desc(TotalMinutes)) %>%
  head(8)

competition_gt_table <- monthly_summary %>%
  gt() %>%
  tab_header(
    title = "Top Competition Performance",
    subtitle = "Ranked by Total Viewing Minutes"
  ) %>%
  cols_label(
    Competition = "Competition",
    TotalMinutes = "Total Minutes",
    AvgMonthlyViewers = "Avg Monthly Viewers",
    PeakMonth = "Peak Month",
    GrowthRate = "Growth Rate (%)"
  ) %>%
  fmt_number(
    columns = c(TotalMinutes, AvgMonthlyViewers),
    decimals = 0,
    use_seps = TRUE
  ) %>%
  fmt_number(
    columns = GrowthRate,
    decimals = 1
  ) %>%
  data_color(
    columns = GrowthRate,
    colors = scales::col_numeric(
      palette = c("#FE5F55", "#E8F4F5", "#02C39A"),
      domain = c(-50, 50)
    )
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#00A896"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels()
  ) %>%
  tab_style(
    style = cell_borders(
      sides = "all",
      color = "#E5E7EB",
      weight = px(1)
    ),
    locations = cells_body()
  ) %>%
  tab_options(
    table.font.size = px(13),
    heading.title.font.size = px(18),
    table.width = pct(100)
  )

gtsave(competition_gt_table, 
       filename = "/dbfs/FileStore/charts/competition_gt_table.png",
       vwidth = 900,
       vheight = 450)

cat("      ✓ Saved: competition_gt_table.png\n")

# Example 3: Device Breakdown with Percentages
device_with_pct <- device_df %>%
  mutate(
    ViewerShare = round(UniqueViewers / sum(UniqueViewers) * 100, 1),
    MinuteShare = round(ViewingMinutes / sum(ViewingMinutes) * 100, 1)
  )

device_gt_table <- device_with_pct %>%
  gt() %>%
  tab_header(
    title = "Device Usage Breakdown",
    subtitle = "Distribution Across Platforms"
  ) %>%
  cols_label(
    Device = "Device Type",
    ViewingMinutes = "Total Minutes",
    UniqueViewers = "Unique Viewers",
    MinutesPerViewer = "Avg Min/Viewer",
    ViewerShare = "Viewer Share (%)",
    MinuteShare = "Minute Share (%)"
  ) %>%
  fmt_number(
    columns = c(ViewingMinutes, UniqueViewers),
    decimals = 0,
    use_seps = TRUE
  ) %>%
  fmt_number(
    columns = c(MinutesPerViewer, ViewerShare, MinuteShare),
    decimals = 1
  ) %>%
  data_color(
    columns = c(ViewerShare, MinuteShare),
    palette = c("#E8F4F5", "#028090")
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#02C39A"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels()
  ) %>%
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(18)
  )

gtsave(device_gt_table, 
       filename = "/dbfs/FileStore/charts/device_gt_table.png",
       vwidth = 950,
       vheight = 350)

cat("      ✓ Saved: device_gt_table.png\n")
```

### Python Script - Insert GT Tables into PowerPoint

Add this to your **`databricks_python_ppt_builder.py`** after the existing slides:

```python
# ========================================================================
# SLIDE 8: GT TABLE - SPORTS PERFORMANCE
# ========================================================================
print("      - Slide 8: Sports Performance Table (GT)")
slide8 = prs.slides.add_slide(prs.slide_layouts[6])

title_shape = slide8.shapes.add_shape(1, Inches(0), Inches(0), Inches(10), Inches(0.7))
title_shape.fill.solid()
title_shape.fill.fore_color.rgb = colors['primary']
title_shape.line.fill.background()

title_text = title_shape.text_frame
title_text.text = "SPORTS PERFORMANCE SUMMARY"
p = title_text.paragraphs[0]
p.font.size = Pt(32)
p.font.bold = True
p.font.color.rgb = colors['white']
p.alignment = PP_ALIGN.LEFT
title_text.margin_left = Inches(0.3)
title_text.vertical_anchor = MSO_ANCHOR.MIDDLE

if os.path.exists("/dbfs/FileStore/charts/sports_gt_table.png"):
    slide8.shapes.add_picture("/dbfs/FileStore/charts/sports_gt_table.png", 
                              Inches(0.5), Inches(1.2), width=Inches(9))
else:
    print("         Warning: sports_gt_table.png not found")

# ========================================================================
# SLIDE 9: GT TABLE - COMPETITION COMPARISON
# ========================================================================
print("      - Slide 9: Competition Comparison Table (GT)")
slide9 = prs.slides.add_slide(prs.slide_layouts[6])

title_shape = slide9.shapes.add_shape(1, Inches(0), Inches(0), Inches(10), Inches(0.7))
title_shape.fill.solid()
title_shape.fill.fore_color.rgb = colors['primary']
title_shape.line.fill.background()

title_text = title_shape.text_frame
title_text.text = "TOP COMPETITION PERFORMANCE"
p = title_text.paragraphs[0]
p.font.size = Pt(32)
p.font.bold = True
p.font.color.rgb = colors['white']
p.alignment = PP_ALIGN.LEFT
title_text.margin_left = Inches(0.3)
title_text.vertical_anchor = MSO_ANCHOR.MIDDLE

if os.path.exists("/dbfs/FileStore/charts/competition_gt_table.png"):
    slide9.shapes.add_picture("/dbfs/FileStore/charts/competition_gt_table.png", 
                              Inches(0.3), Inches(1.2), width=Inches(9.4))
else:
    print("         Warning: competition_gt_table.png not found")

# ========================================================================
# SLIDE 10: GT TABLE - DEVICE BREAKDOWN
# ========================================================================
print("      - Slide 10: Device Breakdown Table (GT)")
slide10 = prs.slides.add_slide(prs.slide_layouts[6])

title_shape = slide10.shapes.add_shape(1, Inches(0), Inches(0), Inches(10), Inches(0.7))
title_shape.fill.solid()
title_shape.fill.fore_color.rgb = colors['primary']
title_shape.line.fill.background()

title_text = title_shape.text_frame
title_text.text = "DEVICE USAGE BREAKDOWN"
p = title_text.paragraphs[0]
p.font.size = Pt(32)
p.font.bold = True
p.font.color.rgb = colors['white']
p.alignment = PP_ALIGN.LEFT
title_text.margin_left = Inches(0.3)
title_text.vertical_anchor = MSO_ANCHOR.MIDDLE

if os.path.exists("/dbfs/FileStore/charts/device_gt_table.png"):
    slide10.shapes.add_picture("/dbfs/FileStore/charts/device_gt_table.png", 
                               Inches(0.4), Inches(1.4), width=Inches(9.2))
else:
    print("         Warning: device_gt_table.png not found")
```

---

## 📊 **Method 2: Using Flextable**

### R Script - Create and Save Flextable

```r
# ============================================================================
# FLEXTABLE ALTERNATIVE
# ============================================================================
library(flextable)
library(officer)  # Required for saving

# Example: Sports Performance Flextable
sports_flex <- sports_df %>%
  flextable() %>%
  set_header_labels(
    Sport = "Sport Category",
    ViewingMinutes = "Total Minutes",
    UniqueViewers = "Unique Viewers",
    MinutesPerViewer = "Avg Min/Viewer"
  ) %>%
  colformat_double(j = c("ViewingMinutes", "UniqueViewers"), big.mark = ",", digits = 0) %>%
  colformat_double(j = "MinutesPerViewer", digits = 1) %>%
  bg(bg = "#028090", part = "header") %>%
  color(color = "white", part = "header") %>%
  bold(part = "header") %>%
  bg(i = ~ Sport == "Football", bg = "#E8F4F5") %>%
  align(align = "center", part = "all") %>%
  autofit() %>%
  width(width = 1.5) %>%
  add_header_lines("Sports Performance Summary - 2025")

# Save as PNG
save_as_image(sports_flex, 
              path = "/dbfs/FileStore/charts/sports_flex_table.png",
              zoom = 3,
              webshot = "webshot2")

cat("      ✓ Saved: sports_flex_table.png\n")

# Advanced Flextable with Conditional Formatting
device_flex <- device_df %>%
  mutate(PerformanceRating = case_when(
    MinutesPerViewer > 15 ~ "High",
    MinutesPerViewer > 12 ~ "Medium",
    TRUE ~ "Low"
  )) %>%
  flextable() %>%
  set_header_labels(
    Device = "Device Type",
    ViewingMinutes = "Total Minutes",
    UniqueViewers = "Unique Viewers",
    MinutesPerViewer = "Avg Min/Viewer",
    PerformanceRating = "Rating"
  ) %>%
  colformat_double(j = c("ViewingMinutes", "UniqueViewers"), big.mark = ",", digits = 0) %>%
  colformat_double(j = "MinutesPerViewer", digits = 1) %>%
  bg(bg = "#00A896", part = "header") %>%
  color(color = "white", part = "header") %>%
  bold(part = "header") %>%
  bg(i = ~ PerformanceRating == "High", j = "PerformanceRating", bg = "#02C39A") %>%
  bg(i = ~ PerformanceRating == "Medium", j = "PerformanceRating", bg = "#F0B67F") %>%
  bg(i = ~ PerformanceRating == "Low", j = "PerformanceRating", bg = "#FE5F55") %>%
  color(i = ~ PerformanceRating %in% c("High", "Low"), j = "PerformanceRating", color = "white") %>%
  align(align = "center", part = "all") %>%
  autofit() %>%
  add_header_lines("Device Performance Analysis")

save_as_image(device_flex, 
              path = "/dbfs/FileStore/charts/device_flex_table.png",
              zoom = 3,
              webshot = "webshot2")

cat("      ✓ Saved: device_flex_table.png\n")
```

---

## 📦 **Installation Requirements**

### For GT Tables:

```r
# In Databricks R cell
install.packages("gt")
install.packages("webshot2")

# Verify installation
library(gt)
library(webshot2)
```

### For Flextable:

```r
# In Databricks R cell
install.packages("flextable")
install.packages("officer")
install.packages("webshot2")

# Verify installation
library(flextable)
library(officer)
```

---

## 🎨 **Advanced GT Styling Examples**

### Example 1: Sparklines in GT Table

```r
library(gtExtras)

monthly_trends <- monthly_df %>%
  group_by(Competition) %>%
  summarise(
    TotalViewers = sum(UniqueViewers),
    MonthlyTrend = list(UniqueViewers)
  ) %>%
  arrange(desc(TotalViewers)) %>%
  head(8)

sparkline_table <- monthly_trends %>%
  gt() %>%
  tab_header(title = "Competition Trends with Sparklines") %>%
  gt_plt_sparkline(MonthlyTrend, 
                   type = "shaded",
                   line_color = "#028090",
                   fill_color = "#E8F4F5") %>%
  fmt_number(columns = TotalViewers, decimals = 0, use_seps = TRUE) %>%
  tab_style(
    style = cell_fill(color = "#028090"),
    locations = cells_column_labels()
  ) %>%
  tab_style(
    style = cell_text(color = "white", weight = "bold"),
    locations = cells_column_labels()
  )

gtsave(sparkline_table, 
       filename = "/dbfs/FileStore/charts/sparkline_table.png",
       vwidth = 800,
       vheight = 500)
```

### Example 2: GT Table with Images/Icons

```r
library(gtExtras)

sports_with_icons <- sports_df %>%
  mutate(
    Icon = case_when(
      Sport == "Football" ~ "⚽",
      Sport == "Motorsports" ~ "🏎️",
      Sport == "Basketball" ~ "🏀",
      Sport == "Tennis" ~ "🎾",
      Sport == "Rugby" ~ "🏉"
    )
  ) %>%
  select(Icon, everything())

icon_table <- sports_with_icons %>%
  gt() %>%
  tab_header(title = "Sports Performance with Icons") %>%
  cols_label(Icon = "") %>%
  fmt_number(columns = c(ViewingMinutes, UniqueViewers), decimals = 0, use_seps = TRUE) %>%
  fmt_number(columns = MinutesPerViewer, decimals = 1) %>%
  tab_style(
    style = cell_text(size = px(24)),
    locations = cells_body(columns = Icon)
  ) %>%
  data_color(
    columns = UniqueViewers,
    palette = "viridis"
  )

gtsave(icon_table, 
       filename = "/dbfs/FileStore/charts/icon_table.png",
       vwidth = 850,
       vheight = 400)
```

---

## 🔥 **Pro Tips**

### 1. **Optimize Image Quality**

```r
# For GT tables - adjust dimensions for clarity
gtsave(your_table, 
       filename = "/dbfs/FileStore/charts/table.png",
       vwidth = 1000,   # Wider = more detail
       vheight = 600,   # Taller = more rows visible
       expand = 10)     # Add padding around table
```

### 2. **Handle Long Tables**

```r
# Split long tables across multiple slides
long_table <- monthly_df %>%
  arrange(desc(ViewingMinutes))

# First half
table_part1 <- long_table %>%
  slice(1:15) %>%
  gt() %>%
  tab_header(title = "Top Competitions (Part 1)")

gtsave(table_part1, "/dbfs/FileStore/charts/table_part1.png")

# Second half
table_part2 <- long_table %>%
  slice(16:30) %>%
  gt() %>%
  tab_header(title = "Top Competitions (Part 2)")

gtsave(table_part2, "/dbfs/FileStore/charts/table_part2.png")
```

### 3. **Create Summary Tables**

```r
# Create a summary table with totals
summary_table <- sports_df %>%
  bind_rows(
    tibble(
      Sport = "TOTAL",
      ViewingMinutes = sum(sports_df$ViewingMinutes),
      UniqueViewers = sum(sports_df$UniqueViewers),
      MinutesPerViewer = mean(sports_df$MinutesPerViewer)
    )
  ) %>%
  gt() %>%
  tab_style(
    style = list(
      cell_fill(color = "#028090"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_body(rows = Sport == "TOTAL")
  )

gtsave(summary_table, "/dbfs/FileStore/charts/summary_table.png")
```

---

## ✅ **Complete Workflow Summary**

```
R (Cell 1):
├── Create data frames
├── Create GT/flextable tables
├── Save tables as PNG → /dbfs/FileStore/charts/
└── Register data as Spark temp views

Python (Cell 2):
├── Read Spark temp views
├── Load table images from DBFS
├── Insert tables into PowerPoint slides
└── Save presentation
```

This approach gives you the **best of both worlds**:
- ✅ Beautiful, complex formatting from GT/flextable
- ✅ Easy integration into PowerPoint
- ✅ Full control over table styling in R
- ✅ No data loss or formatting issues

The tables will look **exactly** as they appear in R! 🎨
