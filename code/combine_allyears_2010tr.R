#This script creates a longitudinal tract database from 1970 to 2020. It:
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


#set working directory 
here::i_am("combinte_allyears_2010tr.R")

#load data
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


#calculate change variables
##for 1970 to 1980
data <- within(data, {
  Adults_sum_chg_1970to1980 <- Adults_sum_1980 - Adults_sum_1970
  Asian_pct_chg_1970to1980 <- Asian_pct_1980 - Asian_pct_1970
  Asian_sum_chg_1970to1980 <- Asian_sum_1980 - Asian_sum_1970
  Bach_pct_chg_1970to1980 <- Bach_pct_1980 - Bach_pct_1970
  Bach_sum_chg_1970to1980 <- Bach_sum_1980 - Bach_sum_1970
  Black_pct_chg_1970to1980 <- Black_pct_1980 - Black_pct_1970
  Black_sum_chg_1970to1980 <- Black_sum_1980 - Black_sum_1970
  ConRent_agg_chg_1970to1980 <- ConRent_agg_1980 - ConRent_agg_1970
  ConRent_mean_chg_1970to1980 <- ConRent_mean_1980 - ConRent_mean_1970
  Elocal_chg_1970to1980 <- Elocal_1980 - Elocal_1970
  Employed_sum_chg_1970to1980 <- Employed_sum_1980 - Employed_sum_1970
  HHIncome_agg_chg_1970to1980 <- HHIncome_agg_1980 - HHIncome_agg_1970
  HHIncome_mean_chg_1970to1980 <- HHIncome_mean_1980 - HHIncome_mean_1970
  Hispanic_pct_chg_1970to1980 <- Hispanic_pct_1980 - Hispanic_pct_1970
  Hispanic_sum_chg_1970to1980 <- Hispanic_sum_1980 - Hispanic_sum_1970
  Households_sum_chg_1970to1980 <- Households_sum_1980 - Households_sum_1970
  HouseUnits_sum_chg_1970to1980 <- HouseUnits_sum_1980 - HouseUnits_sum_1970
  HouseValue_agg_chg_1970to1980 <- HouseValue_agg_1980 - HouseValue_agg_1970
  HouseValue_mean_chg_1970to1980 <- HouseValue_mean_1980 - HouseValue_mean_1970
  HUOccupied_sum_chg_1970to1980 <- HUOccupied_sum_1980 - HUOccupied_sum_1970
  HUOwner_pct_chg_1970to1980 <- HUOwner_pct_1980 - HUOwner_pct_1970
  HUOwner_sum_chg_1970to1980 <- HUOwner_sum_1980 - HUOwner_sum_1970
  HURenter_pct_chg_1970to1980 <- HURenter_pct_1980 - HURenter_pct_1970
  HURenter_sum_chg_1970to1980 <- HURenter_sum_1980 - HURenter_sum_1970
  HUVacant_pct_chg_1970to1980 <- HUVacant_pct_1980 - HUVacant_pct_1970
  HUVacant_sum_chg_1970to1980 <- HUVacant_sum_1980 - HUVacant_sum_1970
  MovedIn_under10yrs_pct_chg_1970to1980 <- MovedIn_under10yrs_pct_1980 - MovedIn_under10yrs_pct_1970
  MovedIn_under10yrs_sum_chg_1970to1980 <- MovedIn_under10yrs_sum_1980 - MovedIn_under10yrs_sum_1970
  Other_pct_chg_1970to1980 <- Other_pct_1980 - Other_pct_1970
  Other_sum_chg_1970to1980 <- Other_sum_1980 - Other_sum_1970
  Population_sum_chg_1970to1980 <- Population_sum_1980 - Population_sum_1970
  Poverty_pct_chg_1970to1980 <- Poverty_pct_1980 - Poverty_pct_1970
  Poverty_sum_chg_1970to1980 <- Poverty_sum_1980 - Poverty_sum_1970
  White_pct_chg_1970to1980 <- White_pct_1980 - White_pct_1970
  White_sum_chg_1970to1980 <- White_sum_1980 - White_sum_1970
  WhiteCollar_pct_chg_1970to1980 <- WhiteCollar_pct_1980 - WhiteCollar_pct_1970
  WhiteCollar_sum_chg_1970to1980 <- WhiteCollar_sum_1980 - WhiteCollar_sum_1970
})

