#This script joins tabular and spatial data, then publishes a webmap via Mapbox API

if (!require(dplyr)) install.packages("dplyr")
if (!require(here)) install.packages("here")
if (!require(stringr)) install.packages("stringr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(mapboxapi)) install.packages("mapboxapi")
if (!require(mapgl)) install.packages("mapgl")
if (!require(sf)) install.packages("sf")
if (!require(httr)) install.packages("httr")

library(dplyr)
library(here)
library(stringr)
library(ggplot2)
library(mapboxapi)
library(sf)
library(httr)


# set environment
here::i_am("03_spatial/map_publishtoweb_2020tr.r")

# load data 
## tabular data
data <- read.csv(here("01_data/metrotracts_gentscores_2020tr.csv")) %>%
  select(tr2020gj, 
         CBSAFP, 
         Bach_pct_chg_1990to2020,
         classtype, 
         ConRent_mean_chg_1990to2020,
         GentIntensity_1990,
         GentIntensity_2000,
         GentIntensity_2010,
         GentIntensity_2010,
         GentIntensity_1990to2000,
         GentIntensity_2000to2010,
         GentIntensity_2010to2020,
         GentIntensity_1990to2020,
         Gentrified,
         HHIncome_mean_chg_1990to2020,
         HistoricallyAffluent,
         HouseValue_mean_chg_1990to2020,
         Poverty_pct_chg_1990to2020,
         Population_sum_1990,
         Population_sum_2020,
         SuperGentrified,
         WhiteCollar_pct_chg_1990to2020) %>%
  rename(GISJOIN = tr2020gj) 


## convert to units of std dev
variables <- data %>%
  select(starts_with("GentIntensity")) %>%
  names()
for (var in variables) {
  mean <- mean(data[[var]], na.rm = TRUE)
  sd <- sd(data[[var]], na.rm = TRUE)
  name <- paste0(var, "_sdfrommean")
  data[[name]] <- (data[[var]] - mean) / sd
}


# spatial data
st_layers(here("03_spatial/tract_boundaries.gpkg"))
boundaries <- st_read(dsn = here("03_spatial/tract_boundaries.gpkg"), 
                      layer = "tracts_highres_2020tr") %>%
  mutate(STATE2  = str_pad(STATEFP,  width = 2, side = "left", pad = "0"),
         COUNTY4 = str_pad(COUNTYFP, width = 4, side = "left", pad = "0"),
         TRACT7  = str_pad(TRACTCE,  width = 7, side = "left", pad = "0"),
         GISJOIN = paste0("G", STATE2, COUNTY4, TRACT7)) %>%
  select(-c(STATE2, COUNTY4, TRACT7))

## join the dataframes
map_data <- boundaries %>%
  inner_join(data, by = "GISJOIN")


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
           COUNTYFP == "061")
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
token = "a secret mapbox token"
username = "your mapbox username"
tileset_id = "backend data name"
tileset_name = "display name"
mts_list_tilesets(username = username, access_token = token)

## prep data for upload
map_data <- st_make_valid(map_data)
map_data <- st_transform(x = map_data, crs = 4326)

## create source
mts_create_source(data = map_data, 
                  tileset_id = tileset_id, 
                  username = username, 
                  access_token = token)

## define tileset recipe
tract_layer <- recipe_layer(
  source = paste0("mapbox://tileset-source/", username, "/", tileset_id),
  minzoom = 5, 
  maxzoom = 12,
  tiles = tile_options(layer_size = 2500))

recipe <- mts_make_recipe(tract_layer)
layer <- recipe$layers[[1]]
recipe$layers <- list(gentintensity_1990to2020 = layer)
str(recipe)

mts_validate_recipe(recipe = recipe, 
                    access_token = token)

## create tileset
mts_create_tileset(tileset_name = tileset_id,
                   username = username,
                   recipe = recipe,
                   access_token = token)

## upload content
mts_publish_tileset(tileset_name = tileset_id,
                    username = username, 
                    access_token = token)

## rename the tileset
PATCH(
  url = paste0("https://api.mapbox.com/tilesets/v1/", username, ".", tileset_id),
  query = list(access_token = token),
  body = list(name = tileset_name),
  encode = "json"
)

