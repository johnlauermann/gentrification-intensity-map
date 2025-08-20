#This script
## 1) pulls raw data from the NGHIS API, 
## 2) crosswalks the data to modern census boundaries
## 3) cleans data and calculates derivative statistics (e.g. percents, means)

#To run this, you will need:
## a National Historical GIS account (https://www.nhgis.org/)
## an IPUMPS API key (https://developer.ipums.org/docs/v2/get-started/)

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ipumsr)) install.packages("ipumsr")
if (!require(purrr)) install.packages("purrr")

library(dplyr)
library(here)
library(ipumsr)
library(purrr)

#set working directory & general attributes
here::i_am("data_1990to2010tracts.R")
year <- "1990"
inflation <- 2.0656 #based on BLS CPI inflation calculator: https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1%2C000.00&year1=198912&year2=202012

#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "59cba10d8a5da536fc06b59dd3b53dbff7f4442fac9f4480a5c34118"
set_ipums_api_key(my_key)

#see metadata for relevant parameters
metadata_SF1 <- get_metadata_nhgis(dataset = "1990_STF1")
metadata_SF3 <- get_metadata_nhgis(dataset = "1990_STF3")
metadata_ts <- get_metadata_nhgis("time_series_tables")


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_nhgis(
  description = "Gentrification map data, block group parts & 1990 time series (on 2010tr)",
  time_series_tables = list(
    tst_spec("CL8", geog_levels = "tract", years = "1990"),
    tst_spec("CM1", geog_levels = "tract", years = "1990"),
    tst_spec("CP4", geog_levels = "tract", years = "1990"),
    tst_spec("CM4", geog_levels = "tract", years = "1990"),
    tst_spec("CM7", geog_levels = "tract", years = "1990"),
    tst_spec("CM9", geog_levels = "tract", years = "1990"),
    tst_spec("CN1", geog_levels = "tract", years = "1990"),
    tst_spec("CW3", geog_levels = "tract", years = "1990")
  ),
  datasets = list(
    ds_spec("1990_STF1", 
            data_tables = c("NH24", "NH33"),
            geog_levels = "blck_grp_598_101"),
    ds_spec("1990_STF3", 
            data_tables = c("NP57", "NP70", "NP78", "NP81", "NP121", "NH29", "NH62", "NH33", "NH24"),
            geog_levels = "blck_grp_598_101")
  ),
  geographic_extents = "*"
)

##submit to the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)   
filepath <- download_extract(extract)


#for data from time series tables, on 2010 block group boundaries
##define variables
variables_ts <- c(
  Age_2529_sum = "CW3AI1990",
  Age_3034_sum = "CW3AJ1990",
  Age_3539_sum = "CW3AK1990",
  Age_4044_sum = "CW3AL1990",
  Age_4549_sum = "CW3AM1990",
  Age_5054_sum = "CW3AN1990",
  Age_5559_sum = "CW3AO1990",
  Age_6061_sum = "CW3AP1990",
  Age_6264_sum = "CW3AQ1990",
  Age_6569_sum = "CW3AR1990",
  Age_7074_sum = "CW3AS1990",
  Age_7579_sum = "CW3AT1990",
  Age_8084_sum = "CW3AU1990",
  Age_over85_sum = "CW3AV1990",
  Asian_sum = "CM1AD1990",
  Black_sum = "CM1AB1990",
  Hispanic_sum = "CP4AB1990",
  Households_sum = "CM4AA1990",
  HouseUnits_sum = "CM7AA1990",
  HUOccupied_sum = "CM9AA1990",
  HUOwner_sum = "CN1AA1990",
  HURenter_sum = "CN1AB1990",
  HUVacant_sum = "CM9AB1990",
  Other_sum = "CM1AF1990",
  Population_sum = "CL8AA1990",
  White_sum = "CM1AA1990"
)

##load data, filtering to reduce memory load
data_ts <- read_nhgis(filepath, file_select = 3) %>%
  select(GISJOIN, all_of(variables_ts)) 
data_ts <- data_ts %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##calculate additional categories from components
data_ts <- within(data_ts, {
  Adults_sum <- Age_2529_sum + Age_3034_sum + Age_3539_sum + Age_4044_sum + 
    Age_4549_sum + Age_5054_sum + Age_5559_sum + Age_6061_sum + Age_6264_sum + 
    Age_6569_sum + Age_7074_sum + Age_7579_sum + Age_8084_sum + Age_over85_sum})

##define final variable selections
variable_names_ts <- c(
  "Adults_sum",
  "Asian_sum",
  "Black_sum",
  "Hispanic_sum",
  "Households_sum",
  "HouseUnits_sum",
  "HUOccupied_sum",
  "HUOwner_sum",
  "HURenter_sum",
  "HUVacant_sum",
  "Other_sum",
  "Population_sum",
  "White_sum"
)

##sort and clean
data_ts <- data_ts %>% 
  select(GISJOIN, all_of(variable_names_ts)) %>% 
  rename(tr2010gj = GISJOIN)


#for data from long form questionnaire, available at block group partition level
##define variables
variables_bgp_STF1 <- c(
  ConRent_agg = "ES8001",
  HouseValue_agg = "ESV001"
)

