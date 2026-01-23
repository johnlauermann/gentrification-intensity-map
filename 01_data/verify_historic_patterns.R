# This script compares the contemporary and historical versions of the National Gentrification Intensity Map
# It assesses whether tracts identified as 'historically affluent' in the contemporary map were gentrified in early decades.
# The workflow includes:
## 1) Load the gentrification index data from both methodology
## 2) Crosswalk the historical data to contemporary boundaries and merge with contemporary data
## 3) Verify if and which tracts should be reclassified from historically affluent to gentrified

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ipumsr)) install.packages("ipumsr")

library(dplyr)
library(here)
library(ipumsr)

# set environment
here::i_am("01_data/verify_historic_patterns.R")


# load data
## define variables
variables <- c("Gentrified",
               "Gentrifying",
               "HistoricallyAffluent")
pattern <- paste(variables, collapse = "|")

## load and filter data
modern_data <- read.csv(here("01_data/metrotracts_gentscores_2020tr.csv")) %>%
  select(tr2020gj, CBSAFP, matches(pattern)) %>%
  filter(HistoricallyAffluent == 1)
historic_data <- read.csv(here("02_data_historic/metrotracts_gentscores_2010tr.csv")) %>%
  select(tr2010gj, CBSAFP, matches(pattern)) %>%
  filter(Gentrified_70to80 == 1 | Gentrified_80to90 == 1)


# set API key (to get one: https://account.ipums.org/api_keys)
my_key <- "your key here"
set_ipums_api_key(my_key)


# crosswalk historic data
###load crosswalk from IPUMS API
url <- "https://secure-assets.ipums.org/nhgis/crosswalks/nhgis_tr2020_tr2010.zip"
download.file(url, here("01_data/nhgis_tr2020_tr2010.zip"), headers = c(Authorization = my_key))

###join with data to identify 2010 to 2020 matches (only complete matches)
crosswalks <- read_ipums_agg(here("01_data/nhgis_tr2020_tr2010.zip")) %>%
  filter(wt_pop == 1)
historic_data <- historic_data %>% 
  left_join(crosswalks, historic_data, by = "tr2010gj")


# identify overlaps
## join historical data to modern
overlaps <- inner_join(modern_data, historic_data, by = "tr2020gj") %>%
  select(tr2020gj, Gentrified_70to80, Gentrified_80to90) 

## remove duplicate rows
overlaps <- overlaps %>%
  group_by(tr2020gj) %>%
  summarise(Gentrified_70to80 = mean(Gentrified_70to80),
            Gentrified_80to90 = mean(Gentrified_80to90)
  )


# reclassify historically gentrified tracts
data <- read.csv(here("01_data/metrotracts_gentscores_2020tr.csv"))
data <- left_join(data, overlaps, by = "tr2020gj") 

## reclassify overlaps from 'historically affluent' to 'gentrified'
data <- data %>%
  mutate(
    Gentrified_70to80 = ifelse(is.na(Gentrified_70to80), 0, Gentrified_70to80),
    Gentrified_80to90 = ifelse(is.na(Gentrified_80to90), 0, Gentrified_80to90)
    )
data <- data %>%
  mutate(
    HistoricallyAffluent = ifelse((Gentrified_70to80 == 1 | Gentrified_80to90 ==1), 0, HistoricallyAffluent),
    Gentrified = ifelse((Gentrified_70to80 == 1 | Gentrified_80to90 == 1), 1, Gentrified)
    ) 

## verify any changes to super-gentrification patterns
data <- data %>%
  mutate(
    SuperGentrified_80to00 = ifelse((Gentrified_70to80 == 1 | Gentrified_80to90 == 1) &
                                      (Gentrifying_90to00 == 1), 1, 0),
    SuperGentrified_90to10 = ifelse((Gentrified_80to90 == 1 | Gentrified_90to00 == 1) &
                                      (Gentrifying_00to10 ==1), 1, 0),
    SuperGentrified_00to20 = ifelse((Gentrified_90to00 == 1 | Gentrified_00to10 == 1) &
                                      (Gentrifying_10to20 == 1), 1, 0)
  )
data <- data %>%
  mutate(
    SuperGentrified = ifelse(SuperGentrified_80to00 == 1 | SuperGentrified_90to10 == 1 | SuperGentrified_00to20 == 1, 1, 0)
  )

## Classify by class type
data <- data %>%
  mutate(
    classtype = case_when(
      SuperGentrified == 1 ~ 'super-gentrified',
      Gentrified == 1 & SuperGentrified == 0 ~ 'gentrified',
      HistoricallyAffluent == 1 ~ 'historically affluent',
      TRUE ~ 'not gentrified'
    )
  )
table(data$classtype)


#save data
data <- data %>% select(tr2020gj, CBSAFP, sort(setdiff(names(.), "tr2020gj")))
write.csv(data, file = "metrotracts_gentscores_2020tr.csv", na="", row.names = FALSE)

