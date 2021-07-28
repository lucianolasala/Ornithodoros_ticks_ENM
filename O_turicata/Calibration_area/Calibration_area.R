# Calibration area (M) consist of ecoregions in area of interest (i.e., Argentina) where O. turicata
# has been recorded

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

#------------------------------------------------------------------------------------
# O. turicata occurrences
#------------------------------------------------------------------------------------

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
length(turicata$Especie)
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


#s2_available = !inherits(try(sf_use_s2(TRUE), silent=TRUE), "try-error")
#s2_available

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
# Process 19 Bioclimatic variables across M
# First crop to extent and then mask
# Details: https://www.worldclim.org/data/bioclim.html
#-------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\Historial data\\WorldClim Bioclimatic variables_wc2.1_5m_bio")  # 19 WorldClim variables for whole world

files <- list.files(pattern = ".tif$", all.files = TRUE, full.names = TRUE)
length(files)  # 19

allrasters <- stack(files)
class(allrasters)  # "RasterStack"

# Load ecorregions polygon

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg")

# Crop raster stack with 19 variables using the vector

bioclim_crop <- crop(allrasters, cal_area)

str(bioclim_crop)
class(bioclim_crop)  # "RasterBrick"

plot(bioclim_crop[[1]])

# Mask raster stack with 19 variables using the vector

bioclim_mask <- mask(bioclim_crop, cal_area)
class(bioclim_mask)  # "RasterBrick"

plot(bioclim_mask[[1]])

individual_r <- unstack(bioclim_mask)
class(individual_r)  # list

plot(individual_r[[2]])

variables <- as.factor(c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6",
                         "Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13",
                         "Bio14","Bio15","Bio16","Bio17","Bio18","Bio19"))


for(i in 1:length(variables)) {
writeRaster(individual_r[[i]], filename = paste0("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/", variables[i]), format = "ascii")
}


# Alternative approach to masking and saving each raster file

outfiles <- file.path("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/Bioclim", 
                      paste0(basename(tools::file_path_sans_ext(files)),
                      "_M.tif"))

for(i in seq_along(files)) {
  r <- mask(raster(files[i]), cal_area)
  writeRaster(r, filename = outfiles[i], overwrite = TRUE)
}


#------------------------------------------------------------------------
# Check spatial resolution and raster extent for M layers
#------------------------------------------------------------------------

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M")

files = list.files(pattern = ".asc$", all.files = TRUE, full.names = FALSE)
files

# Verify resolution and extent of rasters

mytable <- NULL

