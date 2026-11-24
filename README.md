# US Groceries and Fuel Prices Analysis

## Overview
Grocery prices are always a relevant topic, from food to commodities.
We want to find if there is any hidden data within the prices, anything that we can point and say that predicts anything.
Analyzing the U.S.A's economy is no simple or straightforward task, and quite frankly to make any conclusion statement would be in bad faith.
This project aims to analyze the economy in a more superficial way, figuring out if there are any outlying issues that can be seen without
having a heavy economical understanding.
We are going to first determine if month-to-month changes are noticeable for all products, excluding fuel.
Then we are checking if fuel prices precede changes in groceries.
 
## Dataset
**US Grocery and Gas Prices (2015-2026)**
74 items recorded monthly, and gathered in US BLS's Average Price Data programme and downloaded from Kaggle (Harshit Kumar's US Grocery and Gas Prices 2015-2026). \\
Variables: date, year, month, item, unit, category, price, id.
Fuel items are excluded from the primary analysis (see Methods).

## Research questions
- **RQ1:** Do month-to-month price changes of grocery items move together more
  within product categories than between them?
- **RQ2:** Do changes in fuel prices precede changes in grocery prices, and
  does this vary by category?

## Methods
1. Convert prices to month-over-month log differences
2. Compute Spearman correlation matrix
3. Permutation test (5,000 shuffles) of within- vs. between-category mean correlation
4. Robustness: seasonal adjustment, excluding 2021-2023, with/without fuel
5. Lagged correlations between diesel and grocery price changes


### Source and License
SOURCE AND LICENSE US Bureau of Labor Statistics, Average Price Data (AP), U.S. city average, monthly, not seasonally adjusted. \\
Built from ap.series plus ap.data.3.Food, ap.data.2.Gasoline and ap.data.1.HouseholdFuels, filtered to area_code 0000 (national). \\
Works of the US federal government are in the public domain (CC0). \\
BLS does not endorse this compilation.

## Version Control
Renv was not used, here are some outputs from sessionInfo(): \\
R version 4.6.2 (2026-10-29) \\
attached base packages:
[1] stats     graphics  grDevices datasets 
[5] utils     methods   base     

other attached packages:
 [1] rstatix_1.1.0   readxl_1.6.0    lubridate_1.9.5
 [4] forcats_1.0.1   stringr_1.6.0   dplyr_1.2.1    
 [7] purrr_1.2.2     readr_2.2.0     tidyr_1.3.2    
[10] tibble_3.3.1    ggplot2_4.0.4   tidyverse_2.0.0