##for 1980 to 1990
data <- within(data, {
  Adults_sum_chg_1980to1990 <- Adults_sum_1990 - Adults_sum_1980
  Asian_pct_chg_1980to1990 <- Asian_pct_1990 - Asian_pct_1980
  Asian_sum_chg_1980to1990 <- Asian_sum_1990 - Asian_sum_1980
  Bach_pct_chg_1980to1990 <- Bach_pct_1990 - Bach_pct_1980
  Bach_sum_chg_1980to1990 <- Bach_sum_1990 - Bach_sum_1980
  Black_pct_chg_1980to1990 <- Black_pct_1990 - Black_pct_1980
  Black_sum_chg_1980to1990 <- Black_sum_1990 - Black_sum_1980
  ConRent_agg_chg_1980to1990 <- ConRent_agg_1990 - ConRent_agg_1980
  ConRent_mean_chg_1980to1990 <- ConRent_mean_1990 - ConRent_mean_1980
  Elocal_chg_1980to1990 <- Elocal_1990 - Elocal_1980
  Employed_sum_chg_1980to1990 <- Employed_sum_1990 - Employed_sum_1980
  HHIncome_agg_chg_1980to1990 <- HHIncome_agg_1990 - HHIncome_agg_1980
  HHIncome_mean_chg_1980to1990 <- HHIncome_mean_1990 - HHIncome_mean_1980
  Hispanic_pct_chg_1980to1990 <- Hispanic_pct_1990 - Hispanic_pct_1980
  Hispanic_sum_chg_1980to1990 <- Hispanic_sum_1990 - Hispanic_sum_1980
  Households_sum_chg_1980to1990 <- Households_sum_1990 - Households_sum_1980
  HouseUnits_sum_chg_1980to1990 <- HouseUnits_sum_1990 - HouseUnits_sum_1980
  HouseValue_agg_chg_1980to1990 <- HouseValue_agg_1990 - HouseValue_agg_1980
  HouseValue_mean_chg_1980to1990 <- HouseValue_mean_1990 - HouseValue_mean_1980
  HouseValue_Mortgaged_agg_chg_1980to1990 <- HouseValue_Mortgaged_agg_1990 - HouseValue_Mortgaged_agg_1980
  HouseValue_Mortgaged_mean_chg_1980to1990 <- HouseValue_Mortgaged_mean_1990 - HouseValue_Mortgaged_mean_1980
  HUOccupied_sum_chg_1980to1990 <- HUOccupied_sum_1990 - HUOccupied_sum_1980
  HUOwner_pct_chg_1980to1990 <- HUOwner_pct_1990 - HUOwner_pct_1980
  HUOwner_sum_chg_1980to1990 <- HUOwner_sum_1990 - HUOwner_sum_1980
  HURenter_pct_chg_1980to1990 <- HURenter_pct_1990 - HURenter_pct_1980
  HURenter_sum_chg_1980to1990 <- HURenter_sum_1990 - HURenter_sum_1980
  HUVacant_pct_chg_1980to1990 <- HUVacant_pct_1990 - HUVacant_pct_1980
  HUVacant_sum_chg_1980to1990 <- HUVacant_sum_1990 - HUVacant_sum_1980
  MovedIn_under10yrs_pct_chg_1980to1990 <- MovedIn_under10yrs_pct_1990 - MovedIn_under10yrs_pct_1980
  MovedIn_under10yrs_sum_chg_1980to1990 <- MovedIn_under10yrs_sum_1990 - MovedIn_under10yrs_sum_1980
  Other_pct_chg_1980to1990 <- Other_pct_1990 - Other_pct_1980
  Other_sum_chg_1980to1990 <- Other_sum_1990 - Other_sum_1980
  Population_sum_chg_1980to1990 <- Population_sum_1990 - Population_sum_1980
  Poverty_pct_chg_1980to1990 <- Poverty_pct_1990 - Poverty_pct_1980
  Poverty_sum_chg_1980to1990 <- Poverty_sum_1990 - Poverty_sum_1980
  White_pct_chg_1980to1990 <- White_pct_1990 - White_pct_1980
  White_sum_chg_1980to1990 <- White_sum_1990 - White_sum_1980
  WhiteCollar_pct_chg_1980to1990 <- WhiteCollar_pct_1990 - WhiteCollar_pct_1980
  WhiteCollar_sum_chg_1980to1990 <- WhiteCollar_sum_1990 - WhiteCollar_sum_1980
})

