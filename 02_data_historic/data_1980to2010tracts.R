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

library(dplyr)
library(here)
library(ipumsr)


#set working directory & general attributes
here::i_am("data_1980to2010tracts.R")
year <- "1980"
inflation <- 3.39601  #based on BLS CPI calculator: https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1000&year1=197912&year2=202012 


#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "your key here"
set_ipums_api_key(my_key)


#view metadata for Census products
metadata_Cnt3 <- get_metadata_nhgis(dataset = "1980_STF1")
metadata_Cnt4H <- get_metadata_nhgis(dataset = "1980_STF3")
metadata_ts <- get_metadata_nhgis(time_series_table = "A35")  ## etc...


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_nhgis(
  description = "Gentrification map data, 1980 tracts & 1980 time series",
  datasets = list(
    ds_spec("1980_STF1", data_tables = c("NT45"), geog_levels = "tract"),
    ds_spec("1980_STF3", data_tables = c("NT55A", "NT66", "NT70", "NT91A", "NT110A", "NT137", "NT140"), geog_levels = "tract")
    ), 
    time_series_tables = list(
      tst_spec("A35", geog_levels = "tract", years = "1980"),
      tst_spec("A41", geog_levels = "tract", years = "1980"),
      tst_spec("A43", geog_levels = "tract", years = "1980"),
      tst_spec("AR5", geog_levels = "tract", years = "1980"),
      tst_spec("AV0", geog_levels = "tract", years = "1980"),
      tst_spec("B08", geog_levels = "tract", years = "1980"),
      tst_spec("B69", geog_levels = "tract", years = "1980"),
      tst_spec("B37", geog_levels = "tract", years = "1980")
    )
)

##submit to the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)   
filepath <- download_extract(extract)


#sort & clean data
##define variables
variables <- c(
  Asian_Chinese_sum = "B08AE1980",
  Asian_Filipino_sum = "B08AF1980",
  Asian_Korean_sum = "B08AG1980",
  Asian_Japanese_sum = "B08AD1980",
  Black_sum = "B08AB1980",
  ConRent_agg = "C8P001",
  Ed_under9thGrade_sum = "B69AA1980",
  Ed_9thtoSomeCollege_sum = "B69AB1980",
  Bach_sum = "B69AC1980",
  Employed_F_sum = "DHX006",
  Employed_M_sum = "DHX002",
  HHIncome_agg = "DIG001",
  Hispanic_sum = "A35AA1980",
  Households_sum = "AR5AA1980",
  HouseUnits_sum = "A41AA1980",
  HouseValue_agg = "DFY001",
  HouseValue_Mortgaged_agg_7580 = "DFV001",
  HouseValue_Mortgaged_agg_7074 = "DFV002",
  HouseValue_Mortgaged_agg_6069 = "DFV003",
  HouseValue_Mortgaged_agg_before59 = "DFV004",
  HUOccupied_sum = "A43AA1980",
  HU_MovedIn_under1yr_sum = "DET001",
  HU_MovedIn_2to5yrs_sum = "DET002",
  HU_MovedIn_5to10yrs_sum= "DET003",
  HUOwner_sum = "B37AA1980",
  HURenter_sum = "B37AB1980",
  HUVacant_sum = "A43AB1980",
  Occ_EAM_sum = "DIB001",
  Occ_MP_sum = "DIB002",
  Other_sum = "B08AI1980",
  Population_sum = "AV0AA1980",
  Poverty_sum = "DI8002",
  White_sum = "B08AA1980"
)

##read each table into a dataframe
ts <- read_nhgis(filepath, file_select = 3) %>%
  select(GJOIN1980,STATEFP, COUNTYFP, TRACTA, any_of(variables)) %>%
  mutate_all(~ ifelse(. <0, NA, .))
STF1 <- read_nhgis(filepath, file_select = 1) %>%
  select(GISJOIN, any_of(variables)) 
STF3 <- read_nhgis(filepath, file_select = 2) %>%
  select(GISJOIN, any_of(variables)) 


