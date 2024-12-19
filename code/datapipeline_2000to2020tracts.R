#This script
## 1)pulls raw data from the NGHIS API, 
## 2) crosswalks the data to modern census boundaries
## 3) cleans data and calculates derivative statistics (e.g. percents, means)

library(ipumsr)
library(dplyr)
library(data.table)
library(purrr)

#set working directory & general attributes
setwd("Your directory here")
year <- "2000"
inflation <- 1.5477  #based on BLS CPI inflation calculator, https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1%2C000.00&year1=199912&year2=202012

#set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "Your key here"
set_ipums_api_key(my_key)

#see metadata for relevant parameters
metadata_SF1b <- get_metadata_nhgis(dataset = "2000_SF1b")
metadata_SF3b <- get_metadata_nhgis(dataset = "2000_SF3b")


#pulling data from the IPUMS API
##define the data to extract
ds <- define_extract_nhgis(
  description = "Gentrification map data, 2000 blocks & block group parts",
  datasets = list(
    ds_spec("2000_SF1b",
            data_tables = c("NP001A", "NP003A", "NP003B", "NP004A", "NP015A",
                            "NH001A", "NH003A", "NH004B"),
            geog_levels = "block"),
    ds_spec("2000_SF3b",
            data_tables = c("NP037A", "NP037C", "NP049A", "NP050B", "NP054A", 
                            "NP088A", "NH038A", "NH058A", "NH078A", "NH081A"),
            geog_levels = "blck_grp_090")
    ),
    geographic_extents = "*"
  )

##submit to the API and download results
extract <- submit_extract(ds)
wait_for_extract(extract)   
filepath <- download_extract(extract)


#for data from short form questionnaire (SF1b), available at block level
##define variables
variables_blk <- c(
  Asian_sum = "FXW004",
  Black_sum = "FXW002",
  Hispanic_sum = "FXZ001",
  Households_sum = "FY4001",
  HouseUnits_sum = "FV5001",
  HUOccupied_sum = "FV8001",
  HUOwner_sum = "FWA001",
  HURenter_sum = "FWA002",
  HUVacant_sum = "FV8002",
  Multi_sum = "FXV002",
  Other_sum = "FXW006",
  Population_sum = "FXS001",
  White_sum = "FXW001"
)

##load data, filtering to reduce memory load
data_blk <- read_nhgis(filepath, file_select = 1) %>%
  select(GISJOIN, all_of(variables_blk)) 
data_blk <- data_blk %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##crosswalk the data to 2010 tract boundaries
####load crosswalk from IPUMS API
url_blk <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_blk2000_blk2010.zip"
download.file(url_blk, "nhgis_blk2000_blk2010.zip", headers = c(Authorization = my_key))

###crosswalk and merge
crosswalks_blk <- read_nhgis("nhgis_blk2000_blk2010.zip") %>%
  select(blk2000gj, blk2010gj, weight)
data_blk <- data_blk %>% rename(blk2000gj = GISJOIN)
data_blk <- left_join(crosswalks_blk, data_blk, by = "blk2000gj")
rm(crosswalks_blk)

###weight source data for new boundaries
data_blk <- data_blk %>%
  mutate(across(
    .cols = !all_of(c("blk2000gj", "blk2010gj")),  
    .fns = ~ . * weight
  ))