##for 1990 to 2000
data <- within(data, {
  Adults_sum_chg_1990to2000 <- Adults_sum_2000 - Adults_sum_1990
  Asian_pct_chg_1990to2000 <- Asian_pct_2000 - Asian_pct_1990
  Asian_sum_chg_1990to2000 <- Asian_sum_2000 - Asian_sum_1990
  Bach_pct_chg_1990to2000 <- Bach_pct_2000 - Bach_pct_1990
  Bach_sum_chg_1990to2000 <- Bach_sum_2000 - Bach_sum_1990
  Black_pct_chg_1990to2000 <- Black_pct_2000 - Black_pct_1990
  Black_sum_chg_1990to2000 <- Black_sum_2000 - Black_sum_1990
  ConRent_agg_chg_1990to2000 <- ConRent_agg_2000 - ConRent_agg_1990
  ConRent_mean_chg_1990to2000 <- ConRent_mean_2000 - ConRent_mean_1990
  Elocal_chg_1990to2000 <- Elocal_2000 - Elocal_1990
  Employed_sum_chg_1990to2000 <- Employed_sum_2000 - Employed_sum_1990
  HHIncome_agg_chg_1990to2000 <- HHIncome_agg_2000 - HHIncome_agg_1990
  HHIncome_mean_chg_1990to2000 <- HHIncome_mean_2000 - HHIncome_mean_1990
  Hispanic_pct_chg_1990to2000 <- Hispanic_pct_2000 - Hispanic_pct_1990
  Hispanic_sum_chg_1990to2000 <- Hispanic_sum_2000 - Hispanic_sum_1990
  Households_sum_chg_1990to2000 <- Households_sum_2000 - Households_sum_1990
  HouseUnits_sum_chg_1990to2000 <- HouseUnits_sum_2000 - HouseUnits_sum_1990
  HouseValue_agg_chg_1990to2000 <- HouseValue_agg_2000 - HouseValue_agg_1990
  HouseValue_mean_chg_1990to2000 <- HouseValue_mean_2000 - HouseValue_mean_1990
  HouseValue_Mortgaged_agg_chg_1990to2000 <- HouseValue_Mortgaged_agg_2000 - HouseValue_Mortgaged_agg_1990
  HouseValue_Mortgaged_mean_chg_1990to2000 <- HouseValue_Mortgaged_mean_2000 - HouseValue_Mortgaged_mean_1990
  HUOccupied_sum_chg_1990to2000 <- HUOccupied_sum_2000 - HUOccupied_sum_1990
  HUOwner_pct_chg_1990to2000 <- HUOwner_pct_2000 - HUOwner_pct_1990
  HUOwner_sum_chg_1990to2000 <- HUOwner_sum_2000 - HUOwner_sum_1990
  HURenter_pct_chg_1990to2000 <- HURenter_pct_2000 - HURenter_pct_1990
  HURenter_sum_chg_1990to2000 <- HURenter_sum_2000 - HURenter_sum_1990
  HUVacant_pct_chg_1990to2000 <- HUVacant_pct_2000 - HUVacant_pct_1990
  HUVacant_sum_chg_1990to2000 <- HUVacant_sum_2000 - HUVacant_sum_1990
  MovedIn_under10yrs_pct_chg_1990to2000 <- MovedIn_under10yrs_pct_2000 - MovedIn_under10yrs_pct_1990
  MovedIn_under10yrs_sum_chg_1990to2000 <- MovedIn_under10yrs_sum_2000 - MovedIn_under10yrs_sum_1990
  Other_pct_chg_1990to2000 <- Other_pct_2000 - Other_pct_1990
  Other_sum_chg_1990to2000 <- Other_sum_2000 - Other_sum_1990
  Population_sum_chg_1990to2000 <- Population_sum_2000 - Population_sum_1990
  Poverty_pct_chg_1990to2000 <- Poverty_pct_2000 - Poverty_pct_1990
  Poverty_sum_chg_1990to2000 <- Poverty_sum_2000 - Poverty_sum_1990
  White_pct_chg_1990to2000 <- White_pct_2000 - White_pct_1990
  White_sum_chg_1990to2000 <- White_sum_2000 - White_sum_1990
  WhiteCollar_pct_chg_1990to2000 <- WhiteCollar_pct_2000 - WhiteCollar_pct_1990
  WhiteCollar_sum_chg_1990to2000 <- WhiteCollar_sum_2000 - WhiteCollar_sum_1990
})