for(i in 1:19){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable

write.csv(mytable, file = "Raster properties.csv")
xlsx::write.xlsx(mytable, file = "./Raster_properties.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)


#---------------------------------------------------------------------------------------
# PROCESSING OF WORLD CLIM MONTHLY CLIMATIC DATA

# There are monthly climate data for minimum, mean, and maximum temperature, precipitation, 
# solar radiation, wind speed, water vapor pressure, and for total precipitation.
# Temporal series: 1970-2000.
# Source: https://www.worldclim.org/data/worldclim21.html

# Note: Each layer represents the mean value for each month over the 1970-2000
# period. Then, one can apply a pixel-wise reduction functions (mean, min, max, etc.) 
# across layers to obtain summary statistics for each location (pixel) during this period. 
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Solar radiation: reduction using mean
#---------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_srad")

solar_rad = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
solar_rad

solar_rad_stack = stack(solar_rad)
class(solar_rad_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

solar_crop <- crop(solar_rad_stack, cal_area)

class(solar_crop)  # "RasterBrick"

plot(solar_crop[[1]])

# Mask

solar_mask <- raster::mask(solar_crop, cal_area)

class(solar_mask)  # "RasterBrick"

plot(solar_mask[[1]])

par(mfrow=c(1,2))
plot(solar_crop[[1]])
plot(solar_mask[[1]])

# Pixel-wise stats for raster brick 

solar_rad_mean = mean(solar_mask)
class(solar_rad_mean)  # "RasterLayer"


#--------------------------------------------------------------------------------
# Raster exploration
#--------------------------------------------------------------------------------

summary(solar_rad_mean@data@values)  # Stats for the single layer

cellStats(solar_rad_mean, stat = "mean")  # Summarizing the cell values of each (or only) layer
cellStats(solar_rad_mean, stat = "min")
cellStats(solar_rad_mean, stat = "max")
cellStats(solar_rad_mean, stat = "range")

# Now we can explore cell values at individual raster using index subsetting

which(!is.na(values(solar_rad_mean)))  # Extract cells that are not NA and select one

solar_rad_mean[18999]  # 12555.5  
solar_rad_min[18999]   # 3918 
solar_rad_max[18999]   # 21091
solar_rad_range[18999] # 17173

range = solar_rad_max[18999]-solar_rad_min[18999]
range

# Save output raster as ascii file

writeRaster(solar_rad_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/solar_rad_mean.asc", format = "GTiff", overwrite = TRUE)
writeRaster(solar_rad_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/solar_rad_mean.asc", format = "ascii", overwrite = TRUE)


#--------------------------------------------------------------------------------
# The raster stack can be unstacked as follows:
#--------------------------------------------------------------------------------

individual_solar <- unstack(solar_mask)
class(individual_solar)  # list

# Plotting same masked layers
par(mfrow=c(1,2))
plot(solar_mask[[1]])
plot(individual_solar[[1]])


#---------------------------------------------------------------------------------------
# Water vapor pressure (kPa): reduction using mean

# Note: Each layer represents the mean value for each month over the 1970-2000
# period. Then, one can apply a pixel-wise reduction functions (mean, min, max, etc.) 
# across layers to obtain summary statistics for each location (pixel) during this period. 
#---------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_vapr")

vapr = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
vapr

vapr_stack = stack(vapr)
class(vapr_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

vapr_crop <- crop(vapr_stack, cal_area)

class(vapr_crop)  # "RasterBrick"

plot(vapr_crop[[1]])

# Mask

vapr_mask <- raster::mask(vapr_crop, cal_area)

class(vapr_mask)  # "RasterBrick"

plot(vapr_mask[[1]])

par(mfrow=c(1,2))
plot(vapr_crop[[1]])
plot(vapr_mask[[1]])

# Pixel-wise stats for raster brick 

vapr_mean = mean(vapr_mask)
class(vapr_mean)  # "RasterLayer"

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(vapr_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/vapor_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(vapr_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/vapor_mean.tif", format = "GTiff", overwrite = TRUE)

#--------------------------------------------------------------------------------
# Minimum temperature (°C)

# Note: Each layer represents the minimum value for each month over the 1970-2000
# period. Then, one can apply a pixel-wise reduction functions (mean, min, max, etc.) 
# across layers to obtain summary statistics for each location (pixel) during this period.
#--------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_tmin")

tmin = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
tmin

tmin_stack = stack(tmin)
class(tmin_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

tmin_crop <- crop(tmin_stack, cal_area)

class(tmin_crop)  # "RasterBrick"

plot(tmin_crop[[1]])

# Mask

tmin_mask <- raster::mask(tmin_crop, cal_area)

class(tmin_mask)  # "RasterBrick"

plot(tmin_mask[[1]])

par(mfrow=c(1,2))
plot(tmin_crop[[1]])
plot(tmin_mask[[1]])

# Pixel-wise stats for raster brick 

tmin_mean = mean(tmin_mask)

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(tmin_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tmin_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(tmin_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tmin_mean.tif", format = "GTiff", overwrite = TRUE)

#--------------------------------------------------------------------------------
# Maximum temperature (°C)

# Note: Each layer represents the maximum value for each month over the 1970-2000
# period. Then, one can apply a pixel-wise reduction functions (mean, min, max, etc.) 
# across layers to obtain summary statistics for each location (pixel) during this period.
#--------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_tmax")

tmax = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
tmax

tmax_stack = stack(tmax)
class(tmax_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

tmax_crop <- crop(tmax_stack, cal_area)

class(tmax_crop)  # "RasterBrick"

plot(tmax_crop[[1]])

# Mask

tmax_mask <- raster::mask(tmax_crop, cal_area)

class(tmax_mask)  # "RasterBrick"

plot(tmax_mask[[1]])

par(mfrow=c(1,2))
plot(tmax_crop[[1]])
plot(tmax_mask[[1]])

# Pixel-wise stats for raster brick 

tmax_mean = mean(tmax_mask)

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(tmax_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tmax_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(tmax_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tmax_mean.tif", format = "GTiff", overwrite = TRUE)

#--------------------------------------------------------------------------------
# Average temperature (°C)

# Note: Each layer represents the average maximum value for each month over the 1970-2000
# period. Then, one can apply a pixel-wise reduction functions (mean, min, max, etc.) 
# across layers to obtain summary statistics for each location (pixel) during this period.
#--------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_tavg")

tavg = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
tavg

tavg_stack = stack(tavg)
class(tavg_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

tavg_crop <- crop(tavg_stack, cal_area)

class(tavg_crop)  # "RasterBrick"

plot(tavg_crop[[1]])

# Mask

tavg_mask <- raster::mask(tavg_crop, cal_area)

class(tavg_mask)  # "RasterBrick"

plot(tavg_mask[[1]])

par(mfrow=c(1,2))
plot(tavg_crop[[1]])
plot(tavg_mask[[1]])

# Pixel-wise stats for raster brick 

tavg_mean = mean(tavg_mask)

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(tavg_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tavg_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(tavg_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/tavg_mean.tif", format = "GTiff", overwrite = TRUE)

#--------------------------------------------------------------------------------
# Precipitation (mm)

# Note: Each layer represents the average precipitation value for each month over the 1970-2000
# period. Then, one can apply the mean as reduction function 
# across layers to obtain average value for each location (pixel) during this period.
#--------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_prec")

prec = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
prec

prec_stack = stack(prec)
class(prec_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

prec_crop <- crop(prec_stack, cal_area)

class(prec_crop)  # "RasterBrick"

plot(prec_crop[[1]])

# Mask

prec_mask <- raster::mask(prec_crop, cal_area)

class(prec_mask)  # "RasterBrick"

plot(prec_mask[[1]])

par(mfrow=c(1,2))
plot(prec_crop[[1]])
plot(prec_mask[[1]])

# Pixel-wise stats for raster brick 

prec_mean = mean(prec_mask)

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(prec_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/prec_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(prec_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/prec_mean.tif", format = "GTiff", overwrite = TRUE)

#--------------------------------------------------------------------------------
# Wind speed (m s-1)

# Note: Each layer represents the average wind speed value for each month over the 1970-2000
# period. Then, one can apply the mean as reduction function 
# across layers to obtain average value for each location (pixel) during this period.
#--------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_wind")

wind = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
wind

wind_stack = stack(wind)
class(wind_stack)  # "RasterStack"

# Crop by extent 

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg") 

wind_crop <- crop(wind_stack, cal_area)

class(wind_crop)  # "RasterBrick"

plot(wind_crop[[1]])

# Mask

wind_mask <- raster::mask(wind_crop, cal_area)

class(wind_mask)  # "RasterBrick"

plot(wind_mask[[1]])

par(mfrow=c(1,2))
plot(wind_crop[[1]])
plot(wind_mask[[1]])

# Pixel-wise stats for raster brick 

wind_mean = mean(wind_mask)

#--------------------------------------------------------------------------------
# Raster exportation
#--------------------------------------------------------------------------------

# Save output rasters as ascii files

writeRaster(wind_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/wind_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(wind_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/wind_mean.tif", format = "GTiff", overwrite = TRUE)
