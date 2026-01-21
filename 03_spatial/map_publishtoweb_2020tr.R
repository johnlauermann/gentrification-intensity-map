#This script joins tabular and spatial data, then publishes a webmap via Mapbox API

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(mapboxapi)) install.packages("mapboxapi")
if (!require(mapgl)) install.packages("mapgl")
if (!require(sf)) install.packages("sf")

library(dplyr)
library(here)
library(ggplot2)
library(mapboxapi)
library(sf)

# set environment
here::i_am("03_spatial/map_publishtoweb_2020tr.r")

# load data 
## tabular data
data <- read.csv(here("01_data/metrotracts_gentscores_2020tr.csv")) %>%
  rename(GISJOIN = tr2020gj)

## spatial data
st_layers(here("03_spatial/tract_boundaries.gpkg"))
boundaries <- st_read(dsn = here("03_spatial/tract_boundaries.gpkg"), 
                      layer = "metrotracts_2020tr")


# join the dataframes
map_data <- boundaries %>%
  left_join(data, by = "GISJOIN")


# view a map, just to verify
## first we'll query one region of data just to keep it manageable
northeast <- map_data %>%
  filter(STATEFP == "09" | STATEFP == "23" | STATEFP == "25" | STATEFP == "33" | 
           STATEFP == "36" | STATEFP == "44" | STATEFP == "50")

ggplot(data = northeast) +  # defines the plot space
  geom_sf(aes(fill = GentIntensity_1990to2020), color = NA) +  # viz type = map
  coord_sf(crs = "ESRI:102010") +   # a relevant map projection for the region
  scale_fill_gradient2(low = "blue",   # color ramp
                       mid = "gray70", 
                       high = "red", 
                       midpoint = 0,
                       name = "Intensity Score") +
  labs(          
    title = "Gentrification Intensity, 1990 to 2020", # add text
    caption = "Source: github.com/johnlauermann/gentrification-intensity-map",
  ) + 
  theme_minimal()  # choose a theme

## and try a single county
Manhattan <- map_data %>%
  filter(STATEFP == "36" &
           COUNTYFP == "61")
ggplot(data = Manhattan) +
  geom_sf(aes(fill = GentIntensity_1990to2020), color = NA) +  
  coord_sf(crs = "EPSG:32618") +  
  scale_fill_gradient2(low = "blue", 
                       mid = "gray70", 
                       high = "red", 
                       midpoint = 0,
                       name = "Intensity Score") +
  labs(          
    title = "Gentrification Intensity, 1990 to 2020", 
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
  tileset_id = "gentscores_2020tr",
  tileset_name = "gentrification_intensity_index_1990to2020", 
  multipart = TRUE, 
)
