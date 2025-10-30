
# Gig Economy Impact Analysis

## Project Overview
This analysis examines how gig economy participation affects worker income and economic stability using synthetic longitudinal employment data.

## Methods
- **Data**: Synthetic panel data for 2,000 workers over 8 quarters
- **Analysis**: Fixed effects models to control for individual characteristics
- **Visualization**: ggplot2 and plotly for interactive charts

## Key Findings
1. Gig work is growing over time, particularly among less-educated workers
2. Gig workers experience 20-30% lower income than traditional workers
3. Income volatility is significantly higher for gig workers

## How to Run
1. Open RStudio and set working directory to this folder
2. Run: `source("gig_analysis.R")`
3. Or knit: `rmarkdown::render("gig_report.Rmd")`

## Files
- `gig_analysis.R` - Main analysis script
- `gig_report.Rmd` - Summary report
- `requirements.R` - Package setup