##for 2000 to 2010
data <- within(data, {
  Adults_sum_chg_2000to2010 <- Adults_sum_2010 - Adults_sum_2000
  Asian_pct_chg_2000to2010 <- Asian_pct_2010 - Asian_pct_2000
  Asian_sum_chg_2000to2010 <- Asian_sum_2010 - Asian_sum_2000
  Bach_pct_chg_2000to2010 <- Bach_pct_2010 - Bach_pct_2000
  Bach_sum_chg_2000to2010 <- Bach_sum_2010 - Bach_sum_2000
  Black_pct_chg_2000to2010 <- Black_pct_2010 - Black_pct_2000
  Black_sum_chg_2000to2010 <- Black_sum_2010 - Black_sum_2000
  ConRent_agg_chg_2000to2010 <- as.numeric(ConRent_agg_2010) - ConRent_agg_2000
  ConRent_mean_chg_2000to2010 <- ConRent_mean_2010 - ConRent_mean_2000
  Elocal_chg_2000to2010 <- Elocal_2010 - Elocal_2000
  Employed_sum_chg_2000to2010 <- Employed_sum_2010 - Employed_sum_2000
  HHIncome_agg_chg_2000to2010 <- as.numeric(HHIncome_agg_2010) - as.numeric(HHIncome_agg_2000)
  HHIncome_mean_chg_2000to2010 <- HHIncome_mean_2010 - HHIncome_mean_2000
  Hispanic_pct_chg_2000to2010 <- Hispanic_pct_2010 - Hispanic_pct_2000
  Hispanic_sum_chg_2000to2010 <- Hispanic_sum_2010 - Hispanic_sum_2000
  Households_sum_chg_2000to2010 <- Households_sum_2010 - Households_sum_2000
  HouseUnits_sum_chg_2000to2010 <- HouseUnits_sum_2010 - HouseUnits_sum_2000
  HouseValue_agg_chg_2000to2010 <- as.numeric(HouseValue_agg_2010) - as.numeric(HouseValue_agg_2000)
  HouseValue_mean_chg_2000to2010 <- HouseValue_mean_2010 - HouseValue_mean_2000
  HouseValue_Mortgaged_agg_chg_2000to2010 <- as.numeric(HouseValue_Mortgaged_agg_2010) - 
    as.numeric(HouseValue_Mortgaged_agg_2000)
  HouseValue_Mortgaged_mean_chg_2000to2010 <- HouseValue_Mortgaged_mean_2010 - HouseValue_Mortgaged_mean_2000
  HUOccupied_sum_chg_2000to2010 <- HUOccupied_sum_2010 - HUOccupied_sum_2000
  HUOwner_pct_chg_2000to2010 <- HUOwner_pct_2010 - HUOwner_pct_2000
  HUOwner_sum_chg_2000to2010 <- HUOwner_sum_2010 - HUOwner_sum_2000
  HURenter_pct_chg_2000to2010 <- HURenter_pct_2010 - HURenter_pct_2000
  HURenter_sum_chg_2000to2010 <- HURenter_sum_2010 - HURenter_sum_2000
  HUVacant_pct_chg_2000to2010 <- HUVacant_pct_2010 - HUVacant_pct_2000
  HUVacant_sum_chg_2000to2010 <- HUVacant_sum_2010 - HUVacant_sum_2000
  MovedIn_under10yrs_pct_chg_2000to2010 <- MovedIn_under10yrs_pct_2010 - MovedIn_under10yrs_pct_2000
  MovedIn_under10yrs_sum_chg_2000to2010 <- MovedIn_under10yrs_sum_2010 - MovedIn_under10yrs_sum_2000
  Multi_pct_chg_2000to2010 <- Multi_pct_2010 - Multi_pct_2000
  Multi_sum_chg_2000to2010 <- Multi_sum_2010 - Multi_sum_2000
  Other_pct_chg_2000to2010 <- Other_pct_2010 - Other_pct_2000
  Other_sum_chg_2000to2010 <- Other_sum_2010 - Other_sum_2000
  Population_sum_chg_2000to2010 <- Population_sum_2010 - Population_sum_2000
  Poverty_pct_chg_2000to2010 <- Poverty_pct_2010 - Poverty_pct_2000
  Poverty_sum_chg_2000to2010 <- Poverty_sum_2010 - Poverty_sum_2000
  White_pct_chg_2000to2010 <- White_pct_2010 - White_pct_2000
  White_sum_chg_2000to2010 <- White_sum_2010 - White_sum_2000
  WhiteCollar_pct_chg_2000to2010 <- WhiteCollar_pct_2010 - WhiteCollar_pct_2000
  WhiteCollar_sum_chg_2000to2010 <- WhiteCollar_sum_2010 - WhiteCollar_sum_2000
})

