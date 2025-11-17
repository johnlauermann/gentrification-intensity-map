#This script:
##1) Generates class upgrading and class status scores based on factor analysis
##2) Classifies gentrified tracts based on factor scores

if (!require(dplyr)) install.packages("dplyr")
if (!require(psych)) install.packages("psych")
if (!require(tidyverse)) install.packages("tidyverse")

library(dplyr)
library(psych)
library(tidyverse)

# set environment
wd <- getwd()
setwd(wd)


#set up the data for large metros over 1mn residents
##identify variables of interest
variables <- c("Bach_pct",
               "ConRent_mean",
               "HHIncome_mean",
               "HouseValue_mean",
               "Population_sum",
               "Poverty_pct",
               "WhiteCollar_pct")
pattern <- paste(variables, collapse = "|")

##load and filter data
data <- read_csv("metrotracts_data_2010tr.csv") %>%
  select(tr2010gj, CBSAFP, matches(pattern))


#factor analysis for decadal change scores
class_upgrading_score <- function(data, startyear, endyear){
  
  ## define variables
  variables <- c(paste0("Bach_pct_chg_", startyear, "to", endyear),
                 paste0("ConRent_mean_chg_", startyear, "to", endyear),
                 paste0("HHIncome_mean_chg_", startyear, "to", endyear),
                 paste0("HouseValue_mean_chg_", startyear, "to", endyear),
                 paste0("Poverty_pct_chg_", startyear, "to", endyear),
                 paste0("WhiteCollar_pct_chg_", startyear, "to", endyear))
 
   ##Calculate factor scores
  fa_result <- principal(data[variables], nfactors = 1, rotate = "varimax", scores = TRUE, 
                         missing = TRUE, method = "cor", impute = "mean")
  data[[paste0("FAC_", startyear, "to", endyear)]] <- fa_result$scores[,1]
  
  ##create reports
  kmo_result <- KMO(data[variables])
  bartlett_result <- cortest.bartlett(cor(na.omit(data)[variables]), n = nrow(data))
  communalities <- fa_result$communality
  total_variance_explained <- fa_result$Vaccounted
  component_matrix <- fa_result$loadings
  
  ##print results
  cat("\nGentrification Intensity Score for", startyear, "to", endyear, "\n")
  print(kmo_result)
  print(bartlett_result)
  print(fa_result)
  print(communalities)
  print(total_variance_explained)
  print(component_matrix)
  
  ##return updated dataframe
  return(data)
  
}

#factor analysis for decade crosssectional scores
class_status_score <- function(data, year){
  
  ## define year and variables
  variables <- c(paste0("Bach_pct_", year),
                 paste0("ConRent_mean_", year),
                 paste0("HHIncome_mean_", year),
                 paste0("HouseValue_mean_", year),
                 paste0("Poverty_pct_", year),
                 paste0("WhiteCollar_pct_", year))
  
  ##Calculate factor scores
  fa_result <- principal(data[variables], nfactors = 1, rotate = "varimax", scores = TRUE, 
                         missing = TRUE, method = "cor", impute = "mean")
  data[[paste0("FAC_", year)]] <- fa_result$scores[,1]
  
  ##create reports
  kmo_result <- KMO(data[variables])
  bartlett_result <- cortest.bartlett(cor(na.omit(data)[variables]), n = nrow(data))
  communalities <- fa_result$communality
  total_variance_explained <- fa_result$Vaccounted
  component_matrix <- fa_result$loadings
  
  ##print results
  cat("\nClass Status Score for", year, "\n")
  print(kmo_result)
  print(bartlett_result)
  print(fa_result)
  print(communalities)
  print(total_variance_explained)
  print(component_matrix)
  
  ##return updated dataframe
  return(data)
  
}


#run analyses for each decade and decadal pair
data <- class_upgrading_score(data, 1970, 1980)
data <- class_upgrading_score(data, 1980, 1990)
data <- class_upgrading_score(data, 1990, 2000)
data <- class_upgrading_score(data, 2000, 2010)
data <- class_upgrading_score(data, 2010, 2020)
data <- class_upgrading_score(data, 1970, 2020)
data <- class_status_score(data, 1970)
data <- class_status_score(data, 1980)
data <- class_status_score(data, 1990)
data <- class_status_score(data, 2000)
data <- class_status_score(data, 2010)
data <- class_status_score(data, 2020)


#classify tracts based on scores
##Aggregate factor scores by metro
data <- data %>%
  group_by(CBSAFP) %>% 
  mutate(
    metro_FAC_1970 = mean(FAC_1970),
    metro_FAC_1970to1980 = mean(FAC_1970to1980),
    metro_FAC_1980 = mean(FAC_1980),
    metro_FAC_1980to1990 = mean(FAC_1980to1990),
    metro_FAC_1990 = mean(FAC_1990),
    metro_FAC_1990to2000 = mean(FAC_1990to2000),
    metro_FAC_2000 = mean(FAC_2000),
    metro_FAC_2000to2010 = mean(FAC_2000to2010),
    metro_FAC_2010 = mean(FAC_2010),
    metro_FAC_2010to2020 = mean(FAC_2010to2020),
    metro_FAC_2020 = mean(FAC_2020)
  ) %>%
  ungroup()