##merge tables together
ts <- ts %>% rename(GISJOIN = GJOIN1980)
data <- ts %>% 
  left_join(STF1, by = "GISJOIN") %>%
  left_join(STF3, by = "GISJOIN")

##calculate additional variables
data <- within(data, {
  Adults_sum <- Ed_under9thGrade_sum + Ed_9thtoSomeCollege_sum + Bach_sum
  Asian_sum <- Asian_Chinese_sum + Asian_Filipino_sum + Asian_Japanese_sum + Asian_Korean_sum
  Employed_sum <- Employed_F_sum + Employed_M_sum
  MovedIn_under10yrs_sum <- HU_MovedIn_under1yr_sum + HU_MovedIn_2to5yrs_sum +HU_MovedIn_5to10yrs_sum
  HouseValue_Mortgaged_agg <- HouseValue_Mortgaged_agg_before59 + HouseValue_Mortgaged_agg_6069 + 
    HouseValue_Mortgaged_agg_7074 + HouseValue_Mortgaged_agg_7580
  WhiteCollar_sum <- Occ_EAM_sum + Occ_MP_sum
})

##name final variable types
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
  "Other_sum",
  "Population_sum",
  "Poverty_sum",
  "White_sum", 
  "WhiteCollar_sum"
)

##query and sort again
data <- data %>% select(GISJOIN, STATEFP, COUNTYFP, TRACTA, all_of(variable_names))
data <- data %>% select(GISJOIN,  STATEFP, COUNTYFP, TRACTA,sort(setdiff(names(.), "GISJOIN")))
data <- data %>% rename(tr1980gj = GISJOIN)


#crosswalk and merge
##load LTDB crosswalk file (request these from Brown LTDB: https://s4.ad.brown.edu/projects/diversity/researcher/ltdb.htm )
crosswalks <- read.csv("crosswalks_ltdb/crosswalk_1980_2010.csv")

#create a GEOID in NHGIS data that matches LTDB data format
data$GEOID80 <- paste0(data$STATEFP, data$COUNTYFP, data$TRACTA)

##fix formatting problems in LTDB data
crosswalks$GEOID80 <- ifelse(nchar(as.character(crosswalks$trtid80)) == 10,
                             paste0("0", crosswalks$trtid80),
                             as.character(crosswalks$trtid80))
crosswalks$GEOID10 <- ifelse(nchar(as.character(crosswalks$trtid10)) == 10,
                             paste0("0", crosswalks$trtid10),
                             as.character(crosswalks$trtid10))

##join by new GEOID
data <- left_join(crosswalks, data, by = "GEOID80")
rm(crosswalks)

##weight tract data
data <- data %>%
  mutate(across(
    .cols = all_of(variable_names),  
    .fns = ~ . * weight
  ))

##summarize by tract
data <- data %>% 
  group_by(GEOID10) %>%
  summarize(across(all_of(variable_names), sum))   

##add NHGIS GISJOIN identifiers (csv is the attribute table from 2010 NGHIS tract boundaries)
tracts2010 <- read.csv("US_tract_2010.csv") %>%
  select(GEOID10, tr2010gj)
data$GEOID10 <- as.numeric(data$GEOID10)
data <- left_join(data, tracts2010, by = "GEOID10")


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
data$RacialGroups <- data$Asian_sum + data$Black_sum + data$Other_sum + data$White_sum
data$Elocal <- ifelse(data$Population_sum >= 100 & data$Population_sum >= data$RacialGroups,
                      ((data$White_sum / data$Population_sum) * log(1 / (data$White_sum / data$Population_sum)) + 
                         (data$Black_sum / data$Population_sum) * log(1 / (data$Black_sum / data$Population_sum)) + 
                         (data$Asian_sum / data$Population_sum) * log(1 / (data$Asian_sum / data$Population_sum)) + 
                         (data$Other_sum / data$Population_sum) * log(1 / (data$Other_sum / data$Population_sum))), 
                      NA)
data <- data %>% select(-RacialGroups)


#final cleanup and save
##sort data
data <- data %>% 
  select(-GEOID10) %>% 
  select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))

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
