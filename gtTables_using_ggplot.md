Ah yes, the `webshot2` Chrome dependency issue in Databricks! This is a common problem. Here are **multiple solutions**:

---

## 🎯 **Solution 1: Use `webshot` (Original Version) Instead**

The original `webshot` package uses PhantomJS instead of Chrome and works better in Databricks.

### R Script:

```r
# Install webshot (not webshot2)
install.packages("webshot")
library(webshot)

# Install PhantomJS (one-time setup)
webshot::install_phantomjs()

# Now use gt with webshot
library(gt)

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
  )

# Save using webshot (not webshot2)
gtsave(sports_gt_table, 
       filename = "/dbfs/FileStore/charts/sports_gt_table.png",
       vwidth = 800,
       vheight = 400)
```

---

## 🎯 **Solution 2: Use `htmltools` + `webshot` Manually**

More control over the rendering process:

```r
library(gt)
library(htmltools)
library(webshot)

# Create GT table
sports_gt_table <- sports_df %>%
  gt() %>%
  # ... your styling ...
  tab_options(
    table.width = px(800)
  )

# Save as HTML first
html_file <- "/dbfs/FileStore/temp/table.html"
gtsave(sports_gt_table, filename = html_file)

# Convert HTML to PNG using webshot
webshot(
  url = html_file,
  file = "/dbfs/FileStore/charts/sports_gt_table.png",
  vwidth = 800,
  vheight = 400,
  delay = 0.5  # Wait for rendering
)

# Clean up temp file
file.remove(html_file)
```

---

## 🎯 **Solution 3: Use `flextable` (Easier in Databricks)**

Flextable has better Databricks compatibility and doesn't always need webshot:

```r
library(flextable)
library(officer)

# Create flextable
sports_flex <- sports_df %>%
  flextable() %>%
  set_header_labels(
    Sport = "Sport Category",
    ViewingMinutes = "Total Minutes",
    UniqueViewers = "Unique Viewers",
    MinutesPerViewer = "Avg Min/Viewer"
  ) %>%
  colformat_double(j = c("ViewingMinutes", "UniqueViewers"), 
                   big.mark = ",", digits = 0) %>%
  colformat_double(j = "MinutesPerViewer", digits = 1) %>%
  bg(bg = "#028090", part = "header") %>%
  color(color = "white", part = "header") %>%
  bold(part = "header") %>%
  align(align = "center", part = "all") %>%
  autofit() %>%
  add_header_lines("Sports Performance Summary - 2025")

# Method A: Save directly (if magick is available)
library(magick)
save_as_image(sports_flex, 
              path = "/dbfs/FileStore/charts/sports_flex_table.png",
              zoom = 3)

# Method B: If magick fails, use webshot (original)
library(webshot)
webshot::install_phantomjs()  # One-time

save_as_image(sports_flex, 
              path = "/dbfs/FileStore/charts/sports_flex_table.png",
              zoom = 3,
              webshot = "webshot")  # Use webshot, not webshot2
```

---

## 🎯 **Solution 4: Create Tables with `ggplot2` (No Dependencies!)**

Since you already have ggplot2 working, create tables as ggplot objects:

```r
library(ggplot2)
library(gridExtra)
library(grid)

# Prepare data for table
sports_table_data <- sports_df %>%
  mutate(
    ViewingMinutes = format(ViewingMinutes, big.mark = ","),
    UniqueViewers = format(UniqueViewers, big.mark = ","),
    MinutesPerViewer = sprintf("%.1f", MinutesPerViewer)
  )

# Create table theme
my_theme <- ttheme_default(
  core = list(
    fg_params = list(hjust = 0.5, x = 0.5, fontsize = 12),
    bg_params = list(fill = c("#FFFFFF", "#E8F4F5"))
  ),
  colhead = list(
    fg_params = list(fontface = "bold", fontsize = 14, col = "white"),
    bg_params = list(fill = "#028090")
  ),
  rowhead = list(
    fg_params = list(fontface = "bold")
  )
)

# Create table
table_plot <- tableGrob(
  sports_table_data,
  rows = NULL,
  theme = my_theme
)

# Add title
title <- textGrob(
  "Sports Performance Summary",
  gp = gpar(fontsize = 18, fontface = "bold"),
  just = "center"
)

subtitle <- textGrob(
  "2025 Full Year Analysis",
  gp = gpar(fontsize = 14, col = "#6B7280"),
  just = "center"
)

# Combine title and table
final_plot <- arrangeGrob(
  title,
  subtitle,
  table_plot,
  heights = c(0.1, 0.05, 0.85),
  padding = unit(0.5, "line")
)

# Save as PNG
ggsave(
  "/dbfs/FileStore/charts/sports_table.png",
  final_plot,
  width = 10,
  height = 6,
  dpi = 150,
  bg = "white"
)

cat("      ✓ Saved: sports_table.png\n")
```

