# Calibration area (M) consist of ecoregions in area of interest where 
# O. coriaceus has been recorded

# Load required packages

rm(list=ls(all=TRUE))

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

# Set working dir

setwd("D:/Trabajo/Analisis/MNE_garrapatas") 

#------------------------------------------------------------------------------------
# O. coriaceus occurrences
#------------------------------------------------------------------------------------

Ornithodoros <- read_csv("D:/LFLS/Analyses/MNE_garrapatas/Ocurrencias/Ornithodoros_DB.csv")  # readr::rerad_csv function imports data into R as a tibble
head(Ornithodoros)
class(Ornithodoros)
colnames(Ornithodoros)

st_crs(Ornithodoros)  # No CRS

# Subset and save shp files for each species

coriaceus <- dplyr::filter(Ornithodoros, Especie == "Ornithodoros coriaceus")

coriaceus <- Ornithodoros[which(Ornithodoros$Especie == "Ornithodoros coriaceus"), ]

head(coriaceus)
class(coriaceus)
length(coriaceus$Especie)  # 18 records
colnames(coriaceus)

# Keep only species, longitude and latitude columns
occs <- coriaceus[,c(2,9,10)]
head(occs)

write.csv(occs, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Occs/O_coriaceus.csv", row.names = FALSE)

# Create a CRS object to define the CRS of our sf object

ticks_crs <- st_crs(4326)  # Set or replace retrieve coordinate reference system from object 
st_crs(ticks_crs)
class(ticks_crs)  # crs

# Need to convert our "non-spatial" flat file to a spatially explicit file
# Need to specify columns containing coordinates and the CRS that the column coordinate represent

coriaceus_df <- st_as_sf(coriaceus, coords = c("Long", "Lat"), crs = ticks_crs)  # turicata has Long, Lat columns, which are transformed to "geometry" column through sf
class(coriaceus_df)
head(coriaceus_df)
colnames(coriaceus_df)
length(coriaceus_df$Especie)

plot(coriaceus_df$geometry, col = "blue")  # Como es un objeto sf, el plot tiene que llamar a la columna "geometry", que reemplaza a las Long/Lat de un archivo tradicional

st_write(coriaceus_df, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Occs/O_coriaceus.gpkg", driver = "gpkg")

# Corregí en QGIS coordenadas de uno punto que cae fuera de las ecorregiones, así que
# a continuación levanto ese nuevo jpgk para seguir trabajando

# Double check the CRS to make sure it is correct


st_crs(coriaceus_df)  # Check that there exist a CRS

is.data.frame(coriaceus_df)  # Check that it's a dataframe
head(coriaceus_df)  # Display first records. It says: Simple feature collection with 6 features (rows) and 14 fields (columns)


#------------------------------------------------------------------------------------
# Extracting ecoregions for O. coriaceus
#------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

coriaceus1 <- read_sf("D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Occs/O_coriaceus.gpkg")
class(coriaceus1)  # Loads as tbl_df
length(coriaceus1$Especie)

coriaceus2 <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Occs/O_coriaceus.gpkg")
class(coriaceus2)  # Loads as sf dataframe
head(coriaceus2)

coriaceus_df <- as.data.frame(sf::st_coordinates(coriaceus2))  # retrieve coordinates in matrix form
head(coriaceus_df)

colnames(coriaceus_df) <- c("Long", "Lat")  # Name columns Long and Lat
head(coriaceus_df)
length(coriaceus_df$Long)  # 50


#------------------------------------------------------------------------------------
# Load ecorregions of the world
#------------------------------------------------------------------------------------

# st_read reads shapefile with ecoregions of the world and transforms into simple feature data frame 

eco_world <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/World ecoregions/World_ecoregions_fixed_final.gpkg")

class(eco_world)  # Check objet class
head(eco_world)  # Show first six records
colnames(eco_world)

valid = st_is_valid(eco_world)
length(valid)

which(valid=="FALSE") # 0. No hay geometrias invalidas 
which(valid=="TRUE")  # 14449

#------------------------------------------------------------------------------------
# Intersect between world ecorregions and O. coriaceus occurrences 1
#------------------------------------------------------------------------------------

# Create a points collection.
# The do.call function executes a function by its name (here, "st_sfc") and a list of 
# corresponding arguments. 
# st_sfc = Create simple feature geometry list column (la columna "geometry" de sf dataframe)
# st_point = Create simple feature from a numeric vector, matrix or list
# lapply() es un caso especial de apply(), diseñado para aplicar funciones a todos 
# los elementos de una lista (de alli la letra "l")
# Referencia para lapply: https://bookdown.org/jboscomendoza/r-principiantes4/lapply.html

# turicata_df is "data.frame" and needs to be transformed into "sf" for further spatial operations

coriaceus_sf <- do.call("st_sfc", c(lapply(1:nrow(coriaceus_df),  
                                          function(i) {
                                            st_point(as.numeric(coriaceus_df[i, ]))}), list("crs" = 4326))) 

head(coriaceus_sf)
class(coriaceus_sf)  # "sfc_POINT" "sfc"

# Intersect and extract ecoregion name

sf::sf_use_s2(TRUE)

coriaceus_df$Ecoregion <- apply(st_intersects(eco_world, coriaceus_sf, sparse = FALSE), MARGIN = 2,
                               function(eco) { 
                                 eco_world[which(eco), ]$ECO_NAME
                               })

head(coriaceus_df)

coriaceus_df
class(coriaceus_df)
length(coriaceus_df$Ecoregion)  # 50

# Subset unique ecorregion names

unique_eco <- coriaceus_df[!duplicated(coriaceus_df[3]),]
length(unique_eco$Ecoregion)  # 13
class(unique_eco)

# Save as csv

write.csv(unique_eco, file = "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/Unique_ecoregions_coriaceus.csv")

# Load ecoregions saved as csv

unique_eco <- read.csv(file = "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/Unique_ecoregions_coriaceus.csv", sep = ",")
unique_eco

unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion,]

plot(unique_eco_map$geom)

class(unique_eco_map)
str(unique_eco_map)
unique_eco_map$ECO_NAME

st_write(unique_eco_map, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/coriaceus_ecoregions.gpkg", driver = "gpkg")

#-------------------------------------------------------------------------
# Dissolve ecoregions for O. coriaceus
#-------------------------------------------------------------------------

coriaceus_dis <- readOGR("D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/coriaceus_ecoregions.gpkg")
class(coriaceus_dis)

coriaceus_dissolved <- rgeos::gUnaryUnion(coriaceus_dis)   # fc in rgeos pkg
class(coriaceus_dissolved)  # SpatialPolygons, no need to SpatialPolygonsDataFrame

plot(coriaceus_dissolved, col = "blue")

# The difference between SpatialPolygons and SpatialPolygonsDataFrame are the attributes 
# that are associated with the polygons. SpatialPolygonsDataFrames have additional information 
# associated with the polygon (e.g., site, year, individual, etc.) while SpatialPolygons contain 
# only the spatial information (vertices) about the polygon.

coriaceus_dissolved_spdf <- as(coriaceus_dissolved, "SpatialPolygonsDataFrame")

class(coriaceus_dissolved_spdf)
plot(coriaceus_dissolved_spdf)

slotNames(coriaceus_dissolved)

coriaceus_dissolved@polygons
coriaceus_dissolved@polygons %>% class()  # list
coriaceus_dissolved@polygons %>% length() # 1
coriaceus_dissolved@polygons[[1]] %>% class()
coriaceus_dissolved@polygons[[1]]@Polygons[[1]] %>% slotNames()  # list of length 1 with 477 elements

coriaceus_dissolved@proj4string

class(coriaceus_dissolved_spdf)
slotNames(coriaceus_dissolved_spdf)

coriaceus_sf = st_as_sf(coriaceus_dissolved)      
class(coriaceus_sf)

st_write(coriaceus_sf, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/M_coriaceus_dissolved.gpkg", driver = "gpkg")

writeOGR(coriaceus_dissolved_spdf, layer = "M_coriaceus_dissolved", "D:/LFLS/Analyses/MNE_garrapatas/Modelado_coriaceus/Vectors/M_coriaceus_dissolved.shp", driver = "ESRI Shapefile")




