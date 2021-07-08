
Calibration area (M) consist of ecoregions in area of interest (i.e., Argentina) where O. turicata has been recorded

#### Load required packages and libraries

```r
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

library("readr")
library("sf")
library("tidyverse")
library("raster")

# Set working dir

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 
```

#### *O. turicata* occurrences

```r
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
```

#### Extracting ecoregions for *O. turicata*

```r
rm(list=ls(all=TRUE))

turicata1 <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")

class(turicata1)  # Loads as tibble
head(turicata1)
colnames(turicata1)
length(turicata1$Especie)

turicata2 <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Ocurrencias/O_turicata.gpkg")
class(turicata2)  # Loads as sf dataframe
head(turicata2)

turicata_df <- as.data.frame(sf::st_coordinates(turicata1))  # retrieve coordinates in matrix form
head(turicata_df)

colnames(turicata_df) <- c("Long", "Lat")  # Name columns Long and Lat
head(turicata_df)
length(turicata_df$Long)
```

#### Load ecorregions of the world

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

turicata_sf <- do.call("st_sfc", c(lapply(1:nrow(turicata_df), 
                       function(i) {
                       st_point(as.numeric(turicata_df[i, ]))}), list("crs" = 4326))) 

head(turicata_sf)
class(turicata_sf)  # "sfc_POINT" "sfc"

turicata_trans <- st_transform(turicata_sf, 4326) # Transform or convert coordinates of simple feature
head(turicata_trans)

eco_trans <- st_transform(eco_world, 4326)        # Transform or convert coordinates of simple feature
head(eco_trans)

# Intersect and extract ecoregion name

sf::sf_use_s2(TRUE)

turicata_df$Ecoregion <- apply(st_intersects(eco_trans, turicata_trans, sparse = FALSE), 2,
                         function(col) { 
                         eco_trans[which(col), ]$ECO_NAME
                         })

s2_available = !inherits(try(sf_use_s2(TRUE), silent=TRUE), "try-error")
s2_available

library(s2)

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

class(unique_eco_map)
str(unique_eco_map)
unique_eco_map$ECO_NAME

st_write(unique_eco_map, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg", driver = "gpkg")


#-------------------------------------------------------------------------
# Intersect between world ecorregions and O. turicata occurrences 2
#-------------------------------------------------------------------------

install.packages("cleangeo")

eco_world = readOGR("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/World ecoregions/wwf_terr_ecos.gpkg")
slotNames(eco_world)

eco_cleaned <- clgeo_Clean(eco_world, errors.only = NULL, strategy = "POLYGONATION", verbose = FALSE)
class(eco_cleaned)  # sp
head(eco_cleaned)

writeOGR(eco_cleaned, layer = "eco_cleaned", "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_ecoregions_cleaned.shp", driver = "ESRI Shapefile")

turicata_eco = turicata1[eco_world, ]

eco_world_sf = st_as_sf(eco_world)      
class(eco_world_sf)

st_write(eco_world_sf, "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_dissolved_fix.gpkg", driver = "gpkg")


writeOGR(eco_world, layer = "eco_world", "C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/Ecoregions/turicata_ecoregions_fixed.shp", driver = "ESRI Shapefile")


#-------------------------------------------------------------------------
# Disolve ecoregions for O. turicata
#-------------------------------------------------------------------------

turicata_dis <- readOGR("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg")

turicata_dis <- st_read("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_ecoregions.gpkg")
class(turicata_dis)


turicata_dissolved <- rgeos::gUnaryUnion(turicata_dis)   # fc in rgeos pkg
class(turicata_dissolved)  # Need to convert SpatialPolygon to SpatialPolygonsDataFrame

turicata_dissolved <- as(turicata_dissolved, "SpatialPolygonsDataFrame")
class(turicata_dissolved)
plot(turicata_dissolved)

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
    st_as_sf(coords = c("Long","Lat")) %<>%
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

setwd("C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\Historial data\\WorldClim Bioclimatic variables_wc2.1_5m_bio")

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

# How to save cropped rasters as raster brick

writeRaster(bioclim_crop, filename = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/BioClim_M.tif"), format = "GTiff", overwrite = TRUE, options=c("INTERLEAVE=BAND","COMPRESS=LZW"))


# Mask

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
writeRaster(individual_r[[i]], filename = paste0("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/Bio_", variables[i]), format = "ascii")
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

cal_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_M/turicata_dissolved.gpkg")

solar_mask <- raster::mask(solar_crop, cal_area)

class(solar_mask)  # "RasterBrick"

plot(solar_mask[[1]])

par(mfrow=c(1,2))
plot(solar_crop[[1]])
plot(solar_mask[[1]])

# Pixel-wise stats for raster brick 

solar_rad_mean = mean(solar_mask)
class(solar_rad_mean)  # "RasterLayer"

solar_rad_min = min(solar_mask)
solar_rad_max = max(solar_mask)
solar_rad_range = max(solar_mask)-min(solar_mask)

# Agregar standard deviation

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


# Save output rasters as GTiff files

writeRaster(solar_rad_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/solar_rad_mean.asc", format = "ascii", overwrite = TRUE)
writeRaster(solar_rad_min, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/solar_rad_min.asc", format = "ascii", overwrite = TRUE)
writeRaster(solar_rad_max, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/solar_rad_max.asc", format = "ascii", overwrite = TRUE)
writeRaster(solar_rad_range, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/solar_rad_range.asc", format = "ascii", overwrite = TRUE)


#--------------------------------------------------------------------------------
# The raster stack can be unstacked as follows:
#--------------------------------------------------------------------------------

individual_solar <- unstack(solar_mask)
class(individual_solar)  # list

# Plotting same masked layers
par(mfrow=c(1,2))
plot(solar_mask[[1]])
plot(individual_solar[[1]])