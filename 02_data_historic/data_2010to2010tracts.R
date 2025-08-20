#This script
## 1) pulls raw data from the NGHIS API, 
## 2) crosswalks the data to modern census boundaries
## 3) cleans data and calculates derivative statistics (e.g. percents, means)

#To run this, you will need:
## a National Historical GIS account (https://www.nhgis.org/)
## an IPUMPS API key (https://developer.ipums.org/docs/v2/get-started/)
## crosswalk files from the Brown Longitudinal Tract Database (https://s4.ad.brown.edu/projects/diversity/researcher/LTDB.htm)

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ipumsr)) install.packages("ipumsr")
if (!require(purrr)) install.packages("purrr")

library(dplyr)
library(here)
library(ipumsr)
library(purrr)


#set working directory & general attributes
here::i_am("data_2010to2010tracts.R")
year <- "2010"
inflation <- 1.1884  #based on BLS CPI inflation calculator, https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1%2C000.00&year1=201012&year2=202012

#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "your key here"
set_ipums_api_key(my_key)

#see metadata for relevant parameters
metadata <- get_metadata_nhgis(dataset = "2006_2010_ACS5a")


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_nhgis(
  description = "Gentrification map data, 2010 tracts",
  datasets = ds_spec("2006_2010_ACS5a", 
                     data_tables = c("B01003", "B02001", "B03003", "B11001", 
                                     "B15002", "B19025","B25001", "B25002", 
                                     "B25003", "B25060", "B25082", "B25038",
                                     "C17002", "C24010"),
                     geog_levels = c( "tract")
                     )
  )

##submit to the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)
filepath <- download_extract(extract)


#load, sort, and clean data
##define variables
variables <- c(
  Adults_sum = "JN9E001",
  Asian_sum = "JMBE005",
  Black_sum = "JMBE003",
  ConRent_agg = "JS1E001",
  Ed_BachF_sum = "JN9E032",
  Ed_DoctorateF_sum = "JN9E035",
  Ed_MastersF_sum = "JN9E033",
  Ed_ProfDegreeF_sum = "JN9E034",
  Ed_BachM_sum = "JN9E015",
  Ed_DoctorateM_sum = "JN9E018",
  Ed_MastersM_sum = "JN9E016",
  Ed_ProfDegreeM_sum = "JN9E017",
  Employed_sum = "JQ5E001",
  HHIncome_agg = "JOSE001",
  Hispanic_sum = "JMKE003",
  Households_sum = "JM5E001",
  HouseUnits_sum = "JRIE001",
  HouseValue_agg = "JTNE001",
  HouseValue_Mortgaged_agg = "JTNE002",
  HUOccupied_sum = "JRJE002",
  HUOwner_sum = "JRKE002",
  HURenter_sum = "JRKE003",
  HUVacant_sum = "JRJE003",
  Owner_MovedIn_under5yrs_sum = "JSHE003",
  Owner_MovedIn_5to10yrs_sum= "JSHE004",
  Renter_MovedIn_under5yrs_sum = "JSHE010",
  Renter_MovedIn_5to10yrs_sum = "JSHE011",
  Multi_sum = "JMBE009",
  Occ_MBSA_F_sum = "JQ5E039",
  Occ_MBSA_M_sum = "JQ5E003",
  Other_sum = "JMBE007",
  Population_sum = "JMAE001",
  Pov_50to99_sum2020 = "JOCE002",
  Pov_under50_sum = "JOCE003",
  White_sum = "JMBE002"
)

##query and load data
data <- read_nhgis(filepath) %>%
  select(GISJOIN, all_of(variables)) 
data <- data %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##calculate additional categories from components
data <- within(data, {
  Bach_sum <- Ed_BachF_sum + Ed_MastersF_sum + Ed_ProfDegreeF_sum +
    Ed_DoctorateF_sum + Ed_BachM_sum + Ed_MastersM_sum + 
    Ed_ProfDegreeM_sum + Ed_DoctorateM_sum
  MovedIn_under10yrs_sum <- Owner_MovedIn_under5yrs_sum + Owner_MovedIn_5to10yrs_sum + 
    Renter_MovedIn_under5yrs_sum + Renter_MovedIn_5to10yrs_sum
  Poverty_sum <- Pov_under50_sum + Pov_50to99_sum2020
  WhiteCollar_sum <- Occ_MBSA_F_sum + Occ_MBSA_M_sum
})

