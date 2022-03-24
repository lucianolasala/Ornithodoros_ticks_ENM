##### Calibration area (M) consist of ecoregions in area of interest where O. turicata has been recorded

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

library("readr")
library("sf")
library("tidyverse")
library("raster")
library("udunits2")

# Set working dir

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 


# O. turicata occurrences


Ornithodoros <- read_csv("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/Ornithodoros_DB.csv")  # readr::rerad_csv function imports data into R as a tibble
head(Ornithodoros)
class(Ornithodoros)
colnames(Ornithodoros)

st_crs(Ornithodoros)  # No CRS

# Subset and save shp files for each species

turicata <- filter(Ornithodoros, Especie == "Ornithodoros turicata")

turicata <- Ornithodoros[which(Ornithodoros$Especie == "Ornithodoros turicata"), ]

head(turicata)
class(turicata)
length(turicata$Especie)  # 141 records
colnames(turicata)

# Create a CRS object to define the CRS of our sf object

ticks_crs <- st_crs(4326)  # Set or replace retrieve coordinate reference system from object 
st_crs(ticks_crs)
class(ticks_crs)  # crs

# Need to convert our "non-spatial" flat file to a spatially explicit file
# Need to specify columns containing coordinates and the CRS that the column coordinate represent

turicata_df <- st_as_sf(turicata, coords = c("Long", "Lat"), crs = ticks_crs)  # turicata has Long, Lat columns, whoch are transformed to "geometry" column through sf
class(turicata_df)
head(turicata)
colnames(turicata)
length(turicata_df$Especie)

plot(turicata_df$geometry, col = "blue")  # Como es un objeto sf, el plot tiene que llamar a la columna "geometry", que reemplaza a las Long/Lat de un archivo tradicional

st_write(turicata_df, "C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg", driver = "gpkg")

# Double check the CRS to make sure it is correct

st_crs(turicata_df)  # Check that there exist a CRS

is.data.frame(turicata_df)  # Check that it's a dataframe
head(turicata_df)  # Display first records. It says: Simple feature collection with 6 features (rows) and 14 fields (columns)


#------------------------------------------------------------------------------------
# Extracting ecoregions for O. turicata
#------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

turicata1 <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")

class(turicata1)  # Loads as tibble
head(turicata1)
colnames(turicata1)
length(turicata1$Especie)

turicata2 <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")
class(turicata2)  # Loads as sf dataframe
head(turicata2)

turicata_df <- as.data.frame(sf::st_coordinates(turicata2))  # retrieve coordinates in matrix form
head(turicata_df)

colnames(turicata_df) <- c("Long", "Lat")  # Name columns Long and Lat
head(turicata_df)
length(turicata_df$Long)


#------------------------------------------------------------------------------------
# Load ecorregions of the world
#------------------------------------------------------------------------------------

# st_read reads shapefile with ecoregions of the world and transforms into simple feature data frame 

eco_world <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/World ecoregions/wwf_terr_ecos.gpkg")
eco_world <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/World ecoregions/World_ecoregions_fixed_final.gpkg")

class(eco_world)  # Check objet class
head(eco_world)  # Show first six records
str(eco_world)  # Display structure of the data frame
colnames(eco_world)


valid = st_is_valid(eco_world)
length(valid)

which(valid=="FALSE") # 1 (no. 1526)
which(valid=="TRUE")  # 14457

valid[1526]  # FALSE. This appears to be the invalid geometry

st_make_valid(eco_world)
str(eco_world)
corrupt = eco_world[1526, ]
corrupt

eco_world_fix <- eco_world[!(eco_world$ECO_NAME=="Guianan moist forests"),]

length(eco_world_fix$OBJECTID)

length(eco_world$OBJECTID)

head(eco_world_fix)
class(eco_world_fix)

eco_world_fix[1526, ]

class(eco_world_fixed)

