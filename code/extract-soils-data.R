#####################################################
# Retrieve SoilGrids data for meta-analysis points  #
# Author: Stephen Wood                              #
# Last updated: June 2018                           #
#####################################################


# LOAD PACKAGES
library(tidyverse)  # For data manipulation
library(sf)         # For spatial points objects
library(raster)     # For SoilGrids raster data


# READ IN DATA
site_data <- read_csv("data/site-data.csv")
countries <- rnaturalearth::ne_countries(scale = 110, type = "countries", continent = NULL,
                            country = NULL, geounit = NULL, sovereignty = NULL,
                            returnclass = "sf")


# CONVERT POINTS TO SPATIAL CLASS
sp_sites <- st_as_sf(site_data, coords = c("long_dec","lat_dec"), crs=4326)


# PLOT LOCATIONS
plot(
  st_geometry(countries),
  border="grey70"
)
plot(
  st_geometry(sp_sites),
  pch=20,
  cex=0.5,
  col="blue",
  add=T
)


# EXTRACT SOIL PROPERTIES FOR THE US POINTS
## Filter data set to US points
### Do I need to filter out Puerto Rico?
us_sites <- filter(site_data,site.country=="United States") %>%
  st_as_sf(coords = c("long_dec", "lat_dec"),crs = 4326)

## Extract SOC values
soc <- raster("data/SoilGrids/100m/soc_M_sl4_100m.tif")   # What units?
us_sites <- as(us_sites,"Spatial") %>% 
  raster::extract(soc,.) %>%
  cbind(us_sites)
names(us_sites)[1] <- "SOC"


# EXTRACT SOIL PROPERTIES FOR NON-US POINTS
## Filter data set to non-US points
non.us_sites <- filter(site_data,site.country!="United States") %>%
  st_as_sf(coords = c("long_dec", "lat_dec"),crs = 4326)
