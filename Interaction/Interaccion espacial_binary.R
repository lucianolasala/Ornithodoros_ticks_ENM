#-----------------------------------------------------------------------
# Analisis de solapamiento entre MNE de garrapatas y jabali
#-----------------------------------------------------------------------

rm(list=ls())

library(raster)
library(sf)
library(magrittr)
library(dplyr)
library(writexl)

#--------------------------------------------------
# Recorte y enmascarmiento del MNE de rostratus
#--------------------------------------------------

a <- st_read("D:/CIC/Analisis/MNE_garrapatas/ENM_ticks/Vector_data/Mapas politicos/ARG_adm/ARG_adm0.shp")
rostratus <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaccion/ENM_ticks/Modelado_rostratus/Ciclo_3/M_G_merged_rasters/Final_O.rostratus_MSS.tif")

masked <- crop(rostratus, a) %>% mask(a); plot(masked)

writeRaster(masked, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_rostratus.tif")

#--------------------------------------------------
# Check extent and resolution ticks layers
#--------------------------------------------------

setwd("D:/CIC/Analisis/MNE_garrapatas/Interaction")

files <-list.files("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin", pattern = ".tif$", full.names = TRUE); files

mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 16)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
is.matrix(mytable)
mytable_df <- as.data.frame(mytable)

# Notes: Compared to O. turicata:  
# O. rostratus has slightly different y resolution and different extent
# O. coriaceus has slightly different y resolution

