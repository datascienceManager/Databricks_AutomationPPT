# Sports Viewing Analytics - Databricks R to Python PowerPoint Generator

## 🎯 Overview

This is a comprehensive automated report generation system for Databricks that combines the power of R's data manipulation and ggplot2 visualization with Python's PowerPoint creation capabilities.

**Workflow:**
1. **R**: Create data frames and beautiful ggplot2 charts → Save as Spark temp views and PNG files
2. **Python**: Read data from Spark temp views → Embed charts → Generate professional PowerPoint presentation

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [File Structure](#file-structure)
- [Detailed Usage](#detailed-usage)
- [Data Format Requirements](#data-format-requirements)
- [Customization Guide](#customization-guide)
- [Troubleshooting](#troubleshooting)
- [Advanced Features](#advanced-features)

---

## ✅ Prerequisites

### Required Libraries

**R Libraries:**
```r
install.packages("SparkR")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("tidyr")  # Optional, for data reshaping
```

**Python Libraries:**
```bash
# In Databricks notebook cell
%pip install python-pptx pandas
```

### Databricks Requirements
- Databricks Runtime 11.0+
- Cluster with both R and Python support
- Write access to `/dbfs/FileStore/`

---

## 🚀 Quick Start

### Step 1: Upload Scripts to Databricks

Upload both scripts to your Databricks workspace:
- `databricks_r_data_generator.R`
- `databricks_python_ppt_builder.py`

### Step 2: Create a New Notebook

Create a new Databricks notebook with **both R and Python** cells.

### Step 3: Run R Cell

```r
# Cell 1 (R)
source("/Workspace/path/to/databricks_r_data_generator.R")
```

Or copy-paste the R script content directly into an R cell.

### Step 4: Run Python Cell

```python
# Cell 2 (Python)
exec(open("/Workspace/path/to/databricks_python_ppt_builder.py").read())
```

Or copy-paste the Python script content directly into a Python cell.

### Step 5: Download Your Presentation

Click the download button that appears, or navigate to:
```
/FileStore/presentations/Sports_Viewing_Analytics_Report_2025.pptx
```

---

## 📁 File Structure

```
databricks-sports-analytics/
│
├── databricks_r_data_generator.R          # R script for data & charts
├── databricks_python_ppt_builder.py       # Python script for PowerPoint
├── README.md                               # This file
│
└── Output Structure in DBFS:
    ├── /dbfs/FileStore/charts/
    │   ├── sports_pie.png
    │   ├── device_lollipop.png
    │   ├── competition_bar.png
    │   ├── competition_line.png
    │   └── sports_comparison.png
    │
    └── /dbfs/FileStore/presentations/
        └── Sports_Viewing_Analytics_Report_2025.pptx
```

---

## 📖 Detailed Usage

### R Script: `databricks_r_data_generator.R`

**Purpose:** Generate sports viewing data and create ggplot2 visualizations

**What it does:**
1. Creates 4 data frames:
   - `summary_df`: Overall KPIs (viewing minutes, unique viewers, etc.)
   - `monthly_df`: Monthly data for 12 competitions across 12 months
   - `sports_df`: Aggregated data by sport category
   - `device_df`: Viewership breakdown by device type

2. Registers data as Spark temp views:
   - `summary_data`
   - `monthly_data`
   - `sports_data`
   - `device_data`

3. Creates 5 professional ggplot2 charts:
   - Sports distribution pie chart
   - Device viewership lollipop chart
   - Top competitions bar chart
   - Competition trends line chart
   - Sports comparison chart

4. Saves charts as PNG files to `/dbfs/FileStore/charts/`

**Key Variables to Customize:**

```r
# Line 24-26: Competitions list
competitions <- c('LaLiga', 'Premier League', 'UCL', ...)

# Line 28-31: Months (change to your date range)
months <- c('2025-January', '2025-February', ...)

# Line 72-76: Sports categories
sports_df <- data.frame(
  Sport = c('Football', 'Motorsports', 'Basketball', ...),
  ...
)

# Line 86-90: Device types
device_df <- data.frame(
  Device = c('TV', 'Mobile', 'Tablet', 'Desktop'),
  ...
)
```

### Python Script: `databricks_python_ppt_builder.py`

**Purpose:** Create PowerPoint presentation from R data and charts

**What it does:**
1. Loads data from Spark temp views created by R
2. Generates automated insights and recommendations
3. Creates 10-slide professional PowerPoint presentation
4. Saves to `/dbfs/FileStore/presentations/`
5. Displays download link in notebook

**Presentation Structure:**
1. Title slide (branded with teal theme)
2. Executive summary (4 metric cards)
3. Key findings (6 automated insights)
4. Sports distribution chart
5. Device viewership chart
6. Competition trends chart
7. Top competitions chart
8. Data table (sports metrics)
9. Strategic recommendations
10. Closing slide

---

## 📊 Data Format Requirements

### Summary Data Format

```r
summary_df <- data.frame(
  TotalViewingMinutes = numeric,    # Total minutes watched
  UniqueViewers = numeric,          # Count of unique viewers
  AvgMinutesPerViewer = numeric,    # Average engagement
  TotalAssets = numeric             # Number of content assets
)
```

### Monthly Data Format

```r
monthly_df <- data.frame(
  YearMonth = character,            # Format: "2025-January"
  Competition = character,          # Competition name
  ViewingMinutes = numeric,         # Total viewing minutes
  UniqueViewers = numeric,          # Unique viewer count
  MinutesPerViewer = numeric        # Average per viewer
)
```

### Sports Data Format

```r
sports_df <- data.frame(
  Sport = character,                # Sport category name
  ViewingMinutes = numeric,         # Total viewing minutes
  UniqueViewers = numeric,          # Unique viewer count
  MinutesPerViewer = numeric        # Average per viewer
)
```

### Device Data Format

```r
device_df <- data.frame(
  Device = character,               # Device type name
  ViewingMinutes = numeric,         # Total viewing minutes
  UniqueViewers = numeric,          # Unique viewer count
  MinutesPerViewer = numeric        # Average per viewer
)
```

---

## 🎨 Customization Guide

### Change Color Scheme

**In R Script** (Line 106):
```r
chart_colors <- c('#028090', '#00A896', '#02C39A', '#F0B67F', '#FE5F55', '#5C6B73')
# Replace with your brand colors
```

**In Python Script** (Line 76-83):
```python
colors = {
    'primary': RGBColor(2, 128, 144),      # Your primary color
    'secondary': RGBColor(0, 168, 150),    # Your secondary color
    'accent': RGBColor(2, 195, 154),       # Your accent color
    # ... etc
}
```

### Add Custom Charts

**In R Script**, add after line 250:

```r
# Custom Chart Example
my_custom_chart <- ggplot(your_data, aes(x = x_var, y = y_var)) +
  geom_bar(stat = "identity", fill = "#028090") +
  theme_minimal() +
  labs(title = "My Custom Chart")

ggsave("/dbfs/FileStore/charts/my_custom_chart.png", my_custom_chart, 
       width = 10, height = 6, dpi = 150, bg = "white")
```

**In Python Script**, add a new slide:

```python
# Add after line 400 (after slide7)
slide_custom = prs.slides.add_slide(prs.slide_layouts[6])
# ... add title bar ...
slide_custom.shapes.add_picture("/dbfs/FileStore/charts/my_custom_chart.png", 
                                Inches(1), Inches(1.2), width=Inches(8))
```

### Modify Insights Generation

**In Python Script** (Line 58-100):

```python
def generate_key_findings(summary, monthly_data, sports_data, device_data):
    findings = []
    
    # Add your custom insight logic here
    findings.append("Your custom insight...")
    
    return findings
```

### Change Presentation Title

**In Python Script** (Line 151-152):

```python
title_frame.text = "YOUR CUSTOM TITLE"
subtitle1_frame.text = "YOUR CUSTOM SUBTITLE"
```

---

## 🔧 Troubleshooting

### Issue: "Table or view not found: summary_data"

**Solution:** Make sure you run the R script first. The Python script depends on Spark temp views created by R.

```python
# Verify temp views exist
spark.sql("SHOW TABLES").show()
```

### Issue: "Chart image not found"

**Solution:** Check that charts were created successfully in R.

```r
# Verify charts exist
list.files("/dbfs/FileStore/charts/")
```

### Issue: Font warnings in R ggplot2

**Solution:** These are harmless warnings. Charts will still render correctly with default fonts. To suppress:

```r
options(warn = -1)  # Suppress warnings
# ... your ggplot code ...
options(warn = 0)   # Restore warnings
```

### Issue: Permission denied writing to DBFS

**Solution:** Ensure your cluster has write permissions to `/dbfs/FileStore/`

```r
# Test write permissions
system("touch /dbfs/FileStore/test_file.txt")
```

### Issue: Memory errors with large datasets

**Solution:** 
1. Increase cluster size
2. Sample your data
3. Process in batches

```r
# Sample data if too large
monthly_df_sample <- monthly_df %>% sample_n(1000)
```

---

## 🚀 Advanced Features

### 1. Loading Real Data from Database

**In R:**
```r
# Connect to your database
library(RJDBC)

# Load data
monthly_df <- dbGetQuery(conn, "
  SELECT 
    DATE_FORMAT(date, '%Y-%B') as YearMonth,
    competition_name as Competition,
    SUM(viewing_minutes) as ViewingMinutes,
    COUNT(DISTINCT user_id) as UniqueViewers,
    AVG(viewing_minutes) as MinutesPerViewer
  FROM viewing_data
  GROUP BY YearMonth, Competition
")

# Continue with temp view creation...
createOrReplaceTempView(createDataFrame(monthly_df), "monthly_data")
```

### 2. Scheduled Report Generation

Create a Databricks job:

```yaml
Job Configuration:
  - Name: Weekly Sports Analytics Report
  - Schedule: Every Monday at 9:00 AM
  - Tasks:
    1. Run R notebook (data generation)
    2. Run Python notebook (PowerPoint creation)
    3. Email notification with download link
```

### 3. Dynamic Date Ranges

**In R:**
```r
# Generate last 12 months dynamically
library(lubridate)

current_month <- floor_date(Sys.Date(), "month")
months <- format(seq(current_month - months(11), current_month, by = "month"), 
                "%Y-%B")

print(months)
# Output: "2024-March" "2024-April" ... "2025-February"
```

### 4. Multi-Language Support

**In Python:**
```python
# Define translations
LANG = "en"  # or "es", "fr", etc.

translations = {
    "en": {
        "title": "SPORTS VIEWING",
        "subtitle": "ANALYTICS REPORT 2025",
        "exec_summary": "EXECUTIVE SUMMARY",
        # ... etc
    },
    "es": {
        "title": "VISUALIZACIÓN DEPORTIVA",
        "subtitle": "INFORME DE ANÁLISIS 2025",
        "exec_summary": "RESUMEN EJECUTIVO",
        # ... etc
    }
}

# Use in slides
title_frame.text = translations[LANG]["title"]
```

### 5. Export to Multiple Formats

```python
# After creating PowerPoint
from pptx2pdf import convert

# Convert to PDF
convert(output_file, '/dbfs/FileStore/presentations/report.pdf')

# Create summary CSV
summary_df = pd.DataFrame([summary])
summary_df.to_csv('/dbfs/FileStore/data/summary.csv', index=False)
```

---

## 📈 Performance Optimization

### For Large Datasets

**R Script optimizations:**
```r
# Use data.table for faster operations
library(data.table)
monthly_dt <- data.table(monthly_df)
top_comps <- monthly_dt[, .(TotalViewers = sum(UniqueViewers)), 
                         by = Competition][order(-TotalViewers)][1:8]

# Cache Spark DataFrames
monthly_spark <- createDataFrame(monthly_df)
cache(monthly_spark)
```

**Python Script optimizations:**
```python
# Use vectorized operations
import numpy as np

# Cache Spark SQL queries
spark.sql("SELECT * FROM monthly_data").cache()
```

---

## 📞 Support & Contributions

### Getting Help

1. Check the [Troubleshooting](#troubleshooting) section
2. Review Databricks documentation
3. Check R and Python library docs

### Contributing

To extend this system:
1. Add new chart types in R script
2. Create corresponding slides in Python script
3. Update this README with your changes

---

## 📄 License

This project is provided as-is for educational and commercial use. Feel free to modify and adapt to your needs.

---

## 🎓 Learning Resources

### R ggplot2
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/)
- [R Graphics Cookbook](https://r-graphics.org/)

### Python python-pptx
- [python-pptx Documentation](https://python-pptx.readthedocs.io/)
- [PowerPoint Automation Guide](https://realpython.com/creating-modifying-powerpoint-python/)

### Databricks
- [Databricks R Guide](https://docs.databricks.com/languages/r.html)
- [Databricks Python Guide](https://docs.databricks.com/languages/python.html)

---

## 🌟 Example Use Cases

### 1. Weekly Executive Reports
Generate automated weekly reports for leadership with the latest viewing metrics.

### 2. Campaign Performance Analysis
Track marketing campaign performance across different sports and platforms.

### 3. Competitive Benchmarking
Compare your platform's performance against competitors or industry benchmarks.

### 4. Regional Analysis
Modify to analyze viewership by region, timezone, or demographic.

### 5. Content Planning
Use insights to inform content acquisition and scheduling decisions.

---

## ⚙️ System Requirements

- **Databricks Runtime:** 11.0+ (with R and Python support)
- **Memory:** 8GB+ recommended for typical datasets
- **Storage:** 100MB+ free space in DBFS
- **R Version:** 4.0+
- **Python Version:** 3.8+

---

## 🔄 Version History

**Version 1.0** (February 2025)
- Initial release
- R data generation with ggplot2 charts
- Python PowerPoint builder
- 10-slide presentation template
- Automated insights generation

---

**Generated by:** Automated Analytics Team  
**Last Updated:** February 2025  
**Documentation Version:** 1.0
