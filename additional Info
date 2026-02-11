We are free to add additional columns/values to any of the data frames. The scripts are designed to be flexible.

## ✅ What You Can Safely Add:

### 1. **Summary Data** - Add ANY metrics you want:

```r
summary_df <- data.frame(
  # Original fields
  TotalViewingMinutes = 125840000,
  UniqueViewers = 8450000,
  AvgMinutesPerViewer = 14.9,
  TotalAssets = 1250,
  
  # ✅ ADD YOUR OWN FIELDS
  TotalRevenue = 5000000,
  SubscriberGrowth = 15.3,
  ChurnRate = 2.1,
  CustomerSatisfaction = 4.5,
  AdImpressions = 50000000,
  PeakConcurrentViewers = 125000,
  # ... add as many as you need!
)
```

**How it shows in PowerPoint:**
The Executive Summary slide uses only these 4 specific fields for the metric cards:
- `TotalViewingMinutes`
- `UniqueViewers`
- `AvgMinutesPerViewer`
- `TotalAssets`

Your additional fields are **still available** in the Python script for custom analysis or additional slides.

---

### 2. **Monthly Data** - Add more dimensions:

```r
monthly_df <- data.frame(
  # Original fields
  YearMonth = ...,
  Competition = ...,
  ViewingMinutes = ...,
  UniqueViewers = ...,
  MinutesPerViewer = ...,
  
  # ✅ ADD YOUR OWN FIELDS
  Revenue = ...,
  Region = c('North America', 'Europe', 'Asia', ...),
  Platform = c('Web', 'Mobile App', ...),
  AgeGroup = c('18-24', '25-34', ...),
  ContentType = c('Live', 'Replay', ...),
  AdRevenue = ...,
  SubscriptionRevenue = ...,
  # ... whatever you need!
)
```

---

### 3. **Sports Data** - Add metrics:

```r
sports_df <- data.frame(
  # Original fields
  Sport = c('Football', 'Motorsports', ...),
  ViewingMinutes = ...,
  UniqueViewers = ...,
  MinutesPerViewer = ...,
  
  # ✅ ADD YOUR OWN FIELDS
  TotalEvents = c(245, 24, 82, ...),
  AvgRating = c(4.2, 3.9, 4.5, ...),
  RevenuePerViewer = c(5.50, 8.20, ...),
  SocialMediaMentions = c(1500000, 850000, ...),
  MarketShare = c(45.2, 12.5, ...),
  # ... add whatever you track!
)
```

---

### 4. **Device Data** - Add more info:

```r
device_df <- data.frame(
  # Original fields
  Device = c('TV', 'Mobile', 'Tablet', 'Desktop'),
  ViewingMinutes = ...,
  UniqueViewers = ...,
  MinutesPerViewer = ...,
  
  # ✅ ADD YOUR OWN FIELDS
  OS = c('Various', 'iOS/Android', 'iOS/Android', 'Win/Mac'),
  AvgSessionDuration = c(45, 18, 22, 38),
  ConversionRate = c(12.5, 8.3, 9.1, 15.2),
  BufferingEvents = c(1200, 8500, 3200, 1500),
  # ... add device-specific metrics!
)
```

---

## 📊 How to USE Your Additional Fields:

### Option A: Access in Python for Custom Analysis

```python
# In the Python script, after loading data:
monthly_data = spark.sql("SELECT * FROM monthly_data").toPandas()

# Now you have access to ALL columns
print(monthly_data.columns)
# Output: ['YearMonth', 'Competition', 'ViewingMinutes', 'UniqueViewers', 
#          'MinutesPerViewer', 'Revenue', 'Region', 'Platform', ...]

# Use them in your analysis:
revenue_by_region = monthly_data.groupby('Region')['Revenue'].sum()
print(revenue_by_region)
```

### Option B: Add New Metric Cards to Executive Summary

In **`databricks_python_ppt_builder.py`**, modify the metrics section (around line 113):

```python
# Original 4 cards:
metrics = [
    ("📊", "Total Viewing Minutes", f"{int(summary['TotalViewingMinutes']):,}"),
    ("👥", "Unique Viewers", f"{int(summary['UniqueViewers']):,}"),
    ("⏱️", "Avg Minutes/Viewer", f"{summary['AvgMinutesPerViewer']:.1f}"),
    ("🎬", "Total Assets", f"{int(summary['TotalAssets']):,}")
]

# ✅ ADD YOUR NEW CARDS:
metrics = [
    ("📊", "Total Viewing Minutes", f"{int(summary['TotalViewingMinutes']):,}"),
    ("👥", "Unique Viewers", f"{int(summary['UniqueViewers']):,}"),
    ("⏱️", "Avg Minutes/Viewer", f"{summary['AvgMinutesPerViewer']:.1f}"),
    ("🎬", "Total Assets", f"{int(summary['TotalAssets']):,}"),
    ("💰", "Total Revenue", f"${int(summary['TotalRevenue']):,}"),  # NEW!
    ("📈", "Subscriber Growth", f"{summary['SubscriberGrowth']:.1f}%"),  # NEW!
]
```