st_write(eco_world_fix, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/World ecoregions/World_ecoregions_fixed.gpkg", driver = "gpkg")


#------------------------------------------------------------------------------------
# Intersect between world ecorregions and O. turicata occurrences 1
#------------------------------------------------------------------------------------

# Create a points collection
# The do.call function executes a function by its name (here, "st_sfc") and a list of 
# corresponding arguments. 
# st_sfc = Create simple feature geometry list column (la columna "geometry" de sf dataframe)
# st_point = Create simple feature from a numeric vector, matrix or list
# lapply() es un caso especial de apply(), diseñado para aplicar funciones a todos 
# los elementos de una lista (de alli la letra "l")
# Referencia para lapply: https://bookdown.org/jboscomendoza/r-principiantes4/lapply.html

# turicata_df is "data.frame" and needs to be transformed into "sf" for further spatial operations

turicata_sf <- do.call("st_sfc", c(lapply(1:nrow(turicata_df),  
                       function(i) {
                       st_point(as.numeric(turicata_df[i, ]))}), list("crs" = 4326))) 

head(turicata_sf)
class(turicata_sf)  # "sfc_POINT" "sfc"

#turicata_trans <- st_transform(turicata_sf, 4326) # Transform or convert coordinates of simple feature
#head(turicata_trans)

#eco_trans <- st_transform(eco_world, 4326)        # Transform or convert coordinates of simple feature
#head(eco_trans)

# Intersect and extract ecoregion name

sf::sf_use_s2(TRUE)

turicata_df$Ecoregion <- apply(st_intersects(eco_world, turicata_sf, sparse = FALSE), MARGIN = 2,
                               function(eco) { 
                                 eco_world[which(eco), ]$ECO_NAME
                               })

head(turicata_df)

#library(s2)

turicata_df
class(turicata_df)
length(turicata_df$Ecoregion)  # 141

# Subset unique ecorregion names

unique_eco <- turicata_df[!duplicated(turicata_df[3]), ]
length(unique_eco$Ecoregion)  # 30
class(unique_eco)

# Save as csv

write.csv(unique_eco, file = "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/Unique_ecoregions_turicata.csv")

# Load ecoregions saved as csv

unique_eco <- read.csv(file = "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/Unique_ecoregions_turicata.csv", sep = ",")
unique_eco

unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion, ]

plot(unique_eco_map$geom)

class(unique_eco_map)
str(unique_eco_map)
unique_eco_map$ECO_NAME

