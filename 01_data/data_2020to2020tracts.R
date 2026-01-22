#This script
## 1)pulls raw data from the NGHIS API, 
## 2) crosswalks the data to modern census boundaries
## 3) cleans data and calculates derivative statistics (e.g. percents, means)

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ipumsr)) install.packages("ipumsr")
if (!require(purrr)) install.packages("purrr")

library(dplyr)
library(here)
library(ipumsr)
library(purrr)


#set working directory & general attributes
here::i_am("01_data/data_2020to2020tracts.R")
year <- "2020"
inflation <- 1

#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "your key here"
set_ipums_api_key(my_key)

#see metadata for relevant parameters
metadata <- get_metadata_nhgis(dataset = "2016_2020_ACS5a")


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_agg(
  collection = "nhgis",
  description = "Gentrification map data, 2020 tracts",
  datasets = ds_spec("2016_2020_ACS5a",
                     data_tables = c("B01003", "B02001", "B03003", "B11001", 
                                     "B15003", "C17002","B19025", "C24010", 
                                     "B25001", "B25002", "B25003", "B25038",
                                     "B25060", "B25082"),
                     geog_levels = "tract"
                     )
  )

##submit the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)   
filepath <- download_extract(extract)

#load, sort, and clean data
##define variables
variables <- c(
  Adults_sum = "AMRZE001",
  Asian_sum = "AMPWE005",
  Black_sum = "AMPWE003",
  ConRent_agg = "AMVVE001",
  Ed_Bach_sum = "AMRZE022",
  Ed_Doctorate_sum = "AMRZE025",
  Ed_Masters_sum = "AMRZE023",
  Ed_ProfDegree_sum = "AMRZE024",
  Employed_sum = "AMZOE001",
  HHIncome_agg = "AMR9E001",
  Hispanic_sum = "AMP4E003",
  Households_sum = "AMQSE001",
  HouseUnits_sum = "AMUDE001",
  HouseValue_agg = "AMWGE001",
  HouseValue_Mortgaged_agg = "AMWGE002",
  HUOccupied_sum = "AMUEE002",
  HUOwner_sum = "AMUFE002",
  HURenter_sum = "AMUFE003",
  HUVacant_sum = "AMUEE003",
  Owner_MovedIn_2to5yrs_sum = "AMVBE004",
  Owner_MovedIn_5to10yrs_sum= "AMVBE005",
  Owner_MovedIn_under1yr_sum = "AMVBE003",
  Renter_MovedIn_2to5yrs_sum = "AMVBE011",
  Renter_MovedIn_5to10yrs_sum = "AMVBE012",
  Renter_MovedIn_under1yr_sum = "AMVBE010",
  Multi_sum = "AMPWE009",
  Occ_MBSA_F_sum = "AMZOE039",
  Occ_MBSA_M_sum = "AMZOE003",
  Other_sum = "AMPWE007",
  Population_sum = "AMPVE001",
  Pov_50to99_sum2020 = "AMZME003",
  Pov_under50_sum = "AMZME002",
  White_sum = "AMPWE002"
)

##query and load data into dataframe
data <- read_nhgis(filepath) %>%
  select(GISJOIN, all_of(variables)) 
data <- data %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##calculate additional categories from components
data <- within(data, {
  Bach_sum <- Ed_Bach_sum + Ed_Masters_sum + Ed_ProfDegree_sum + Ed_Doctorate_sum
  MovedIn_under10yrs_sum <- Owner_MovedIn_under1yr_sum + Owner_MovedIn_2to5yrs_sum + 
    Owner_MovedIn_5to10yrs_sum + Renter_MovedIn_under1yr_sum + 
    Renter_MovedIn_2to5yrs_sum + Renter_MovedIn_5to10yrs_sum
  Poverty_sum <- Pov_under50_sum + Pov_50to99_sum2020
  WhiteCollar_sum <- Occ_MBSA_F_sum + Occ_MBSA_M_sum
})


# Calculate derivative metrics at the tract scale
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
  ConRent_mean <- divide_value(ConRent_agg, HURenter_sum) * inflation
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
##name final variable selections
variable_names <- c(
  "Adults",
  "Asian",
  "Bach",
  "Black",
  "ConRent",
  "Elocal",
  "Employed",
  "HHIncome",
  "Hispanic",
  "Households",
  "HouseUnits",
  "HouseValue",
  "HouseValue_Mortgaged",
  "HUOccupied",
  "HUOwner",
  "HURenter",
  "HUVacant",
  "MovedIn_under10yrs",
  "Multi",
  "Other",
  "Population",
  "Poverty",
  "White", 
  "WhiteCollar"
)

##query and sort data
data <- data %>% rename(tr2020gj = GISJOIN)
data <- data %>% select(tr2020gj, starts_with(variable_names))
data <- data %>% select(tr2020gj, sort(setdiff(names(.), "tr2020gj")))

##name processed data
data <- data %>%
  rename_with(
    ~ifelse(. == "tr2020gj", ., paste0(., "_", year)),
    .cols = everything()
  )

##archive original data
file.rename(filepath, paste0("nhgis_", year, "_tracts.zip" ))

##save cleaned data
filename <- paste0("tractdata_", year, "_2020tr.csv")
write.csv(data, file = filename, na="", row.names = FALSE)