write_xlsx(mytable_df, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Raster_props/Rasters_props.xlsx")


#----------------------------------------------------------  
# Load O. rostratus and make it the same as O. turicata
#----------------------------------------------------------

rm(list=ls())

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif")  
rostratus <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_rostratus.tif") 
rostratus_resample <- resample(rostratus, turicata, method = "ngb") 

# Extent comparisons
turicata_ext <- turicata@extent; turicata_ext
rostratus_resample_ext <- rostratus_resample@extent; rostratus_resample_ext

# Resolution comparisons
turicata_resol <- res(turicata); turicata_resol
rostratus_resol <- res(rostratus_resample); rostratus_resol

# Check resolution
if(rostratus_resol[1] == turicata_resol[1] & rostratus_resol[2] == turicata_resol[2]){
  print("X and Y are equal")
} else {
  print("There is a difference")
}

# New O. rostratus raster has identical extent and resolution

# Check extent
if(turicata_ext[1] == rostratus_resample_ext[1] & 
   turicata_ext[2] == rostratus_resample_ext[2] &
   turicata_ext[3] == rostratus_resample_ext[3] &
   turicata_ext[4] == rostratus_resample_ext[4]){
  print("xmin, xmax, ymin, ymax are equal")
} else {
  print("There is a difference in raster extent")
}

writeRaster(rostratus_resample, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp_ticks/O_rostratus.tif", overwrite = T)


#----------------------------------------------------------  
# Load O. coriaceus and make it the same as O. turicata
#----------------------------------------------------------

rm(list=ls())

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif")
coriaceus <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_coriaceus.tif") 
coriaceus_resample <- resample(coriaceus, turicata, method = "ngb") 

# Extent comparisons
turicata_ext <- turicata@extent; turicata_ext
coriaceus_resample_ext <- coriaceus_resample@extent; coriaceus_resample_ext

# Resolution comparisons
turicata_resol <- res(turicata); turicata_resol
coriaceus_resol <- res(coriaceus_resample); coriaceus_resol

if(coriaceus_resol[1] == turicata_resol[1] & coriaceus_resol[2] == turicata_resol[2]){
  print("X and Y are equal")
} else {
  print("There is a difference")
}

# New O. coriaceus raster has identical extent and resolution

writeRaster(coriaceus_resample, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp_ticks/O_coriaceus.tif", overwrite=TRUE)


#-----------------------------------------------------------------------
# Llevar modelo de jabali y garrapatas a misma resolucion
#-----------------------------------------------------------------------

rm(list=ls())

wb <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/S_scrofa.tif")
resol_wb <- res(wb); resol_wb
extent_wb <- wb@extent; extent_wb

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif")
resol_turicata <- res(turicata); resol_turicata
extent_turicata <- turicata@extent; extent_turicata

wb_resample <- resample(wb, turicata, method = 'ngb')

resol_wb_resample <- res(wb_resample); resol_wb_resample

wb_resampled_alt <- raster::disaggregate(wb, fact = 10, fun = max)  # Alternative
resol_wb_res_alt <- res(wb_resampled2); resol_wb_res_alt

writeRaster(wb_resample, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp_wb/S_scrofa.tif", overwrite = TRUE)


#------------------------------------------------------------------------
# Check spatial resolution and raster extent for all layers
#------------------------------------------------------------------------

rm(list=ls())

path = ("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp") 

files <- list.files(path = path, pattern = ".tif$", full.names = TRUE)
files

mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 16)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable
mytable <- as.data.frame(mytable)

# Note: all layers have the same resolution and extent


#----------------------------------------------------------------------
# Extract values for overlapping presence pixels between wild boars  
# and each tick species 
#----------------------------------------------------------------------

rm(list = ls())

setwd("D:/CIC/Analisis/MNE_garrapatas/Interaction")

path = ("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp_ticks")
files <- list.files(path = path, pattern = ".tif$", full.names = TRUE); files
wb <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin_resamp_ticks_wb/S_scrofa.tif")

for(i in 1:length(files)){
  r <- raster(files[i])
  overlap <- wb*r
  writeRaster(overlap, filename = paste(getwd(), "/Rasters/Overlap/", basename(files[i]), "_overlap", sep = ''), format = "GTiff", overwrite=TRUE)
}


#-------------------------------------------------------------------------------
# Calculo de areas de solapamiento
#-------------------------------------------------------------------------------

rm(list = ls())

files <- list.files("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap", pattern = ".tif$", full.names = TRUE); files

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap/O_turicata.tif_overlap.tif")
tot_suit <- sum(values(turicata == 1), na.rm = TRUE)*100 

tot_area <- c()
tot_suit <- c()
tot_unsuit <- c()
perc_suit <- c()

for(i in 1:length(files)){
  r <- raster(files[i])
  
  tot_area[i] <- sum(values(r == 1)|values(r == 0), na.rm = TRUE)
  tot_suit[i] <- sum(values(r == 1), na.rm = TRUE)
  tot_unsuit[i] <- sum(values(r == 0), na.rm = TRUE)
  perc_suit[i] <- round((tot_suit[i]/tot_area[i])*100, 2)
  
  print(tot_area[i])
  print(tot_suit[i])
  print(tot_unsuit[i])
  print(perc_suit[i])
}

Species <- c("O. coriaceus","O. rostratus","O. turicata")

table <- data.frame(Species, tot_area, tot_suit, tot_unsuit, perc_suit) %>%
  mutate(across(where(is.numeric), ~ round(., 1)))
table

write.csv(table, "D:/CIC/Analisis/MNE_garrapatas/InteracTion/Tables/Overlap_ticks_wb.csv")


#-------------------------------------------------------------------------------
# Farm data processing
#-------------------------------------------------------------------------------

# Creacion de raster vacio con dimensiones del resto

rm(list=ls(all=TRUE))

pkgs <- c("raster","rgdal","leaflet","sf","ggplot2")

sapply(pkgs, function(x) library(x, character.only = TRUE)) 

options(digits = 16)
options(max.print = 1000)

# Explore dim, resol and ext of one raster

molde <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif") 
dim(molde); molde@extent; res(molde)

# Use parameters above for new raster
arg_ras <- raster(ncol = 2339, nrow = 3837, 
                  xmn = -74.003213106, 
                  xmx = -52.99161861, 
                  ymn = -55.461985642, 
                  ymx = -20.993628189605)

values(arg_ras) <- 1:ncell(arg_ras)  # Asign values to cells
hasValues(arg_ras)
summary(arg_ras@data@values)
dim(arg_ras)

writeRaster(arg_ras, filename = "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Farms_BS3_bin/Raster_empty", format = "GTiff", overwrite = TRUE)

#-----------------------------------------------------------------------
# Carga de poligono tipo SpatialPolygonsDataFrame para area de estudio
#-----------------------------------------------------------------------

arg_poly <- st_read("D:/CIC/Analisis/MNE_garrapatas/ENM_ticks/Vector_data/Mapas politicos/ARG_adm/ARG_adm0.shp")

arg_raster <- mask(arg_ras, arg_poly)
plot(arg_raster)

summary(arg_raster@data@values)  # Min 531 to max 83860, with 50203 NAs after masking


# Raster tiene NA por fuera, y dato por dentro
# Reemplazo no NA's por ceros

arg_raster[!is.na(arg_raster[])] <- 0  # Estos ceros reemplazan el valor inicial de cada pixel con valor
plot(arg_raster)

summary(arg_raster@data@values)  # Todos 0 y 5526343 NAs
which(arg_raster@data@values == 0)
which(is.na(arg_raster@data@values))  # 50203 NAs

writeRaster(arg_raster, filename = "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Farms_BS3_bin/Raster_ceros", format = "GTiff", overwrite = TRUE)

#---------------------------------------------------------------------
# Carga de existencias porcinas
#---------------------------------------------------------------------

rm(list=ls(all=TRUE))

nodos <- read.csv("D:/CIC/Analisis/MNE_garrapatas/Interaction/Datos/Farms/nodes_bs3.csv", sep = ",")
colnames(nodos)
head(nodos)

coordenadas <- nodos[,c("Lon", "Lat")]
is.data.frame(coordenadas)

crs <- CRS("+init=epsg:4326")
spdf <- SpatialPointsDataFrame(coords = coordenadas, data = nodos, proj4string = crs)

class(spdf)
spdf@coords
spdf@data

writeOGR(spdf,"D:/CIC/Analisis/MNE_garrapatas/Interaction/Datos/Farms","BS3", driver = "ESRI Shapefile", overwrite_layer = T)

#---------------------------------------------------------------------------------
# Rasterize the points to match the resolution and extent of the original raster
#---------------------------------------------------------------------------------

arg_raster <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Farms_BS3_bin/Raster_ceros.tif")

farm_raster <- rasterize(spdf, arg_raster, field=1, fun="first", background=0)
plot(farm_raster, main="Rasterized Farms")
class(farm_raster)

# Check extent and resolution

options(digits = 16)

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif")

farm_ext <- farm_raster@extent; farm_ext
farm_res <- res(farm_raster); farm_res

turicata_ext <- turicata@extent; turicata_ext
turicata_res <- res(turicata); turicata_res

if(farm_res[1] == turicata_res[1] & farm_res[2] == turicata_res[2]){
  print("X and Y are equal")
} else {
  print("There is a difference in pixel resolution")
}

# Notes. There are differences in resolution

if(farm_ext[1] == turicata_ext[1] & 
   farm_ext[2] == turicata_ext[2] &
   farm_ext[3] == turicata_ext[3] &
   farm_ext[4] == turicata_ext[4]){
  print("xmin, xmax, ymin, ymax are equal")
} else {
  print("There is a difference in raster extent")
}

# Notes. There are differences in extent

#-------------------------------------------------------------------------
# Match farm raster to the rest
#-------------------------------------------------------------------------

turicata <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/O_turicata.tif")

farms_resample <- resample(farm_raster, turicata, method = "ngb")

farms_res <- res(farms_resample); farms_res 
turicata_res <- res(turicata); turicata_res

farms_ext <- farms_resample@extent; farms_ext 
turicata_ext <- turicata@extent; turicata_ext


if(farms_res[1] == turicata_res[1] & farms_res[2] == turicata_res[2]){
  print("X and Y are equal")
} else {
  print("There is a difference in pixel resolution")
}

# Notes. There are no differences in resolution

if(farms_ext[1] == turicata_ext[1] & 
   farms_ext[2] == turicata_ext[2] &
   farms_ext[3] == turicata_ext[3] &
   farms_ext[4] == turicata_ext[4]){
  print("xmin, xmax, ymin, ymax are equal")
} else {
  print("There is a difference in raster extent")
}

# Notes. There are no differences in extent

writeRaster(farms_resample, "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Farms_BS3_bin/farms_BS3_final.tif")


#-------------------------------------------------------------------------
# Modification of farm raster to include pixels around those with farms
#-------------------------------------------------------------------------

rm(list=ls())

library(raster)

# Load the raster
r <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/Farms_single.tif")

# Find the cells with a value of 1
cells_with_1 <- which(values(r) == 1)



# # Find the cells with a value of 1
# cells_with_1 <- which(values(r) == 1)
# 
# # Function to get the surrounding cells for a given cell
# get_surrounding_cells <- function(cell, raster) {
#   adjacent(raster, cell, directions = 48, pairs = FALSE)
# }

cells_with_1 <- which(values(r) == 1)

# Define a function to get the surrounding cells for a given cell
get_surrounding_cells <- function(cell, raster) {
  # Use adjacent to get cells in a 7x7 neighborhood including the center cell
  surrounding_cells <- adjacent(raster, cell, directions = 8, pairs = FALSE, include = TRUE)
  
  # Get second ring of neighbors
  for (d in c(1, 2, 3)) {
    surrounding_cells <- unique(c(surrounding_cells, adjacent(raster, surrounding_cells, directions = 8, pairs = FALSE, include = TRUE)))
  }
  
  # Remove the central cell from the list
  surrounding_cells <- surrounding_cells[surrounding_cells != cell]
  return(surrounding_cells)
}

# Get all surrounding cells for the cells with value 1
surrounding_cells <- unique(unlist(lapply(cells_with_1, get_surrounding_cells, raster = r)))

# Remove any cells that are not within the raster extent
surrounding_cells <- surrounding_cells[surrounding_cells > 0 & surrounding_cells <= ncell(r)]

# Create a new raster
new_r <- raster(r)

# Initialize with zeros
new_r[] <- 0

# Set the values of the surrounding cells to 1
new_r[surrounding_cells] <- 1

# Ensure the central cells remain as 1
new_r[cells_with_1] <- 1

# Save the new raster
output_filename <- "D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin/Farms_buffer_3km.tif"
writeRaster(new_r, filename = output_filename, format = "GTiff", overwrite = TRUE)


#---------------------------------------------------------------------
# Model farm - tick - wild boar interaction
#---------------------------------------------------------------------

rm(list = ls())

setwd("D:/CIC/Analisis/MNE_garrapatas/Interaction")

path = ("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin")
files <- list.files(path = path, pattern = ".tif$", full.names = TRUE); files

# Farms, O. coriaceus, wild boar
model_1_files <- files[c(2, 4, 7)] # Example: choosing specific files by index

for(i in 1:length(model_1_files)){
  farms <- raster(model_1_files[1])
  coriaceus <- raster(model_1_files[2])
  wb <- raster(model_1_files[3])
  
  # Perform raster algebra using logical AND, propagating NA values
  overlap <- overlay(farms, coriaceus, wb, fun = function(a, b, c) {
    ifelse(is.na(a) | is.na(b) | is.na(c), NA, a & b & c)
  })

  output_filename <- "farm_coriaceus_wb_buffer"
  writeRaster(overlap, filename = paste0("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap/", output_filename, ".tif"), format = "GTiff", overwrite = TRUE)
}


#---------------------------------------------------------------------
# Farms, O. turicata, wild boar
#---------------------------------------------------------------------

rm(list=ls())

path = ("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin")
files <- list.files(path = path, pattern = ".tif$", full.names = TRUE); files

model_2_files <- files[c(2, 6, 7)] # Example: choosing specific files by index

for(i in 1:length(model_2_files)){
  farms <- raster(model_2_files[1])
  turicata <- raster(model_2_files[2])
  wb <- raster(model_2_files[3])
  
  # Perform raster algebra using logical AND, propagating NA values
  overlap <- overlay(farms, turicata, wb, fun = function(a, b, c) {
    ifelse(is.na(a) | is.na(b) | is.na(c), NA, a & b & c)
  })
  
  output_filename <- "farms_turicata_wb_buffer"
  writeRaster(overlap, filename = paste0("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap/", output_filename, ".tif"), format = "GTiff", overwrite = TRUE)
}


#---------------------------------------------------------------------
# Farms, O. rostratus, wild boar
#---------------------------------------------------------------------

rm(list=ls())

path = ("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Final_bin")
files <- list.files(path = path, pattern = ".tif$", full.names = TRUE); files

model_2_files <- files[c(2,5,7)] # Example: choosing specific files by index

for(i in 1:length(model_2_files)){
  farms <- raster(model_2_files[1])
  turicata <- raster(model_2_files[2])
  wb <- raster(model_2_files[3])
  
  # Perform raster algebra using logical AND, propagating NA values
  overlap <- overlay(farms, turicata, wb, fun = function(a, b, c) {
    ifelse(is.na(a) | is.na(b) | is.na(c), NA, a & b & c)
  })
  
  output_filename <- "farms_rostratus_wb_buffer"
  writeRaster(overlap, filename = paste0("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap/", output_filename, ".tif"), format = "GTiff", overwrite = TRUE)
}


#-------------------------------------------------------------------------------
# Calculo de areas de solapamiento
#-------------------------------------------------------------------------------

rm(list = ls())
library(magrittr)
library(dplyr)

files <- list.files("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap", pattern = ".tif$", full.names = TRUE); files

coriaceus_wb_farms <- raster("D:/CIC/Analisis/MNE_garrapatas/Interaction/Rasters/Overlap/farm_coriaceus_wb_buffer.tif")

tot_area <- c()
tot_suit <- c()
tot_unsuit <- c()
perc_suit <- c()

for(i in 1:length(files)){
  r <- raster(files[i])
  
  tot_area[i] <- sum(values(r == 1)|values(r == 0), na.rm = TRUE) # To ha
  tot_suit[i] <- sum(values(r == 1), na.rm = TRUE)
  tot_unsuit[i] <- sum(values(r == 0), na.rm = TRUE)
  perc_suit[i] <- round((tot_suit[i]/tot_area[i])*100, 2)
  
  print(tot_area[i])
  print(tot_suit[i])
  print(tot_unsuit[i])
  print(perc_suit[i])
}

Species <- c("farm_coriaceus_wb","farms_rostratus_wb","farms_turicata_wb",
             "O_coriaceus","O_rostratus","O_turicata")

table <- data.frame(Species, tot_area, tot_suit, tot_unsuit, perc_suit) %>%
  mutate(across(where(is.numeric), ~ round(., 1))); table

write.csv(table, "D:/CIC/Analisis/MNE_garrapatas/InteracTion/Tables/Overlap_ticks_wb.csv")


