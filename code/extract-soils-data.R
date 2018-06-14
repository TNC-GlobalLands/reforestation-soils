#####################################################
# Retrieve SoilGrids data for meta-analysis points  #
# Author: Stephen Wood                              #
# Last updated: June 2018                           #
#####################################################


# LOAD PACKAGES
library(tidyverse)  # For data manipulation
library(sf)         # For spatial objects

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

# 