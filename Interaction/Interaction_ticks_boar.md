
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





