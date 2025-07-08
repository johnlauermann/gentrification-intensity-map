#This script
## 1) pulls raw data from the NGHIS API, 
## 2) crosswalks the data to 2010 census boundaries
## 3) cleans data and calculates derivative statistics (e.g. percents, means)

#To run this, you will need:
## a National Historical GIS account (https://www.nhgis.org/)
## an IPUMPS API key (https://developer.ipums.org/docs/v2/get-started/)
## crosswalk files from the Brown Longitudinal Tract Database (https://s4.ad.brown.edu/projects/diversity/researcher/LTDB.htm)

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ipumsr)) install.packages("ipumsr")
if (!require(purr)) install.packages("purr")

library(dplyr)
library(here)
library(ipumsr)
library(purr)


#set working directory & general attributes
here::i_am("data_2000to2010tracts.R")
year <- "2000"
inflation <- 1.5477  #based on BLS CPI inflation calculator, https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1%2C000.00&year1=199912&year2=202012

#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "Your key"
set_ipums_api_key(my_key)

#see metadata for relevant parameters
metadata_SF1b <- get_metadata_nhgis(dataset = "2000_SF1b")
metadata_SF3b <- get_metadata_nhgis(dataset = "2000_SF3b")


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_agg(
  collection = "nhgis",
  description = "Gentrification map data, 2000 block group parts & time series (on 2010tr)",
  time_series_tables = list(
    tst_spec("CL8", geog_levels = "tract", years = "2000"),
    tst_spec("CM1", geog_levels = "tract", years = "2000"),
    tst_spec("CP4", geog_levels = "tract", years = "2000"),
    tst_spec("CM4", geog_levels = "tract", years = "2000"),
    tst_spec("CM7", geog_levels = "tract", years = "2000"),
    tst_spec("CM9", geog_levels = "tract", years = "2000"),
    tst_spec("CN1", geog_levels = "tract", years = "2000"),
    tst_spec("CW3", geog_levels = "tract", years = "2000")
  ),
  datasets = ds_spec("2000_SF3b",
                     data_tables = c("NP037A", "NP037C", "NP049A", "NP050B", "NP054A", 
                                     "NP088A", "NH038A", "NH058A", "NH078A", "NH081A"),
                     geog_levels = "blck_grp_090"),
  geographic_extents = "*"
)

##submit to the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)   
filepath <- download_extract(extract)


#for data from time series tables, on 2010 tract boundaries
##define variables
variables_ts <- c(
  Age_2529_sum = "CW3AI2000",
  Age_3034_sum = "CW3AJ2000",
  Age_3539_sum = "CW3AK2000",
  Age_4044_sum = "CW3AL2000",
  Age_4549_sum = "CW3AM2000",
  Age_5054_sum = "CW3AN2000",
  Age_5559_sum = "CW3AO2000",
  Age_6061_sum = "CW3AP2000",
  Age_6264_sum = "CW3AQ2000",
  Age_6569_sum = "CW3AR2000",
  Age_7074_sum = "CW3AS2000",
  Age_7579_sum = "CW3AT2000",
  Age_8084_sum = "CW3AU2000",
  Age_over85_sum = "CW3AV2000",
  Asian_sum = "CM1AD2000",
  Black_sum = "CM1AB2000",
  Hispanic_sum = "CP4AB2000",
  Households_sum = "CM4AA2000",
  HouseUnits_sum = "CM7AA2000",
  HUOccupied_sum = "CM9AA2000",
  HUOwner_sum = "CN1AA2000",
  HURenter_sum = "CN1AB2000",
  HUVacant_sum = "CM9AB2000",
  Multi_sum = "CM1AG2000",
  Other_sum = "CM1AF2000",
  Population_sum = "CL8AA2000",
  White_sum = "CM1AA2000"
)

##load data, filtering to reduce memory load
data_ts <- read_nhgis(filepath, file_select = 2) %>%
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
  "Multi_sum",
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
variables_bgp <- c(
  ConRent_agg = "G76001",
  Ed_BachF_sum = "HD1029",
  Ed_DoctorateF_sum = "HD1032",
  Ed_MastersF_sum = "HD1030",
  Ed_ProfDegreeF_sum = "HD1031",
  Ed_BachM_sum = "HD1013",
  Ed_DoctorateM_sum = "HD1016",
  Ed_MastersM_sum = "HD1014",
  Ed_ProfDegreeM_sum = "HD1015",
  Employed_sum = "HFN001",
  HHIncome_agg = "HF7001",
  HouseValue_agg = "G8X001",
  HouseValue_Mortgaged_agg = "G84001",
  Owner_MovedIn_2to5yrs_sum = "G7C002",
  Owner_MovedIn_5to10yrs_sum= "G7C003",
  Owner_MovedIn_under1yr_sum = "G7C001",
  Renter_MovedIn_2to5yrs_sum = "G7C008",
  Renter_MovedIn_5to10yrs_sum = "G7C009",
  Renter_MovedIn_under1yr_sum = "G7C007",
  Occ_MBF_F_sum = "HFS014",
  Occ_MBF_M_sum = "HFS001",
  Occ_MP_F_sum = "HFS015",
  Occ_MP_M_sum = "HFS002",
  Pov_50to74_sum2020 = "HHG002",
  Pov_75to99_sum2020 = "HHG003",
  Pov_under50_sum = "HHG001"
)

