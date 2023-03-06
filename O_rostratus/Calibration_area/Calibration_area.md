## Calibration area (M) 
>This area consist of ecoregions in area of interest where *O. rostratus* has been recorded.

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
```

#### Loading *O. rostratus* occurrences
```r
Ornithodoros <- read_csv("D:/LFLS/Analyses/MNE_garrapatas/Ocurrencias/Ornithodoros_DB.csv")  # readr::rerad_csv function imports data into R as a tibble

# Subset and save shp files for each species
rostratus <- dplyr::filter(Ornithodoros, Especie == "Ornithodoros rostratus")

# Keep only species, longitude and latitude columns
occs <- rostratus[,c(2,9,10)]

write.csv(occs, "D:/LFLS/Analyses/MNE_garrapatas/Ocurrencias/O_rostratus.csv", row.names = FALSE)

# Create a CRS object to define the CRS of our sf object
ticks_crs <- st_crs(4326) 

# Convert "non-spatial" flat file to a spatially explicit file.
rostratus_df <- st_as_sf(rostratus, coords = c("Long", "Lat"), crs = ticks_crs)  

st_write(rostratus_df, "D:/Trabajo/Analisis/MNE_garrapatas/Modelado_rostratus/Occs/O_rostratus.gpkg", driver = "gpkg")
```

#### Extracting ecoregions for *O. rostratus*
```r
rostratus <- st_read("D:/Trabajo/Analisis/MNE_garrapatas/Modelado_rostratus/Occs/O_rostratus.gpkg")
rostratus_df <- as.data.frame(sf::st_coordinates(rostratus)  
colnames(rostratus_df) <- c("Long", "Lat")  
```

#### Load ecorregions of the world and select those with occurrences
```r
eco_world <- st_read("D:/Trabajo/Analisis/MNE_garrapatas/Vector data/World ecoregions/World_ecoregions_fixed_final.gpkg")
rostratus_sf <- do.call("st_sfc", c(lapply(1:nrow(rostratus_df),  
                                          function(i) {  st_point(as.numeric(rostratus_df[i, ]))}), list("crs" = 4326))) 

# Intersect and extract ecoregion name

sf::sf_use_s2(TRUE)

rostratus_df$Ecoregion <- apply(st_intersects(eco_world, rostratus_sf, sparse = FALSE), MARGIN = 2,
function(eco) { 
eco_world[which(eco), ]$ECO_NAME
})

# Subset unique ecorregion names
unique_eco <- rostratus_df[!duplicated(rostratus_df[3]),]

# Save as csv
write.csv(unique_eco, file = "D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/Unique_ecoregions_rostratus.csv")

# Load ecoregions saved as csv
unique_eco <- read.csv(file = "D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/Unique_ecoregions_rostratus.csv", sep = ",")
unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion,]
st_write(unique_eco_map, "D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/rostratus_ecoregions.gpkg", driver = "gpkg")
```

#### Disolve ecoregions for O. rostratus and save as shapefile and geopackage
```r
rostratus_dis <- readOGR("D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/rostratus_ecoregions.gpkg")
rostratus_dissolved <- rgeos::gUnaryUnion(rostratus_dis)   

rostratus_dissolved_spdf <- as(rostratus_dissolved, "SpatialPolygonsDataFrame")

st_write(rostratus_sf, "D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/rostratus_dissolved.gpkg", driver = "gpkg")

writeOGR(rostratus_dissolved_spdf, layer = "rostratus_dissolved", "D:/Trabajo/Analisis/MNE_garrapatas/Vector data/O_rostratus_M/rostratus_dissolved.shp", driver = "ESRI Shapefile")
```