## Calibration area (M) 
>This area consist of ecoregions in area of interest where O. turicata has been recorded.

### Load required packages
```r
if(!require(tidyverse)){
  install.packages("tidyverse")
}
if(!require(sf)){
  install.packages("sf")
}
if(!require(readr)){
  install.packages("readr")
}
if(!require(raster)){
  install.packages("raster")
}
if(!require(udunits2)){
  install.packages("udunits2")
}
if(!require(rgdal)){
  install.packages("rgdal")
}
if(!require(rgeos)){
  install.packages("rgeos")
}  
  
library("readr")
library("sf")
library("tidyverse")
library("raster")
library("udunits2")
library("rgdal")
library("rgeos")
```

#### Loading O. turicata occurrences
```r
Ornithodoros <- read_csv("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/Ornithodoros_DB.csv")  

# Subset and save shp files for O. turicata
turicata <- filter(Ornithodoros, Especie == "Ornithodoros turicata")

# Create a CRS object to define the CRS of our sf object
ticks_crs <- st_crs(4326)

# Convert "non-spatial" flat file to a spatially explicit file.
turicata_df <- st_as_sf(turicata, coords = c("Long", "Lat"), crs = ticks_crs)
st_write(turicata_df, "C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg", driver = "gpkg")
```

#### Extracting ecoregions for O. turicata
```r
turicata <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")
turicata_df <- as.data.frame(sf::st_coordinates(turicata))  
colnames(turicata_df) <- c("Long", "Lat")  
```

#### Load ecorregions of the world and select those with occurrences
```r
eco_world <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/World ecoregions/World_ecoregions_fixed_final.gpkg")
turicata_sf <- do.call("st_sfc", c(lapply(1:nrow(turicata_df), function(i) {
st_point(as.numeric(turicata_df[i, ]))}), list("crs" = 4326))) 
turicata_df$Ecoregion <- apply(st_intersects(eco_world, turicata_sf, sparse = FALSE), MARGIN = 2, function(eco) { 
eco_world[which(eco), ]$ECO_NAME
})

# Subset unique ecorregion names
unique_eco <- turicata_df[!duplicated(turicata_df[3]), ]
write.csv(unique_eco, file = "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/Unique_ecoregions_turicata.csv")

# Load ecoregions saved as geopackage
unique_eco <- read.csv(file = "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/Unique_ecoregions_turicata.csv", sep = ",")
unique_eco
unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion, ]
st_write(unique_eco_map, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg", driver = "gpkg")
```

#### Disolve ecoregions for O. turicata and save as shapefile and geopackage
```r
turicata_dis <- readOGR("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg")
turicata_dissolved <- rgeos::gUnaryUnion(turicata_dis)
turicata_dissolved_spdf <- as(turicata_dissolved, "SpatialPolygonsDataFrame")
turicata_sf <- st_as_sf(turicata_dissolved)      
st_write(turicata_sf, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg", driver = "gpkg")
writeOGR(turicata_dissolved, layer = "turicata_dissolved", "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_dissolved.shp", driver = "ESRI Shapefile")
```