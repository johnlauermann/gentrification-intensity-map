#This script joins tabular and spatial data, then publishes a web map via Mapbox API

if (!require(dplyr)) install.packages("dplyr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(mapboxapi)) install.packages("mapboxapi")
if (!require(sf)) install.packages("sf")

library(dplyr)
library(ggplot2)
library(mapboxapi)
library(sf)

# set environment
wd <- getwd()
setwd(wd)
setwd('../') # moving up one directory level, since this script is stored in a subfolder

# load data 
## tabular data
data <- read.csv("02_data_historic/metrotracts_gentscores_2010tr.csv") %>%
  rename(GISJOIN = tr2010gj)

## spatial stata
st_layers("03_spatial/tract_boundaries.gpkg")
boundaries <- st_read(dsn = "03_spatial/tract_boundaries.gpkg", 
                      layer = "metrotracts_2010tr")


# join the dataframes
map_data <- boundaries %>%
  left_join(data, by = "GISJOIN")


# view a map, just to verify
## first we'll query one region of data just to keep it manageable
northeast <- map_data %>%
  filter(STATEFP10 == "09" | STATEFP10 == "23" | STATEFP10 == "25" | STATEFP10 == "33" | 
           STATEFP10 == "36" | STATEFP10 == "44" | STATEFP10 == "50")

ggplot(data = northeast) +  # defines the plot space
  geom_sf(aes(fill = FAC_1970to2020), color = NA) +  # viz type = map
  coord_sf(crs = "ESRI:102010") +   # a relevant map projection for the region
  scale_fill_gradient2(low = "blue",   # color ramp
                       mid = "gray70", 
                       high = "red", 
                       midpoint = 0,
                       name = "Intensity Score") +
  labs(          
    title = "Gentrification Intensity, 1970 to 2020", # add text
    caption = "Source: github.com/johnlauermann/gentrification-intensity-map",
  ) + 
  theme_minimal()  # choose a theme

## and try a single county
Manhattan <- map_data %>%
  filter(STATEFP10 == "36" & COUNTYFP10 == "061")
ggplot(data = Manhattan) +
  geom_sf(aes(fill = FAC_1970to2020), color = NA) +  
  coord_sf(crs = "EPSG:32618") +  
  scale_fill_gradient2(low = "blue", 
                       mid = "gray70", 
                       high = "red", 
                       midpoint = 0,
                       name = "Intensity Score") +
  labs(          
    title = "Gentrification Intensity, 1970 to 2020", 
    caption = "Source: github.com/johnlauermann/gentrification-intensity-map",
  ) + 
  theme_minimal()  # choose a theme


# publish to Mapbox
## set up parameters
token = "your private token"
username = "your username"

## upload data
upload_tiles(
  input = map_data,
  username = username,
  access_token = token,
  tileset_id = "gentscores_2010tr",
  tileset_name = "gentrification_intensity_index_1970to2020", 
  multipart = TRUE, 
)
