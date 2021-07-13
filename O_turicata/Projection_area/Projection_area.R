# Projection areas (G) consist of ecoregions in area of interest (i.e., Argentina) where O. turicata
# has not been recorded

# Load required packages

rm(list=ls(all=TRUE))

if(!require(tidyverse)){
  install.packages("tidyverse")
}

if(!require(sf)){
  install.packages("sf")
}

if(!require(raster)){
  install.packages("raster")
}

if(!require(readr)){
  install.packages("readr")
}

if(!require(magrittr)){
  install.packages("magrittr")
}

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 

#-------------------------------------------------------------------------
# Process 19 Bioclimatic variables across G
# First crop to extent and then mask
# Details: https://www.worldclim.org/data/bioclim.html
#-------------------------------------------------------------------------

rm(list=ls(all=TRUE))

files <- list.files(path = "C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\Historial data\\WorldClim Bioclimatic variables_wc2.1_5m_bio", 
                    pattern = ".tif$", all.files = TRUE, full.names = TRUE)
length(files)  # 19


# Load Argentina polygon

proj_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_G/O_turicata_projection.gpkg")
str(proj_area)
plot(proj_area$geom)

allrasters <- stack(files)
class(allrasters)  # "RasterStack"

# Crop raster stack with 19 variables using the vector

bioclim_crop <- crop(allrasters, proj_area)

str(bioclim_crop)
class(bioclim_crop)  # "RasterBrick"

plot(bioclim_crop[[1]])

# How to save cropped rasters as raster brick

writeRaster(bioclim_crop, filename = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/BioClim_M.tif"), format = "GTiff", overwrite = TRUE, options=c("INTERLEAVE=BAND","COMPRESS=LZW"))

# Mask

bioclim_mask <- mask(bioclim_crop, proj_area)
class(bioclim_mask)  # "RasterBrick"

plot(bioclim_mask[[1]])

individual_r <- unstack(bioclim_mask)
class(individual_r)  # list

plot(individual_r[[2]])

variables <- as.factor(c("Bio1","Bio2","Bio3","Bio4","Bio5","Bio6",
                         "Bio7","Bio8","Bio9","Bio10","Bio11","Bio12","Bio13",
                         "Bio14","Bio15","Bio16","Bio17","Bio18","Bio19"))


for(i in 1:length(variables)) {
  writeRaster(individual_r[[i]], filename = paste0("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Projection_G/", variables[i]), format = "ascii")
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

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Projection_G")

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
# Solar radiation: 12 rasters (one for each month over the period 1970-2000). 
# Reduction using mean
#---------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/Historial data/WorldClim_monthly climate data/wc2.1_5m_srad")

solar_rad = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
solar_rad

solar_rad_stack = stack(solar_rad)
class(solar_rad_stack)  # "RasterStack"

# Crop raster stack with 19 variables using the vector 

proj_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_G/O_turicata_projection.gpkg") 
plot(proj_area$geom)

solar_crop <- crop(solar_rad_stack, proj_area)

class(solar_crop)  # "RasterBrick"

plot(solar_crop[[1]])

# Mask

solar_mask <- raster::mask(solar_crop, proj_area)

class(solar_mask)  # "RasterBrick"

plot(solar_mask[[1]])

par(mfrow=c(1,2))
plot(solar_crop[[1]])
plot(solar_mask[[1]])

# Pixel-wise stats for raster brick 

solar_rad_mean = mean(solar_mask)
class(solar_rad_mean)  # "RasterLayer"

#solar_rad_min = min(solar_mask)
#solar_rad_max = max(solar_mask)
#solar_rad_range = max(solar_mask)-min(solar_mask)


#--------------------------------------------------------------------------------
# Raster exploration
#--------------------------------------------------------------------------------

summary(solar_rad_mean@data@values)  # Stats for the single layer

cellStats(solar_rad_mean, stat = "mean")  # Summarizing the cell values of each (or only) layer

# Now we can explore cell values at individual raster using index subsetting

which(!is.na(values(solar_rad_mean)))  # Extract cells that are not NA and select one

solar_rad_mean[4657]  # 19010.67  
#solar_rad_min[4657]   # 13752 
#solar_rad_max[4657]   # 24367
#solar_rad_range[4657] # 10615

#range = solar_rad_max[4657]-solar_rad_min[4657]
#range  # 10615

# Save output rasters as GTiff files

writeRaster(solar_rad_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Projection_G/solar_rad_mean.asc", format = "ascii", overwrite = TRUE)

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

# Save output rasters as GTiff files

writeRaster(vapr_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/vapor_mean.asc", format = "ascii", overwrite = TRUE)


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

# Save output rasters as GTiff files

writeRaster(tmin_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/tmin_mean.asc", format = "ascii", overwrite = TRUE)


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

# Save output rasters as GTiff files

writeRaster(tmax_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/tmax_mean.asc", format = "ascii", overwrite = TRUE)


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

# Save output rasters as GTiff files

writeRaster(tavg_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/tavg_mean.asc", format = "ascii", overwrite = TRUE)


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

# Save output rasters as GTiff files

writeRaster(prec_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/prec_mean.asc", format = "ascii", overwrite = TRUE)


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

# Save output rasters as GTiff files

writeRaster(wind_mean, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/wind_mean.asc", format = "ascii", overwrite = TRUE)