##define final variable selections
variable_names_blk <- c(
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

##summarize by block
### use data table to manage big data
setDT(data_blk)
setkey(data_blk, blk2010gj)
data_blk <- data_blk[, lapply(.SD, sum), by = blk2010gj, .SDcols = variable_names_blk]

##crosswalk the data to 2020 tracts
###load crosswalk from IPUMS API
url_blk <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_blk2010_tr2020.zip"
download.file(url_blk, "nhgis_blk2010_tr2020.zip", headers = c(Authorization = my_key))

###crosswalk and merge again, to tracts
crosswalks_blk <- read_nhgis("nhgis_blk2010_tr2020.zip") %>%
  select(blk2010gj, tr2020gj, weight)
data_blk <- left_join(crosswalks_blk, data_blk, by = "blk2010gj")
rm(crosswalks_blk)

###weight variables again, to tracts
data_blk <- data_blk %>%
  mutate(across(
    .cols = !all_of(c("blk2010gj", "tr2020gj")),  
    .fns = ~ . * weight
  ))

### use data table to manage big data
setDT(data_blk)
setkey(data_blk, tr2010gj)

##summarize by tract
data_blk <- data_blk[, lapply(.SD, sum), by = tr2020gj, .SDcols = variable_names_blk]


#for data from long form questionnaire, available at block group partition level
##define variables
variables_bgp <- c(
  Adults_sum = "HDZ001",
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
data_bgp <- read_nhgis(filepath, file_select = 2)%>%
  select(GISJOIN, all_of(variables_bgp)) 
data_bgp <- data_bgp %>% select(GISJOIN, sort(setdiff(names(.), "GISJOIN")))

##crosswalk the data to 2010 tract boundaries
###load crosswalk from IPUMS API
url_bgp <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_bgp2000_bg2010.zip"
download.file(url_bgp, "nhgis_bgp2000_bg2010.zip", headers = c(Authorization = my_key))

###crosswalk and merge
crosswalks_bgp <- read_nhgis("nhgis_bgp2000_bg2010.zip")
data_bgp <- data_bgp %>% rename(bgp2000gj = GISJOIN)
data_bgp <- left_join(crosswalks_bgp, data_bgp, by = "bgp2000gj")
rm(crosswalks_bgp)

###weight blocks to tracts
data_bgp <- within(data_bgp, {
  Adults_sum <- Adults_sum * wt_pop
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
  "Adults_sum",
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
  group_by(bg2010gj) %>%
  summarize(across(all_of(variable_names_bgp), sum))   

##crosswalk the data to 2020 tracts
###load crosswalk from IPUMS API
url_bgp <- "https://api.ipums.org/supplemental-data/nhgis/crosswalks/nhgis_bg2010_tr2020.zip"
download.file(url_bgp, "nhgis_bg2010_tr2020.zip", headers = c(Authorization = my_key))

###crosswalk and merge again, to tracts
crosswalks_bgp <- read_nhgis("nhgis_bg2010_tr2020.zip") 
data_bgp <- left_join(crosswalks_bgp, data_bgp, by = "bg2010gj")
rm(crosswalks_bgp)

###weight data by tract
data_bgp <- within(data_bgp, {
  Adults_sum <- Adults_sum * wt_adult
  ConRent_agg <- ConRent_agg * wt_renthu
  Bach_sum <- Bach_sum * wt_adult
  Employed_sum <- Employed_sum * wt_pop
  HHIncome_agg <- HHIncome_agg * wt_hh
  HouseValue_agg <- HouseValue_agg * wt_ownhu
  HouseValue_Mortgaged_agg <- HouseValue_Mortgaged_agg * wt_ownhu
  MovedIn_under10yrs_sum <- MovedIn_under10yrs_sum * wt_hu
  Poverty_sum <- Poverty_sum * wt_pop
  WhiteCollar_sum <- WhiteCollar_sum * wt_pop
})


###summarize by tract
data_bgp <- data_bgp %>% 
  group_by(tr2020gj) %>%
  summarize(across(all_of(variable_names_bgp), sum))   


#compile the entire dataset
##merge block and block group partition data
data <- left_join(data_blk, data_bgp, by = "tr2020gj")
data <- data %>% select(tr2020gj, sort(setdiff(names(.), "tr2020gj")))


##calculate derivative metrics
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
    return(numerator / denominator)
  } else {
    return(NA)
  }
})

divide_value <- Vectorize(function(numerator, denominator) {
  if (!is.na(numerator) && !is.na(denominator) && denominator >= 10) {
    return(numerator / denominator)
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
data <- data %>% select(tr2020gj, sort(setdiff(names(.), "tr2020gj")))

##name processed data
data <- data %>%
  rename_with(
    ~ifelse(. == "tr2020gj", ., paste0(., "_", year)),
    .cols = everything()
  )

##archive original data
file.rename(filepath, paste0("nhgis_", year, ".zip" ))

##save cleaned data
filename <- paste0("tractdata_", year, "_2020tr.csv")
write.csv(data, file = filename, na="")

