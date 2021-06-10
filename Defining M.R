# Load required packages

## Installing the package devtools

rm(list=ls(all=TRUE))

install.packages("devtools")

## kuenm
devtools::install_github("marlonecobos/kuenm")

rm(list=ls(all=TRUE))

if(!require(tidyverse)){
  install.packages("tidyverse")
}

if(!require(sf)){
  install.packages("sf")
}

if(!require(stars)){
  install.packages("stars")
}

if(!require(devtools)){
  install.packages("devtools")
}

if(!require(readr)){
  install.packages("readr")
}


setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 

#------------------------------------------------------------------------------------
# O. turicata occurrences
#------------------------------------------------------------------------------------

Ornithodoros <- read_csv("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/Ornithodoros_DB.csv")
head(Onnithodoros)
class(Ornithodoros)

st_crs(Onnithodoros)  # No CRS

# Subset and save shp files for each species

turicata <- filter(Ornithodoros, Especie == "Ornithodoros turicata")
head(turicata)
class(turicata)
length(turicata$Especie)

# Create a CRS object to define the CRS of our sf object

ticks_crs <- st_crs(4326)
st_crs(ticks_crs)
class(ticks_crs)  # crs

# Alternatively: st_crs(sfc) = 4326

# Convert our non-spatial flat file
# Need to specify columns containing coordinates and the CRS that the column coordinate represent

turicata <- st_as_sf(turicata, coords = c("Long", "Lat"), crs = ticks_crs)
class(turicata)

st_write(turicata, "C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg", driver = "gpkg", overwrite = TRUE)

# Double check the CRS to make sure it is correct

st_crs(turicata)

is.data.frame(turicata)
head(turicata)


#------------------------------------------------------------------------------------
# Extracting ecoregions for O. turicata
#------------------------------------------------------------------------------------

turicata_df <- as.data.frame(sf::st_coordinates(turicata))  
colnames(turicata_df) <- c("Long", "Lat")
head(turicata_df)
length(turicata_df$Long)


#------------------------------------------------------------------------------------
# Load ecorregions of the world
#------------------------------------------------------------------------------------

eco_world <- st_read("C:/Users/User/Documents/Shapefiles y rasters/WWF Ecoregions of the World/official/wwf_terr_ecos.shp")
class(eco_world)
head(eco_world)
str(eco_world)

#------------------------------------------------------------------------------------
# Intersect
#------------------------------------------------------------------------------------

# Create a points collection

turicata_sf <- do.call("st_sfc", c(lapply(1:nrow(turicata_df), 
                                     function(i) {st_point(as.numeric(turicata_df[i, ]))}), list("crs" = 4326))) 

turicata_trans <- st_transform(turicata_sf, 4326) # Apply transformation to pnts sf
eco_trans <- st_transform(eco_world, 4326)        # Apply transformation to polygons sf

# Intersect and extract ecoregion name
turicata_df$Ecoregion <- apply(st_intersects(eco_trans, turicata_trans, sparse = FALSE), 2, 
                     function(col) { 
                       eco_trans[which(col), ]$ECO_NAME
                     })
turicata_df
class(turicata_df)
length(turicata_df$Ecoregion)  # 138

# Subset unique ecorregion names

unique_eco <- turicata_df[!duplicated(turicata_df[3]),]
length(unique_eco$Ecoregion)  # 30
class(unique_eco)

# Save as csv

write.csv(unique_eco, file = "./Vector data/Ecoregions/Unique_ecoregions_turicata.csv")

# Load ecoregions saves as csv

unique_eco <- read.csv(file = "./Shapefiles/Unique_eco_turicata.csv", sep = ",")
unique_eco

unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion, ]
class(unique_eco_map)
str(unique_eco_map)
unique_eco_map$ECO_NAME


st_write(unique_eco_map, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_ecoregions.shp", driver = "ESRI Shapefile")

# Disolve ecoregions for O. turicata

turicata_dis <- readOGR("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_ecoregions.shp")

turicata_dissolved <- rgeos::gUnaryUnion(turicata_dis)   # fc in rgeos pkg
class(turicata_dissolved)  # Need to convert SpatialPolygon to SpatialPolygonsDataFrame

turicata_dissolved <- as(turicata_dissolved, "SpatialPolygonsDataFrame")
class(turicata_dissolved)
plot(turicata_dissolved)

writeOGR(turicata_dissolved, layer = "turicata_dissolved", "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_dissolved.shp", driver = "ESRI Shapefile")

# Plot occurrences

turicata_dissolved %<>% 
  st_as_sf(coords = c("Long", "Lat")) %>% 
  st_sf(crs = 4326)

turicata_dissolved

# Load O. turicara occs

turicata = st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")

turicata %<>% 
    st_as_sf(coords = c("Long","Lat")) %<>%
    st_sf(crs = 4326)

p = ggplot() + # Create a ggplot object
    geom_sf(data = turicata_dissolved) +
    geom_sf(data = turicata, color = "blue", size = 1.5)
    

p

