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
sp_sites <- st_as_sf(site_data, coords = c("long_dec", "lat_dec"), crs = 4326)


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


# EXTRACT SOIL PROPERTIES FOR USA POINTS
## Filter data set to USA points (non PR & USVI)
us_sites <- filter(site_data, site.country == "United States" & 
                     site.state != "US Virgin Islands" & 
                     site.state != "Puerto Rico") %>%
  st_as_sf(coords = c("long_dec", "lat_dec"), crs = 4326)

## Read in 100m rasters (to 60 cm)
### Paper found here: https://arxiv.org/pdf/1705.08323.pdf
soc <- raster("data/SoilGrids/100m/soc_M_sl5_100m.tif")     # %
bd <- raster("data/SoilGrids/100m/bd_M_sl5_100m.tif")       # g cm-3, of <2mm
clay <- raster("data/SoilGrids/100m/clay_M_sl5_100m.tif")   # %
ph <- raster("data/SoilGrids/100m/ph_h2o_M_sl5_100m.tif")   # pH * 10 in 1:1 soil-H2O
sand <- raster("data/SoilGrids/100m/sand_M_sl5_100m.tif")   # %

## Extract values and clean up data space
us_sites <- as(us_sites,"Spatial") %>% 
  raster::extract(soc,.) %>%
  cbind(us_sites) %>%
  raster::extract(bd,.) %>%
  cbind(us_sites) %>%
  raster::extract(clay,.) %>%
  cbind(us_sites) %>%
  raster::extract(ph,.) %>%
  cbind(us_sites) %>%
  raster::extract(sand,.) %>%
  cbind(us_sites)
names(us_sites)[1:5] <- c("SOC","BD","Clay","pH","Sand")

rm(soc); rm(bd); rm(clay); rm(ph); rm(sand)


# EXTRACT SOIL PROPERTIES FOR NON-US POINTS
## Filter data set to non-US points
non.us_sites <- filter(site_data, site.country != "United States" | 
                         (site.country == "United States" & 
                            (site.state == "Puerto Rico" | site.state == "US Virgin Islands"))) %>%
  st_as_sf(coords = c("long_dec", "lat_dec"),crs = 4326)

## Read in 250m rasters (to 60 cm)
soc <- raster("data/SoilGrids/250m/ORCDRC_M_sl5_250m.tif")  # g kg-1, fine earth
bd <- raster("data/SoilGrids/250m/BLDFIE_M_sl5_250m.tif")   # kg m-3
clay <- raster("data/SoilGrids/250m/CLYPPT_M_sl5_250m.tif") # % 0-2 um
ph <- raster("data/SoilGrids/250m/PHIHOX_M_sl5_250m.tif")   # pH in H2O, reported as pH * 10
sand <- raster("data/SoilGrids/250m/SNDPPT_M_sl5_250m.tif") # % 50-2000 um

## Extract values and clean up data space
non.us_sites <- as(non.us_sites,"Spatial") %>% 
  raster::extract(soc,.) %>%
  cbind(us_sites) %>%
  raster::extract(bd,.) %>%
  cbind(us_sites) %>%
  raster::extract(clay,.) %>%
  cbind(us_sites) %>%
  raster::extract(ph,.) %>%
  cbind(us_sites) %>%
  raster::extract(sand,.) %>%
  cbind(us_sites)
names(non.us_sites)[1:5] <- c("SOC","BD","Clay","pH","Sand")

rm(soc); rm(bd); rm(clay); rm(ph); rm(sand)

## Merge data sets and clean up data space
sp_sites <- rbind(us_sites, non.us_sites)

rm(us_sites); rm(non.us_sites); rm(site_data); rm(countries)
