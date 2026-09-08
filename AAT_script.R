##########################################
######AFOLU Agriculture Tool##########
##########################################

library(tidyverse)

# Paths
# Inputs
report_path <- "report.rds"
shares_path <- "AAT_shares_byState.csv"

# Outputs
output_path_areas <- "AAT_areas_byState.csv"
output_path_emissions <- "AAT_emissions_byState.csv"

# Read data
df <- readRDS(report_path)

# Subsets
df <- df[df$region == "BRA", ]

df_pasture  <- df[df$variable == "Resources|Land Cover|+|Pastures and Rangelands", ]
df_cropland <- df[df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Cereals|+|Maize"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Cereals|+|Rice"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Cereals|+|Temperate cereals"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Cereals|+|Tropical cereals"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Oil crops|+|Cotton seed"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Oil crops|+|Soybean"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Oil crops|+|Sunflower"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Oil crops|+|Groundnuts"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Other crops|+|Potatoes"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Other crops|+|Pulses"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Other crops|+|Tropical roots"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Sugar crops|+|Sugar beet"|
                  df$variable == "Resources|Land Cover|Cropland|Croparea|Crops|Sugar crops|+|Sugar cane", ]
df_cropland<-df_cropland%>%group_by(model, scenario, region, unit, period)%>%summarise(value=sum(value))
df_cropland$variable<-"Resources|Land Cover|Cropland|Croparea|Crops..."

# Read shares
areas <- read.csv(shares_path, sep = ";")
#scenarios <- c("A", "B", "C", "D")

##AQUI TEM QUE ENTRAR O NOME DO CENÁRIO QUE O USUÁRIO ESCOLHEU
#ler a tabela da escolha do usuário: user <-... ###ADAPTAÇÃO FICA COM SERGIO/THIAGO?
#selected_scenario_pasture <- user$COLUNA_DO_CENÁRIO[`variable name`=="Pasture condition dynamics"]
#selected_scenario_cropland <- user$COLUNA_DO_CENÁRIO[`variable name`=="Cropland management systems"]

#Provisoriamente para testar
selected_scenario_pasture <- "A"
selected_scenario_cropland <- "A"
areas<-areas[areas$Scenario==selected_scenario_pasture|areas$Scenario==selected_scenario_cropland,]

years <- c("1995", "2000", "2005", "2010", "2015", "2020","2025","2030","2035","2040","2045","2050")
cols  <- paste0("X", years)

# Mapping variables
var_map <- list(
  "Pasture condition dynamics" = df_pasture,
  "Cropland management systems" = df_cropland
)

#Loop for the calculation of total areas in the projected years
for (var_name in names(var_map)) {
  
  df_source <- var_map[[var_name]]
  
  for (i in seq_along(years)) {
    
    yr  <- years[i]
    col <- cols[i]
    
    val <- df_source$value[df_source$period == yr]
    
    idx <- areas$Variable == var_name
    
    areas[idx, col] <- areas[idx, col] * val
  }
}


# Mapping emission factors (tCO2/hectare/year)
emiss_map <- list(
  "Degraded pasture" = 1.03,
  "Intermediate pasture" = 0.11,
  "Well-managed pasture" = -2.24,
  "Conventional tillage" = 1.47,
  "No-till practices" = -0.44,
  "Full no-till system" = -1.84
)

#Loop for the calculation of emissions per system in the projected years
emissions<-areas

for (class_name in names(emiss_map)) {
  
  df_source <- emiss_map[[class_name]]
  
  for (i in seq_along(years)) {
    
    yr  <- years[i]
    col <- cols[i]
    
    idx <- areas$Class == class_name
    
    emissions[idx, col] <- emissions[idx, col] * df_source
  }
}

# Export 
write.csv(areas, output_path_areas, row.names = FALSE)
write.csv(emissions, output_path_emissions, row.names = FALSE)