### Option C: Create Custom Charts with Your New Fields

In **R script**, add a new chart:

```r
# Example: Revenue by Region
revenue_by_region <- monthly_df %>%
  group_by(Region) %>%
  summarise(TotalRevenue = sum(Revenue))

revenue_chart <- ggplot(revenue_by_region, aes(x = reorder(Region, TotalRevenue), 
                                                 y = TotalRevenue)) +
  geom_bar(stat = "identity", fill = "#028090") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Revenue by Region", x = "Region", y = "Revenue ($)")

ggsave("/dbfs/FileStore/charts/revenue_by_region.png", revenue_chart, 
       width = 10, height = 6, dpi = 150, bg = "white")
```

Then add it to the PowerPoint in **Python script**:

```python
# Add new slide with your custom chart
slide_revenue = prs.slides.add_slide(prs.slide_layouts[6])

# Add title bar (copy from other slides)
title_shape = slide_revenue.shapes.add_shape(1, Inches(0), Inches(0), Inches(10), Inches(0.7))
title_shape.fill.solid()
title_shape.fill.fore_color.rgb = colors['primary']
title_shape.line.fill.background()

title_text = title_shape.text_frame
title_text.text = "REVENUE BY REGION"
# ... (copy formatting from other slides)

# Add your chart
slide_revenue.shapes.add_picture("/dbfs/FileStore/charts/revenue_by_region.png", 
                                  Inches(1), Inches(1.2), width=Inches(8))
```

### Option D: Add Columns to Existing Table

In **Python script**, modify the table creation (around line 362):

```python
# Original table headers
headers = ["Sport", "Viewing Minutes", "Unique Viewers", "Minutes/Viewer"]

# ✅ ADD YOUR NEW COLUMNS:
headers = ["Sport", "Viewing Minutes", "Unique Viewers", "Minutes/Viewer", 
           "Total Events", "Avg Rating"]

# Update table creation
rows = len(sports_data) + 1
cols = 6  # Changed from 4 to 6

# ... create table ...

# In the data row loop, add your new columns:
for row_idx, (_, row) in enumerate(sports_data.iterrows(), start=1):
    table.cell(row_idx, 0).text = str(row['Sport'])
    table.cell(row_idx, 1).text = f"{int(row['ViewingMinutes']):,}"
    table.cell(row_idx, 2).text = f"{int(row['UniqueViewers']):,}"
    table.cell(row_idx, 3).text = f"{row['MinutesPerViewer']:.2f}"
    table.cell(row_idx, 4).text = f"{int(row['TotalEvents']):,}"  # NEW!
    table.cell(row_idx, 5).text = f"{row['AvgRating']:.1f}"       # NEW!
```

---

## ⚠️ Important Notes:

1. **Don't Remove Original Fields** - The Python script expects these specific fields:
   - Summary: `TotalViewingMinutes`, `UniqueViewers`, `AvgMinutesPerViewer`, `TotalAssets`
   - Monthly: `YearMonth`, `Competition`, `ViewingMinutes`, `UniqueViewers`, `MinutesPerViewer`
   - Sports: `Sport`, `ViewingMinutes`, `UniqueViewers`, `MinutesPerViewer`
   - Device: `Device`, `ViewingMinutes`, `UniqueViewers`, `MinutesPerViewer`

2. **Adding Fields is Safe** - You can add as many additional columns as you want. They'll be available in Python but won't automatically appear in the presentation unless you explicitly add them.

3. **Access All Fields** - Even if a field isn't used in the presentation, it's still available in the Python DataFrame for custom analysis.

---

## 🎯 Quick Example - Complete Workflow:

```r
# R: Add custom field
summary_df <- data.frame(
  TotalViewingMinutes = 125840000,
  UniqueViewers = 8450000,
  AvgMinutesPerViewer = 14.9,
  TotalAssets = 1250,
  TotalRevenue = 5000000  # ✅ NEW FIELD
)

createOrReplaceTempView(createDataFrame(summary_df), "summary_data")
```

```python
# Python: Access your new field
summary_data = spark.sql("SELECT * FROM summary_data").toPandas()
summary = summary_data.iloc[0].to_dict()

# Use it in custom insight
findings.append(f"Generated ${int(summary['TotalRevenue']):,} in total revenue")

# Or add a new metric card
# (see Option B above)
```

**The system is 100% flexible - add whatever fields you need!** 🚀