variables_bgp_STF3 <- c(
  Ed_Bach_sum = "E33006",
  Ed_Graduate_sum = "E33007",
  Employed_F_sum = "E4I006",
  Employed_M_sum = "E4I002",
  HHIncome_under150k_agg = "E4V001",
  HHIncome_over150k_agg = "E4V002",
  HouseValue_Mortgaged_agg = "EZJ001",
  Owner_MovedIn_2to5yrs_sum = "EYC002",
  Owner_MovedIn_5to10yrs_sum= "EYC003",
  Owner_MovedIn_under1yr_sum = "EYC001",
  Renter_MovedIn_2to5yrs_sum = "EYC008",
  Renter_MovedIn_5to10yrs_sum = "EYC009",
  Renter_MovedIn_under1yr_sum = "EYC007",
  Occ_EAM_sum = "E4Q001",
  Occ_MP_sum = "E4Q002",
  Pov_50to74_sum2020 = "E1C002",
  Pov_75to99_sum2020 = "E1C003",
  Pov_under50_sum = "E1C001"
)

##load data, filtering to reduce memory load
data_bgp_STF1 <- read_nhgis(filepath, file_select = 1) %>%
  select(GISJOIN, all_of(variables_bgp_STF1)) 
data_bgp_STF3 <- read_nhgis(filepath, file_select = 2) %>%
  select(GISJOIN, all_of(variables_bgp_STF3))
data_bgp <- left_join(data_bgp_STF1, data_bgp_STF3, by = "GISJOIN")
data_bgp <- data_bgp %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##crosswalk the data to new tract boundaries
####load crosswalk from IPUMS API
url_bgp <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_bgp1990_tr2010.zip"
download.file(url_bgp, "nhgis_bgp1990_tr2010.zip", headers = c(Authorization = my_key))

###crosswalk and merge
crosswalks_bgp <- read_nhgis("nhgis_bgp1990_tr2010.zip")
data_bgp <- data_bgp %>% rename(bgp1990gj = GISJOIN)
data_bgp <- left_join(crosswalks_bgp, data_bgp, by = "bgp1990gj")
rm(crosswalks_bgp)

###weight blocks 
data_bgp <- within(data_bgp, {
  ConRent_agg <- ConRent_agg * wt_renthu
  Ed_Bach_sum <- Ed_Bach_sum * wt_adult
  Ed_Graduate_sum <- Ed_Graduate_sum * wt_adult
  Employed_F_sum <- Employed_F_sum * wt_pop
  Employed_M_sum <- Employed_M_sum * wt_pop
  HHIncome_under150k_agg <- HHIncome_under150k_agg * wt_hh
  HHIncome_over150k_agg <- HHIncome_over150k_agg * wt_hh
  HouseValue_agg <- HouseValue_agg * wt_ownhu
  HouseValue_Mortgaged_agg <- as.numeric(HouseValue_Mortgaged_agg) * wt_ownhu
  Owner_MovedIn_under1yr_sum <- Owner_MovedIn_under1yr_sum * wt_ownhu
  Owner_MovedIn_2to5yrs_sum <- Owner_MovedIn_2to5yrs_sum * wt_ownhu
  Owner_MovedIn_5to10yrs_sum <- Owner_MovedIn_5to10yrs_sum * wt_ownhu
  Renter_MovedIn_under1yr_sum <- Renter_MovedIn_under1yr_sum * wt_renthu
  Renter_MovedIn_2to5yrs_sum <- Renter_MovedIn_2to5yrs_sum * wt_renthu
  Renter_MovedIn_5to10yrs_sum <- Renter_MovedIn_5to10yrs_sum * wt_renthu
  Occ_EAM_sum <- Occ_EAM_sum * wt_pop
  Occ_MP_sum <- Occ_MP_sum * wt_pop
  Pov_under50_sum <- Pov_under50_sum * wt_pop
  Pov_50to74_sum2020 <- Pov_50to74_sum2020 * wt_pop
  Pov_75to99_sum2020 <- Pov_75to99_sum2020 * wt_pop
})


##calculate additional categories from components
data_bgp <- within(data_bgp, {
  Bach_sum <- Ed_Bach_sum + Ed_Graduate_sum
  Employed_sum <- Employed_F_sum + Employed_M_sum
  HHIncome_agg <- HHIncome_under150k_agg + HHIncome_over150k_agg
  MovedIn_under10yrs_sum <- Owner_MovedIn_under1yr_sum + Owner_MovedIn_2to5yrs_sum +
    Owner_MovedIn_5to10yrs_sum + Renter_MovedIn_under1yr_sum +
    Renter_MovedIn_2to5yrs_sum + Renter_MovedIn_5to10yrs_sum
  Poverty_sum <- Pov_under50_sum + Pov_50to74_sum2020 + Pov_75to99_sum2020
  WhiteCollar_sum <- Occ_EAM_sum + Occ_MP_sum
})


##define final variable selections
variable_names_bgp <- c(
  "Bach_sum",
  "ConRent_agg",
  "Employed_sum",
  "HHIncome_agg",
  "HouseValue_agg",
  "HouseValue_Mortgaged_agg",
  "MovedIn_under10yrs_sum",
  "Poverty_sum",
  "WhiteCollar_sum"
)

##summarize by block group
data_bgp <- data_bgp %>% 
  group_by(tr2010gj) %>%
  summarize(across(all_of(variable_names_bgp), sum))


#compile the entire dataset
##merge block and block group partition data
data <- left_join(data_bgp, data_ts, by = "tr2010gj")
data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))


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
##sort data
data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))

##name processed data
data <- data %>%
  rename_with(
    ~ifelse(. == "tr2010gj", ., paste0(., "_", year)),
    .cols = everything()
  )

##archive original data
file.rename(filepath, paste0("nhgis_", year, ".zip" ))

##save cleaned data
filename <- paste0("tractdata_", year, "_2010tr.csv")
write.csv(data, file = filename, na="", row.names = FALSE)