##for 2010 to 2020
data <- within(data, {
  Adults_sum_chg_2010to2020 <- Adults_sum_2020 - Adults_sum_2010
  Asian_pct_chg_2010to2020 <- Asian_pct_2020 - Asian_pct_2010
  Asian_sum_chg_2010to2020 <- Asian_sum_2020 - Asian_sum_2010
  Bach_pct_chg_2010to2020 <- Bach_pct_2020 - Bach_pct_2010
  Bach_sum_chg_2010to2020 <- Bach_sum_2020 - Bach_sum_2010
  Black_pct_chg_2010to2020 <- Black_pct_2020 - Black_pct_2010
  Black_sum_chg_2010to2020 <- Black_sum_2020 - Black_sum_2010
  ConRent_agg_chg_2010to2020 <- as.numeric(ConRent_agg_2020) - as.numeric(ConRent_agg_2010)
  ConRent_mean_chg_2010to2020 <- ConRent_mean_2020 - ConRent_mean_2010
  Elocal_chg_2010to2020 <- Elocal_2020 - Elocal_2010
  Employed_sum_chg_2010to2020 <- Employed_sum_2020 - Employed_sum_2010
  HHIncome_agg_chg_2010to2020 <- as.numeric(HHIncome_agg_2020) - as.numeric(HHIncome_agg_2010)
  HHIncome_mean_chg_2010to2020 <- HHIncome_mean_2020 - HHIncome_mean_2010
  Hispanic_pct_chg_2010to2020 <- Hispanic_pct_2020 - Hispanic_pct_2010
  Hispanic_sum_chg_2010to2020 <- Hispanic_sum_2020 - Hispanic_sum_2010
  Households_sum_chg_2010to2020 <- Households_sum_2020 - Households_sum_2010
  HouseUnits_sum_chg_2010to2020 <- HouseUnits_sum_2020 - HouseUnits_sum_2010
  HouseValue_agg_chg_2010to2020 <- as.numeric(HouseValue_agg_2020) - as.numeric(HouseValue_agg_2010)
  HouseValue_mean_chg_2010to2020 <- HouseValue_mean_2020 - HouseValue_mean_2010
  HouseValue_Mortgaged_agg_chg_2010to2020 <- as.numeric(HouseValue_Mortgaged_agg_2020) - 
    as.numeric(HouseValue_Mortgaged_agg_2010)
  HouseValue_Mortgaged_mean_chg_2010to2020 <- HouseValue_Mortgaged_mean_2020 - HouseValue_Mortgaged_mean_2010
  HUOccupied_sum_chg_2010to2020 <- HUOccupied_sum_2020 - HUOccupied_sum_2010
  HUOwner_pct_chg_2010to2020 <- HUOwner_pct_2020 - HUOwner_pct_2010
  HUOwner_sum_chg_2010to2020 <- HUOwner_sum_2020 - HUOwner_sum_2010
  HURenter_pct_chg_2010to2020 <- HURenter_pct_2020 - HURenter_pct_2010
  HURenter_sum_chg_2010to2020 <- HURenter_sum_2020 - HURenter_sum_2010
  HUVacant_pct_chg_2010to2020 <- HUVacant_pct_2020 - HUVacant_pct_2010
  HUVacant_sum_chg_2010to2020 <- HUVacant_sum_2020 - HUVacant_sum_2010
  MovedIn_under10yrs_pct_chg_2010to2020 <- MovedIn_under10yrs_pct_2020 - MovedIn_under10yrs_pct_2010
  MovedIn_under10yrs_sum_chg_2010to2020 <- MovedIn_under10yrs_sum_2020 - MovedIn_under10yrs_sum_2010
  Multi_pct_chg_2010to2020 <- Multi_pct_2020 - Multi_pct_2010
  Multi_sum_chg_2010to2020 <- Multi_sum_2020 - Multi_sum_2010
  Other_pct_chg_2010to2020 <- Other_pct_2020 - Other_pct_2010
  Other_sum_chg_2010to2020 <- Other_sum_2020 - Other_sum_2010
  Population_sum_chg_2010to2020 <- Population_sum_2020 - Population_sum_2010
  Poverty_pct_chg_2010to2020 <- Poverty_pct_2020 - Poverty_pct_2010
  Poverty_sum_chg_2010to2020 <- Poverty_sum_2020 - Poverty_sum_2010
  White_pct_chg_2010to2020 <- White_pct_2020 - White_pct_2010
  White_sum_chg_2010to2020 <- White_sum_2020 - White_sum_2010
  WhiteCollar_pct_chg_2010to2020 <- WhiteCollar_pct_2020 - WhiteCollar_pct_2010
  WhiteCollar_sum_chg_2010to2020 <- WhiteCollar_sum_2020 - WhiteCollar_sum_2010
})