### Advanced ggplot2 Table with Conditional Formatting:

```r
library(ggplot2)
library(dplyr)
library(scales)

# Create styled table data
sports_styled <- sports_df %>%
  mutate(
    Performance = case_when(
      MinutesPerViewer > 14 ~ "High",
      MinutesPerViewer > 13 ~ "Medium",
      TRUE ~ "Low"
    ),
    Color = case_when(
      Performance == "High" ~ "#02C39A",
      Performance == "Medium" ~ "#F0B67F",
      TRUE ~ "#FE5F55"
    )
  )

# Create custom table plot
p <- ggplot(sports_styled, aes(x = 1, y = rev(seq_along(Sport)))) +
  # Background rectangles
  geom_tile(aes(x = 1.5, fill = Color), width = 3, height = 0.8, alpha = 0.3) +
  scale_fill_identity() +
  
  # Sport names (column 1)
  geom_text(aes(x = 0.5, label = Sport), 
            fontface = "bold", size = 5, hjust = 0) +
  
  # Viewing Minutes (column 2)
  geom_text(aes(x = 1, label = format(ViewingMinutes, big.mark = ",")), 
            size = 4.5, hjust = 0.5) +
  
  # Unique Viewers (column 3)
  geom_text(aes(x = 1.5, label = format(UniqueViewers, big.mark = ",")), 
            size = 4.5, hjust = 0.5) +
  
  # Minutes per Viewer (column 4)
  geom_text(aes(x = 2, label = sprintf("%.1f", MinutesPerViewer)), 
            size = 4.5, hjust = 0.5) +
  
  # Performance (column 5)
  geom_text(aes(x = 2.5, label = Performance, color = Color), 
            fontface = "bold", size = 4.5, hjust = 0.5) +
  scale_color_identity() +
  
  # Column headers
  annotate("rect", xmin = 0.2, xmax = 2.8, 
           ymin = max(seq_along(sports_styled$Sport)) + 0.4, 
           ymax = max(seq_along(sports_styled$Sport)) + 0.9,
           fill = "#028090") +
  annotate("text", x = 0.5, 
           y = max(seq_along(sports_styled$Sport)) + 0.65,
           label = "Sport", fontface = "bold", size = 5, 
           color = "white", hjust = 0) +
  annotate("text", x = 1, 
           y = max(seq_along(sports_styled$Sport)) + 0.65,
           label = "Total Minutes", fontface = "bold", size = 5, 
           color = "white") +
  annotate("text", x = 1.5, 
           y = max(seq_along(sports_styled$Sport)) + 0.65,
           label = "Unique Viewers", fontface = "bold", size = 5, 
           color = "white") +
  annotate("text", x = 2, 
           y = max(seq_along(sports_styled$Sport)) + 0.65,
           label = "Min/Viewer", fontface = "bold", size = 5, 
           color = "white") +
  annotate("text", x = 2.5, 
           y = max(seq_along(sports_styled$Sport)) + 0.65,
           label = "Performance", fontface = "bold", size = 5, 
           color = "white") +
  
  # Title
  ggtitle("Sports Performance Summary",
          subtitle = "2025 Full Year Analysis") +
  
  theme_void() +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, 
                              margin = margin(b = 5)),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "#6B7280",
                                 margin = margin(b = 15)),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  coord_cartesian(xlim = c(0.2, 2.8), 
                  ylim = c(0.5, max(seq_along(sports_styled$Sport)) + 1))

# Save
ggsave(
  "/dbfs/FileStore/charts/sports_styled_table.png",
  p,
  width = 11,
  height = 7,
  dpi = 150,
  bg = "white"
)
```

---

## 🎯 **Solution 5: Install Chrome in Databricks (Advanced)**

If you really need webshot2, you can install Chrome in your cluster init script:

### Create Init Script:

1. Go to your Databricks cluster configuration
2. Click "Advanced Options" → "Init Scripts"
3. Create a new init script:

```bash
#!/bin/bash

# Install Chrome dependencies
apt-get update
apt-get install -y wget gnupg

# Add Chrome repository
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

# Install Chrome
apt-get update
apt-get install -y google-chrome-stable

# Verify installation
google-chrome --version
```

4. Save to DBFS: `/databricks/scripts/install_chrome.sh`
5. Restart cluster

Then in R:
```r
library(gt)
library(webshot2)

# Now webshot2 will work
gtsave(your_table, 
       filename = "/dbfs/FileStore/charts/table.png")
```

---

## 🎯 **Solution 6: Use Python to Create Tables (Alternative)**

Since you're already using Python for PowerPoint, you could create tables directly in Python:

```python
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

def create_table_image(df, filename, title="Table"):
    """Create a professional table image using matplotlib"""
    
    fig, ax = plt.subplots(figsize=(10, len(df) * 0.5 + 1))
    ax.axis('tight')
    ax.axis('off')
    
    # Add title
    plt.title(title, fontsize=18, fontweight='bold', pad=20)
    
    # Create table
    table = ax.table(
        cellText=df.values,
        colLabels=df.columns,
        cellLoc='center',
        loc='center',
        colWidths=[0.15] * len(df.columns)
    )
    
    # Style table
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1, 2)
    
    # Style header
    for i in range(len(df.columns)):
        cell = table[(0, i)]
        cell.set_facecolor('#028090')
        cell.set_text_props(weight='bold', color='white', size=14)
    
    # Style rows with alternating colors
    for i in range(1, len(df) + 1):
        for j in range(len(df.columns)):
            cell = table[(i, j)]
            if i % 2 == 0:
                cell.set_facecolor('#E8F4F5')
            else:
                cell.set_facecolor('#FFFFFF')
    
    plt.savefig(filename, bbox_inches='tight', dpi=150, facecolor='white')
    plt.close()

# Use it
sports_data_formatted = sports_data.copy()
sports_data_formatted['ViewingMinutes'] = sports_data_formatted['ViewingMinutes'].apply(lambda x: f"{int(x):,}")
sports_data_formatted['UniqueViewers'] = sports_data_formatted['UniqueViewers'].apply(lambda x: f"{int(x):,}")
sports_data_formatted['MinutesPerViewer'] = sports_data_formatted['MinutesPerViewer'].apply(lambda x: f"{x:.1f}")

create_table_image(
    sports_data_formatted, 
    "/dbfs/FileStore/charts/sports_table_python.png",
    title="Sports Performance Summary"
)
```

---

## ✅ **Recommended Approach**

For Databricks, I recommend **Solution 1 (webshot + PhantomJS)** or **Solution 4 (ggplot2 tables)**:

### Quick Implementation:

```r
# ============================================================================
# COMPLETE WORKING SOLUTION - COPY THIS
# ============================================================================

# Option 1: Using webshot (EASIEST)
install.packages("webshot")
library(webshot)
library(gt)

# Install PhantomJS (one-time)
webshot::install_phantomjs()

# Create and save GT table
sports_gt_table <- sports_df %>%
  gt() %>%
  tab_header(title = "Sports Performance Summary") %>%
  fmt_number(columns = c(ViewingMinutes, UniqueViewers), decimals = 0, use_seps = TRUE) %>%
  tab_style(
    style = list(cell_fill(color = "#028090"), cell_text(color = "white", weight = "bold")),
    locations = cells_column_labels()
  )

gtsave(sports_gt_table, 
       filename = "/dbfs/FileStore/charts/sports_gt_table.png")

# Option 2: Using ggplot2 (NO DEPENDENCIES)
library(ggplot2)
library(gridExtra)

table_plot <- tableGrob(
  sports_df,
  rows = NULL,
  theme = ttheme_default(
    core = list(bg_params = list(fill = c("#FFFFFF", "#E8F4F5"))),
    colhead = list(
      fg_params = list(fontface = "bold", col = "white"),
      bg_params = list(fill = "#028090")
    )
  )
)

ggsave(
  "/dbfs/FileStore/charts/sports_table_ggplot.png",
  table_plot,
  width = 10,
  height = 6,
  dpi = 150,
  bg = "white"
)
```

Both methods work reliably in Databricks without Chrome! 🎉