st_write(unique_eco_map, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg", driver = "gpkg")


#-------------------------------------------------------------------------
# Disolve ecoregions for O. turicata
#-------------------------------------------------------------------------

install.packages("rgdal")
install.packages("rgeos")

turicata_dis <- readOGR("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg")

turicata_dis <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg")
class(turicata_dis)


turicata_dissolved <- rgeos::gUnaryUnion(turicata_dis)   # fc in rgeos pkg
class(turicata_dissolved)  # SpatialPolygons, no need to SpatialPolygonsDataFrame

str(turicata_dissolved)
plot(turicata_dissolved, col = "blue")

# The difference between SpatialPolygons and SpatialPolygonsDataFrame are the attributes 
# that are associated with the polygons. SpatialPolygonsDataFrames have additional information 
# associated with the polygon (e.g., site, year, individual, etc.) while SpatialPolygons contain 
# only the spatial information (vertices) about the polygon.

turicata_dissolved_spdf <- as(turicata_dissolved, "SpatialPolygonsDataFrame")

class(turicata_dissolved_spdf)
plot(turicata_dissolved_spdf)

str(turicata_dissolved)
slotNames(turicata_dissolved)

turicata_dissolved@polygons
turicata_dissolved@polygons %>% class()  # list
turicata_dissolved@polygons %>% length() # 1
turicata_dissolved@polygons[[1]] %>% class()
turicata_dissolved@polygons[[1]]@Polygons[[477]] %>% slotNames()  # list of length 1 with 477 elements


turicata_dissolved@plotOrder
turicata_dissolved@bbox
turicata_dissolved@proj4string

slotNames(turicata_dissolved_spdf)

turicata_dissolved_spdf@data

turicata_sf = st_as_sf(turicata_dissolved)      
class(turicata_sf)

st_write(turicata_sf, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg", driver = "gpkg")

writeOGR(turicata_dissolved, layer = "turicata_dissolved", "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_dissolved.shp", driver = "ESRI Shapefile")


#-------------------------------------------------------------------------
# Plot occurrences in M
#-------------------------------------------------------------------------

turicata_dissolved %<>% 
  st_as_sf(coords = c("Long", "Lat")) %>% 
  st_sf(crs = 4326)

turicata_dissolved


# Load O. turicara occurrences

turicata = st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")

turicata %<>% 
    st_as_sf(coords = c("Long", "Lat")) %<>%
    st_sf(crs = 4326)

p = ggplot() +   # Create a ggplot object
    geom_sf(data = turicata_dissolved) +
    geom_sf(data = turicata, color = "blue", size = 1.5)
p


#-------------------------------------------------------------------------
# Process environmental variables across M
#-------------------------------------------------------------------------

rm(list=ls(all=TRUE))
gc()

# Set wd to folder containing remote sensing variables

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_Teledeteccion/Calibration")  

files <- list.files(pattern = ".tif$", all.files = TRUE, full.names = TRUE)
length(files)  # 22

allrasters <- stack(files)
class(allrasters)  # "RasterStack"

# Load ecorregions polygon

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg")

# Mask raster stack using the vector. No need to crop beforehand since variables
# have already been cropped in GEE

vars_mask <- mask(allrasters, cal_area)
class(vars_mask)  # "RasterBrick"

ind_r_names <- names(vars_mask)
ind_r_names

plot(vars_mask[[1]])

individual_r <- unstack(vars_mask)  # Hay que hacer unmask para luego guardar cada raster individual
class(individual_r)  # list

plot(individual_r[[1]])

variables <- as.factor(c("Bulk_density_0cm_M","Bulk_density_10cm_M",
                         "dayLST_max_M",))

# Guardar como GTiff

for(i in 1:length(ind_r_names)) {
writeRaster(individual_r[[i]], filename = paste0("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_Teledeteccion/Calibration_mask/", ind_r_names[i]), format = "GTiff")
}

# Guardar como ascii

for(i in 1:length(ind_r_names)) {
  writeRaster(individual_r[[i]], filename = paste0("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_Teledeteccion/Calibration_ascii/", ind_r_names[i]), format = "ascii")
}

# Alternative approach to masking and saving each raster file

outfiles <- file.path("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/Alternativa", 
                      paste0(basename(tools::file_path_sans_ext(files)),
                      "_M.tif"))

for(i in seq_along(files)) {
  r <- mask(raster(files[i]), cal_area)
  writeRaster(r, filename = outfiles[i], overwrite = TRUE)
}


for(i in seq_along(files)) {
  cropped <- crop(raster(files[i]), cal_area)
  r <- mask(cropped, cal_area)
  writeRaster(r, filename = outfiles[i], overwrite = TRUE)
}


#------------------------------------------------------------------------
# Check spatial resolution and raster extent for M layers
#------------------------------------------------------------------------

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M")

files = list.files(pattern = ".asc$", all.files = TRUE, full.names = FALSE)
files

# Verify resolution and extent of rasters

setwd("~/Analyses/Ticks ENM/Modeling_Teledeteccion/Calibration_ascii")
files = list.files(pattern = ".asc$", all.files = TRUE, full.names = FALSE)
files
mytable <- NULL

for(i in 1:22){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable

write.csv(mytable, file = "Raster properties.csv")

xlsx::write.xlsx(mytable, file = "Raster_properties.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)


