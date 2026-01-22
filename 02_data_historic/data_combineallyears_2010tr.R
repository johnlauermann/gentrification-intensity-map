#This script creates a longitudinal tract database. It:
#1) combines each decade of tract-level data
#2) calculates change-related variables
#3) saves a longitudinal tract database for all tracts in the US
#4) saves a longitudinal tract database for urban tracts in the US

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(stringr)) install.packages("stringr")

library(dplyr)
library(here)
library(stringr)

#set working directory & source data
here::i_am("02_data_historic/data_combineallyears_2010tr.R")
data1970 <- read.csv("tractdata_1970_2010tr.csv")
data1980 <- read.csv("tractdata_1980_2010tr.csv")
data1990 <- read.csv("tractdata_1990_2010tr.csv")
data2000 <- read.csv("tractdata_2000_2010tr.csv")
data2010 <- read.csv("tractdata_2010_2010tr.csv")
data2020 <- read.csv("tractdata_2020_2010tr.csv")


#merge into longitudinal dataset
data <- data2020 %>% 
  left_join(data2010, by = "tr2010gj") %>%
  left_join(data2000, by = "tr2010gj") %>%
  left_join(data1990, by = "tr2010gj") %>%
  left_join(data1980, by = "tr2010gj") %>%
  left_join(data1970, by = "tr2010gj")

data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))


#calculate rates of change
## function for calculating decadal change
decadal_change <- function(data, variables, year1, year2) {
  for (v in variables) {
    v_year1 <- paste0(v, "_", year1)
    v_year2 <- paste0(v, "_", year2)
    v_change <- paste0(v, "_chg_", year1, "to", year2)
    
    if (!all(c(v_year1, v_year2) %in% names(data))) {
      warning(paste("Skipped", v, "because data are missing."))
      next
    }
    
    data[[v_change]] <- as.numeric(data[[v_year2]]) - as.numeric(data[[v_year1]])
  }
  
  return(data)
}

## list of variables
variable_list <- c(
  "Adults_sum", "Asian_pct", "Asian_sum", "Bach_pct", "Bach_sum",
  "Black_pct", "Black_sum", "ConRent_agg", "ConRent_mean", "Elocal",
  "Employed_sum", "HHIncome_agg", "HHIncome_mean", "Hispanic_pct",
  "Hispanic_sum", "Households_sum", "HouseUnits_sum", "HouseValue_agg",
  "HouseValue_mean", "HouseValue_Mortgaged_agg", "HouseValue_Mortgaged_mean",
  "HUOccupied_sum", "HUOwner_pct", "HUOwner_sum", "HURenter_pct",
  "HURenter_sum", "HUVacant_pct", "HUVacant_sum",
  "MovedIn_under10yrs_pct", "MovedIn_under10yrs_sum", "Multi_pct", "Multi_sum",
  "Other_pct", "Other_sum", "Population_sum", "Poverty_pct",
  "Poverty_sum", "White_pct", "White_sum", "WhiteCollar_pct",
  "WhiteCollar_sum")


## calculate
data <- decadal_change(data = data, variables = variable_list, year1 = 1970, year2 = 1980)
data <- decadal_change(data = data, variables = variable_list, year1 = 1980, year2 = 1990)
data <- decadal_change(data = data, variables = variable_list, year1 = 1990, year2 = 2000)
data <- decadal_change(data = data, variables = variable_list, year1 = 2000, year2 = 2010)
data <- decadal_change(data = data, variables = variable_list, year1 = 2010, year2 = 2020)
data <- decadal_change(data = data, variables = variable_list, year1 = 1970, year2 = 2020)



#verify the shape of the data
## Create an empty dataframe
metrics <- data.frame(Variable = character(),
                      Mean = numeric(),
                      Median = numeric(),
                      Minimum = numeric(),
                      Maximum = numeric(),
                      stringsAsFactors = FALSE)

##Loop through each column in the dataframe
for (column in names(data)) {
  
  ####Ensure the column is numeric
  if (is.numeric(data[[column]])) {
    
    #### Calculate descriptives
    mean <- round(mean(data[[column]], na.rm = TRUE), 2) 
    median <- round(median(data[[column]], na.rm = TRUE), 2)
    minimum <- round(min(data[[column]], na.rm = TRUE), 2)
    maximum <- round(max(data[[column]], na.rm = TRUE), 2)
    
    ####Append results
    metrics <- rbind(metrics, data.frame(Variable = column,
                                         Mean = mean,
                                         Median = median,
                                         Minimum = minimum,
                                         Maximum = maximum,
                                         stringsAsFactors = FALSE))
  }
}

##View descriptive stats to verify
metrics <- metrics %>% arrange(Variable)
write.csv(metrics, "metrics.csv", row.names = FALSE)



#final cleanup and save
##archive tabular data
data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))
write.csv(data, file = "tractdata_2010tr.csv", na="", row.names = FALSE)

##save a sample of 'urban' census tracts
boundaries <- read.csv(here("03_spatial/metrotracts_2010tr.csv"))
data <- boundaries %>%
  left_join(data, by = c("GISJOIN" = "tr2010gj")) %>%
  select(-ends_with(".y")) %>% 
  rename_with(~ sub("\\.x$", "", .x), .cols = ends_with(".x")) %>%
  rename(tr2010gj = GISJOIN)

write.csv(data, file = "metrotracts_data_2010tr.csv", na="", row.names = FALSE)