##for the entire range, 1970 to 2020
data <- within(data, {
  Adults_sum_chg_1970to2020 <- Adults_sum_2020 - Adults_sum_1970
  Asian_pct_chg_1970to2020 <- Asian_pct_2020 - Asian_pct_1970
  Asian_sum_chg_1970to2020 <- Asian_sum_2020 - Asian_sum_1970
  Bach_pct_chg_1970to2020 <- Bach_pct_2020 - Bach_pct_1970
  Bach_sum_chg_1970to2020 <- Bach_sum_2020 - Bach_sum_1970
  Black_pct_chg_1970to2020 <- Black_pct_2020 - Black_pct_1970
  Black_sum_chg_1970to2020 <- Black_sum_2020 - Black_sum_1970
  ConRent_agg_chg_1970to2020 <- ConRent_agg_2020 - ConRent_agg_1970
  ConRent_mean_chg_1970to2020 <- ConRent_mean_2020 - ConRent_mean_1970
  Elocal_chg_1970to2020 <- Elocal_2020 - Elocal_1970
  Employed_sum_chg_1970to2020 <- Employed_sum_2020 - Employed_sum_1970
  HHIncome_agg_chg_1970to2020 <- HHIncome_agg_2020 - HHIncome_agg_1970
  HHIncome_mean_chg_1970to2020 <- HHIncome_mean_2020 - HHIncome_mean_1970
  Hispanic_pct_chg_1970to2020 <- Hispanic_pct_2020 - Hispanic_pct_1970
  Hispanic_sum_chg_1970to2020 <- Hispanic_sum_2020 - Hispanic_sum_1970
  Households_sum_chg_1970to2020 <- Households_sum_2020 - Households_sum_1970
  HouseUnits_sum_chg_1970to2020 <- HouseUnits_sum_2020 - HouseUnits_sum_1970
  HouseValue_agg_chg_1970to2020 <- HouseValue_agg_2020 - HouseValue_agg_1970
  HouseValue_mean_chg_1970to2020 <- HouseValue_mean_2020 - HouseValue_mean_1970
  HUOccupied_sum_chg_1970to2020 <- HUOccupied_sum_2020 - HUOccupied_sum_1970
  HUOwner_pct_chg_1970to2020 <- HUOwner_pct_2020 - HUOwner_pct_1970
  HUOwner_sum_chg_1970to2020 <- HUOwner_sum_2020 - HUOwner_sum_1970
  HURenter_pct_chg_1970to2020 <- HURenter_pct_2020 - HURenter_pct_1970
  HURenter_sum_chg_1970to2020 <- HURenter_sum_2020 - HURenter_sum_1970
  HUVacant_pct_chg_1970to2020 <- HUVacant_pct_2020 - HUVacant_pct_1970
  HUVacant_sum_chg_1970to2020 <- HUVacant_sum_2020 - HUVacant_sum_1970
  MovedIn_under10yrs_pct_chg_1970to2020 <- MovedIn_under10yrs_pct_2020 - MovedIn_under10yrs_pct_1970
  MovedIn_under10yrs_sum_chg_1970to2020 <- MovedIn_under10yrs_sum_2020 - MovedIn_under10yrs_sum_1970
  Other_pct_chg_1970to2020 <- Other_pct_2020 - Other_pct_1970
  Other_sum_chg_1970to2020 <- Other_sum_2020 - Other_sum_1970
  Population_sum_chg_1970to2020 <- Population_sum_2020 - Population_sum_1970
  Poverty_pct_chg_1970to2020 <- Poverty_pct_2020 - Poverty_pct_1970
  Poverty_sum_chg_1970to2020 <- Poverty_sum_2020 - Poverty_sum_1970
  White_pct_chg_1970to2020 <- White_pct_2020 - White_pct_1970
  White_sum_chg_1970to2020 <- White_sum_2020 - White_sum_1970
  WhiteCollar_pct_chg_1970to2020 <- WhiteCollar_pct_2020 - WhiteCollar_pct_1970
  WhiteCollar_sum_chg_1970to2020 <- WhiteCollar_sum_2020 - WhiteCollar_sum_1970
})

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

##View descriptive to verify
metrics <- metrics %>% arrange(Variable)
write.csv(metrics, "metrics.csv", row.names = FALSE)

#final cleanup and save
##archive all data
data <- data %>% select(tr2010gj, sort(setdiff(names(.), "tr2010gj")))
write.csv(data, file = "tractdata_2010tr.csv", na="", row.names = FALSE)

##save a sample of 'urban' census tracts
metros <- read.csv("metrotracts_2010.csv")
metros <- metros %>% rename(tr2010gj = GISJOIN)
metros <- metros %>% left_join(data, by = "tr2010gj")
write.csv(metros, file = "metrotracts_data_2010tr.csv", na="", row.names = FALSE)
