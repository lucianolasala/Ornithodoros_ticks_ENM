# Projection areas (G) consist of ecoregions in area of interest (i.e., Argentina) where O. turicata
# has not been recorded

# Load required packages

## Installing the package devtools

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

if(!require(magrittr)){
  install.packages("magrittr")
}

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 


#-------------------------------------------------------------------------
# Crop G across all variables
#-------------------------------------------------------------------------

rm(list=ls(all=TRUE))

files <- list.files(path = "C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\Historial data\\WorldClim Bioclimatic variables_wc2.1_5m_bio", 
                    pattern = ".tif$", all.files = TRUE, full.names = TRUE)
length(files)  # 19


# Load Argentina polygon

proj_area <- read_sf("C:/Users/User/Documents/Analyses/Ticks ENM/Vector data/O_turicata_G/O_turicata_projection.gpkg")
str(proj_area)
plot(proj_area$geom)



# Mask raster stack with 19 variables using the vector

outfiles <- file.path("C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\O_turicata\\Projection_historical", 
                      paste0(basename(tools::file_path_sans_ext(files)),
                      "_G.tif"))

for(i in seq_along(files)) {
  r <- mask(raster(files[i]), proj_area)
  writeRaster(r, filename = outfiles[i], overwrite = TRUE)
}


#------------------------------------------------------------------------
# Check spatial resolution and raster extent for M layers
#------------------------------------------------------------------------

setwd("C:\\Users\\User\\Documents\\Analyses\\Ticks ENM\\Raster data\\O_turicata\\Projection_historical")

files = list.files(pattern = ".tif$", all.files = TRUE, full.names = FALSE)
length(files)
files

# Verify resolution and extent of rasters

mytable <- NULL

for(i in 1:19){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable

xlsx::write.xlsx(mytable, file = "./Raster_properties.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)