##define final variable selections
variable_names <- c(
  "Adults_sum",
  "Asian_sum",
  "Bach_sum",
  "Black_sum",
  "ConRent_agg",
  "Employed_sum",
  "HHIncome_agg",
  "Hispanic_sum",
  "Households_sum",
  "HouseUnits_sum",
  "HouseValue_agg",
  "HouseValue_Mortgaged_agg",
  "HUOccupied_sum",
  "HUOwner_sum",
  "HURenter_sum",
  "HUVacant_sum",
  "MovedIn_under10yrs_sum",
  "Multi_sum",
  "Other_sum",
  "Population_sum",
  "Poverty_sum",
  "White_sum", 
  "WhiteCollar_sum"
)

##query and sort data
data <- data %>% select(all_of(c("GISJOIN", variable_names)))
data <- data %>% rename(tr2010gj = GISJOIN)


#calculate derivative metrics
## Define functions to exclude incorrect data and low-population tracts
divide_pop <- Vectorize(function(numerator, denominator) {
  if (!is.na(numerator) && !is.na(denominator) && numerator < denominator && denominator >= 100) {
    return(numerator / denominator)
  } else {
    return(NA)
  }
})

divide_units <- Vectorize(function(numerator, denominator) {
  if (!is.na(numerator) && !is.na(denominator) && numerator < denominator && denominator >= 10) {
    return(as.numeric(numerator) / as.numeric(denominator))
  } else {
    return(NA)
  }
})

divide_value <- Vectorize(function(numerator, denominator) {
  if (!is.na(numerator) && !is.na(denominator) && denominator >= 10) {
    return(as.numeric(numerator) / as.numeric(denominator))
  } else {
    return(NA)
  }
})

##apply functions
data <- within(data, {
  ## Socioeconomic variables
  Bach_pct <- divide_pop(Bach_sum, Adults_sum) * 100
  ConRent_mean <- divide_value(as.numeric(ConRent_agg), HURenter_sum) * inflation
  HHIncome_mean <- divide_value(HHIncome_agg, Households_sum) * inflation
  HouseValue_mean <- divide_value(HouseValue_agg, HUOwner_sum) * inflation
  HouseValue_Mortgaged_mean <- divide_value(HouseValue_Mortgaged_agg, HUOwner_sum) * inflation
  HUOwner_pct <- divide_units(HUOwner_sum, HouseUnits_sum) * 100
  HURenter_pct <- divide_units(HURenter_sum, HouseUnits_sum) * 100
  HUVacant_pct <- divide_units(HUVacant_sum, HouseUnits_sum) * 100
  MovedIn_under10yrs_pct <- divide_units(MovedIn_under10yrs_sum, HUOccupied_sum) * 100
  Poverty_pct <- divide_pop(Poverty_sum, Population_sum) * 100
  WhiteCollar_pct <- divide_pop(WhiteCollar_sum, Employed_sum) * 100
  
   ## Racial/ethnic variables
  Asian_pct <- divide_pop(Asian_sum, Population_sum) * 100 
  Black_pct <- divide_pop(Black_sum, Population_sum) * 100 
  Hispanic_pct <- divide_pop(Hispanic_sum, Population_sum) * 100 
  Multi_pct <- divide_pop(Multi_sum, Population_sum) * 100 
  Other_pct <- divide_pop(Other_sum, Population_sum) * 100 
  White_pct <- divide_pop(White_sum, Population_sum) * 100 
})

## Residential diversity variables
data$Elocal <- ifelse((data$Population_sum >= 100),
                      ((data$White_sum /  data$Population_sum) * log(1 / (data$White_sum / data$Population_sum)) +
                         (data$Black_sum / data$Population_sum) * log(1 / (data$Black_sum / data$Population_sum)) +
                         (data$Asian_sum / data$Population_sum) * log(1 / (data$Asian_sum / data$Population_sum)) +
                         (data$Other_sum / data$Population_sum) * log(1 / (data$Other_sum / data$Population_sum))),
                      NA)


#final cleanup and save
##query and sort data
data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))

##name processed data
data <- data %>%
  rename_with(
    ~ifelse(. == "tr2010gj", ., paste0(., "_", year)),
    .cols = everything()
  )

##archive original data
file.rename(filepath, paste0("nhgis_", year, "_tracts.zip" ))

##save cleaned data
filename <- paste0("tractdata_", year, "_2010tr.csv")
write.csv(data, file = filename, na="", row.names = FALSE)