##load data, filter to reduce memory load
data_bgp <- read_nhgis(filepath, file_select = 1)%>%
  select(GISJOIN, all_of(variables_bgp)) 
data_bgp <- data_bgp %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##crosswalk the data to tract boundaries
###load crosswalk from IPUMS API
url <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_bgp2000_tr2010.zip"
download.file(url, "nhgis_bgp2000_tr2010.zip", headers = c(Authorization = my_key))

###crosswalk and merge
crosswalks <- read_nhgis("nhgis_bgp2000_tr2010.zip")
data_bgp <- data_bgp %>% rename(bgp2000gj = GISJOIN)
data_bgp <- left_join(crosswalks, data_bgp, by = "bgp2000gj")
rm(crosswalks)

###weight blocks to tracts
data_bgp <- within(data_bgp, {
  Ed_BachF_sum <- Ed_BachF_sum * wt_adult
  Ed_MastersF_sum <- Ed_MastersF_sum * wt_adult
  Ed_ProfDegreeF_sum <- Ed_ProfDegreeF_sum * wt_adult
  Ed_DoctorateF_sum <- Ed_DoctorateF_sum * wt_adult
  Ed_BachM_sum <- Ed_BachM_sum * wt_adult
  Ed_MastersM_sum <- Ed_MastersM_sum * wt_adult
  Ed_ProfDegreeM_sum <- Ed_ProfDegreeM_sum * wt_adult
  Ed_DoctorateM_sum <- Ed_DoctorateM_sum * wt_adult
  ConRent_agg <- ConRent_agg * wt_renthu
  Employed_sum <- Employed_sum * wt_pop
  HHIncome_agg <- HHIncome_agg * wt_hh
  HouseValue_agg <- HouseValue_agg * wt_ownhu
  HouseValue_Mortgaged_agg <- HouseValue_Mortgaged_agg * wt_ownhu
  Owner_MovedIn_2to5yrs_sum <- Owner_MovedIn_2to5yrs_sum * wt_ownhu
  Owner_MovedIn_5to10yrs_sum <- Owner_MovedIn_5to10yrs_sum * wt_ownhu
  Owner_MovedIn_under1yr_sum <- Owner_MovedIn_under1yr_sum * wt_ownhu
  Renter_MovedIn_2to5yrs_sum <- Renter_MovedIn_2to5yrs_sum * wt_renthu
  Renter_MovedIn_5to10yrs_sum <- Renter_MovedIn_5to10yrs_sum * wt_renthu
  Renter_MovedIn_under1yr_sum <- Renter_MovedIn_under1yr_sum * wt_renthu
  Occ_MBF_F_sum <- Occ_MBF_F_sum * wt_pop
  Occ_MBF_M_sum <- Occ_MBF_M_sum * wt_pop
  Occ_MP_F_sum <- Occ_MP_F_sum * wt_pop
  Occ_MP_M_sum <- Occ_MP_M_sum * wt_pop
  Pov_under50_sum <- Pov_under50_sum * wt_pop
  Pov_50to74_sum2020 <- Pov_50to74_sum2020 * wt_pop
  Pov_75to99_sum2020 <- Pov_75to99_sum2020 * wt_pop
})

###calculate additional categories from components
data_bgp <- within(data_bgp, {
  Bach_sum <- Ed_BachF_sum + Ed_MastersF_sum + Ed_ProfDegreeF_sum +
    Ed_DoctorateF_sum + Ed_BachM_sum + Ed_MastersM_sum + 
    Ed_ProfDegreeM_sum + Ed_DoctorateM_sum
  MovedIn_under10yrs_sum <- Owner_MovedIn_under1yr_sum + Owner_MovedIn_2to5yrs_sum +
    Owner_MovedIn_5to10yrs_sum + Renter_MovedIn_under1yr_sum + 
    Renter_MovedIn_2to5yrs_sum + Renter_MovedIn_5to10yrs_sum
  Poverty_sum <- Pov_under50_sum + Pov_50to74_sum2020 + Pov_75to99_sum2020
  WhiteCollar_sum <- Occ_MBF_F_sum + Occ_MBF_M_sum +
    Occ_MP_F_sum + Occ_MP_M_sum
})


###define final variable selections
variable_names_bgp <- c(
  "ConRent_agg",
  "Bach_sum",
  "Employed_sum",
  "HHIncome_agg",
  "HouseValue_agg",
  "HouseValue_Mortgaged_agg",
  "MovedIn_under10yrs_sum",
  "Poverty_sum",
  "WhiteCollar_sum"
)

###summarize by block group
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