##Identify middle class tracts with factor scores, controlling to remove any small tracts (less than 100 people)
data <- data %>%
  mutate(
    MiddleorUpperClass_1970 = ifelse((FAC_1970 >= metro_FAC_1970) & (Population_sum_1970 >= 100), 1, 0),
    MiddleorUpperClass_1980 = ifelse((FAC_1980 >= metro_FAC_1980) & (Population_sum_1980 >= 100), 1, 0),
    MiddleorUpperClass_1990 = ifelse((FAC_1990 >= metro_FAC_1990) & (Population_sum_1990 >= 100), 1, 0),
    MiddleorUpperClass_2000 = ifelse((FAC_2000 >= metro_FAC_2000) & (Population_sum_2000 >= 100), 1, 0),
    MiddleorUpperClass_2010 = ifelse((FAC_2010 >= metro_FAC_2010) & (Population_sum_2010 >= 100), 1, 0),
    MiddleorUpperClass_2020 = ifelse((FAC_2020 >= metro_FAC_2020) & (Population_sum_2020 >= 100), 1, 0)
  )

##Identify tracts with above average class upgrading
data <- data %>%
  mutate(
    Gentrifying_70to80 = ifelse((FAC_1970to1980 >= metro_FAC_1970to1980) & (Population_sum_1970 >= 100), 1, 0),
    Gentrifying_80to90 = ifelse((FAC_1980to1990 >= metro_FAC_1980to1990) & (Population_sum_1980 >= 100), 1, 0),
    Gentrifying_90to00 = ifelse((FAC_1990to2000 >= metro_FAC_1990to2000) & (Population_sum_1990 >= 100), 1, 0),
    Gentrifying_00to10 = ifelse((FAC_2000to2010 >= metro_FAC_2000to2010) & (Population_sum_2000 >= 100), 1, 0),
    Gentrifying_10to20 = ifelse((FAC_2010to2020 >= metro_FAC_2010to2020) & (Population_sum_2010 >= 100), 1, 0)
  )

##Identify gentrified tracts
data <- data %>%
  mutate(
    Gentrified_70to80 = ifelse((MiddleorUpperClass_1970 == 0) & 
                                 (Gentrifying_70to80 == 1) & 
                                 (MiddleorUpperClass_1980 == 1) & 
                                 (Population_sum_1970 >= 100), 1, 0),
    Gentrified_80to90 = ifelse((MiddleorUpperClass_1970 == 0 | MiddleorUpperClass_1980 == 0) & 
                                 (Gentrifying_80to90 == 1) & 
                                 (MiddleorUpperClass_1990 == 1) &
                                 (Population_sum_1980 >= 100), 1, 0),
    Gentrified_90to00 = ifelse((MiddleorUpperClass_1970 == 0 | MiddleorUpperClass_1980 == 0 | MiddleorUpperClass_1990 == 0) & 
                                 (Gentrifying_90to00 == 1) & 
                                 (MiddleorUpperClass_2000 == 1) &
                                 (Population_sum_1990 >= 100), 1, 0),
    Gentrified_00to10 = ifelse((MiddleorUpperClass_1970 == 0 | MiddleorUpperClass_1980 == 0 | MiddleorUpperClass_1990 == 0 | MiddleorUpperClass_2000 == 0) & 
                                 (Gentrifying_00to10 == 1) & 
                                 (MiddleorUpperClass_2010 == 1) &
                                 (Population_sum_2000 >= 100), 1, 0),
    Gentrified_10to20 = ifelse((MiddleorUpperClass_1970 == 0 | MiddleorUpperClass_1980 == 0 | MiddleorUpperClass_1990 == 0 | MiddleorUpperClass_2000 == 0 | MiddleorUpperClass_2010 == 0) & 
                                 (Gentrifying_10to20 == 1) & 
                                 (MiddleorUpperClass_2020 == 1) &
                                 (Population_sum_2010 >= 100), 1, 0)
    )
data <- data %>%
  mutate(Gentrified = ifelse(Gentrified_70to80 == 1 | Gentrified_80to90 == 1 | Gentrified_90to00 == 1 | Gentrified_00to10 == 1 | Gentrified_10to20 == 1, 1, 0))
table(data$Gentrified)

## Identify super-gentrification with factor scores
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
table(data$SuperGentrified)

## Identify historically affluent with factor scores
data <- data %>%
  mutate(
    HistoricallyAffluent = ifelse((MiddleorUpperClass_1970 == 1 & MiddleorUpperClass_1980 == 1 & MiddleorUpperClass_1990 == 1 & MiddleorUpperClass_2000 == 1 & MiddleorUpperClass_2010 == 1 & MiddleorUpperClass_2020 == 1) & 
                                    Gentrified == 0 & 
                                    SuperGentrified == 0 & 
                                    Population_sum_1970 >= 100, 1, 0)
  )
table(data$HistoricallyAffluent)

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


#save tabular data
data <- data %>% select(tr2010gj, CBSAFP, sort(setdiff(names(.), "tr2010gj")))
write.csv(data, file = "metrotracts_gentscores_2010tr.csv", na="", row.names = FALSE)
