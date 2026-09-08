# Auxiliary Agriculture Tool (AAT)
Auxiliary tool for estimating agricultural areas and associated emissions at the state level in Brazil.

## Inputs
- `report.rds`: MAgPIE-Brazil scenario outputs
- `AAT_shares_byState.csv`: state allocation shares for agricultural systems 【1-dd2480】

## Outputs
- `AAT_areas_byState.csv`
- `AAT_emissions_byState.csv`

## Method
1. Read national MAgPIE-Brazil projections.
2. Allocate pasture and cropland areas to states using predefined shares.
3. Apply emission factors to estimate state-level emissions and removals.

## Run
```r
source("AAT.R")
```

## Dependencies
```r
library(tidyverse)
```

## Project
Developed within the Net Zero Brasil (NZB) initiative.
