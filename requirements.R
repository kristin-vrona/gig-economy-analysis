# List of required packages
required_packages <- c(
  "tidyverse",    # Data manipulation and visualization
  "lubridate",    # Date handling  
  "fixest",       # Econometrics
  "plotly",       # Interactive plots
  "rmarkdown"     # Reporting
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load packages
library(tidyverse)
library(lubridate)
library(fixest)
library(plotly)