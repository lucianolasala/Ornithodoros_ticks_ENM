---
  title: "Untitled"
author: "Luciano F. La Sala"
date: "21/2/2020"
output: md_document
toc: TRUE
toc_depth: 2
---

# An Ecological Niche Model for Wild Boar in Argentina  


rm(list=ls(all=TRUE))

r <- getOption("repos")
r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
options(repos = r)

if(!require(sf)){
  install.packages("sf")
}
if(!require(rmarkdown)){
  install.packages("rmarkdown")
}
if(!require(magrittr)){
  install.packages("magrittr")
}
if(!require(tidyverse)){
  install.packages("tidyverse")
}
if(!require(rnaturalearth)){
  install.packages("rnaturalearth")
}
if(!require(raster)){
  install.packages("raster")
} 
if(!require(rgdal)){
  install.packages("rgdal")
}
if(!require(FNN)){
  install.packages("FNN")
}
if(!require(knitr)){
  install.packages("knitr")
}
if(!require(dplyr)){
  install.packages("dplyr")
}
if(!require(kableExtra)){
  install.packages("kableExtra")
}
if(!require(doParallel)){
  install.packages("doParallel")
}
if(!require(usdm)){
  install.packages("usdm")
}    

library(sf)
library(rmarkdown)
library(magrittr)
library(tidyverse)
library(rnaturalearth)
library(raster)
library(rgdal)
library(FNN)
library(knitr)
library(dplyr)
library(kableExtra)
library(doParallel)
library(usdm)
  
#### Introduction
  
# This document includes analyses and related code for the development of an   ecological niche model (henceforth denoted as ENM) for Wild boar (*Sus scrofa*) in Argentina.
# A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/).  


#### Check spatial resolution and raster extent.

detectCores()
registerDoParallel(4)
  
setwd("C:\\Users\\user\\Documents\\Analyses\\Wild Boar ENM\\Rasters TIF\\Calibration_area")

mytable <- NULL

files <- list.files(pattern=".tif$", full.names = FALSE)

for(i in 1:60){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable

write.csv(mytable, file = "Raster props.csv")


# All rasters have the same spatial resolution and extension.

# Save all rasters as ascii files to be used as M files

r <- lapply(files, function(i) {writeRaster(raster(i), filename=extension(i, ".asc"), overwrite = TRUE)})


#### Distance to water occurrence 20%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_20 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_20.tif")
water <- which(water_20[] == 1)
xy.water <- xyFromCell(water_20, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_20.tif", overwrite = TRUE)


#### Distance to water occurrence 30%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_30 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_30.tif")
water <- which(water_30[] == 1)
xy.water <- xyFromCell(water_30, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_30.tif", overwrite = TRUE)



#### Distance to water occurrence 40%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_40 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_40.tif")
water <- which(water_40[] == 1)
xy.water <- xyFromCell(water_40, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_40.tif", overwrite = TRUE)


#### Distance to water occurrence 50%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_50 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_50.tif")
water <- which(water_50[] == 1)
xy.water <- xyFromCell(water_50, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_50.tif", overwrite = TRUE)


#### Distance to water occurrence 60%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_60 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_60.tif")
water <- which(water_60[] == 1)
xy.water <- xyFromCell(water_60, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_60.tif", overwrite = TRUE)


#### Distance to water occurrence 70%
  
rm(list=ls(all=TRUE))
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_70 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_70.tif")
water <- which(water_70[] == 1)
xy.water <- xyFromCell(water_70, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_70.tif", overwrite = TRUE)


#### Distance to water occurrence 80%
  
molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_80 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_70.tif")
water <- which(water_80[] == 1)
xy.water <- xyFromCell(water_80, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_80.tif", overwrite = TRUE)


#### Distance to water occurrence 90%
  
rm(list=ls(all=TRUE))

molde <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Land Cover.tif")
kpop <- which(!is.na(molde[]))
xy <- xyFromCell(molde, kpop)
xy <- SpatialPoints(xy, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy <- spTransform(xy, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy <- coordinates(xy)

water_90 <- raster("C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Water_occurrence_90.tif")
water <- which(water_90[] == 1)
xy.water <- xyFromCell(water_90, water)
xy.water <- SpatialPoints(xy.water, proj4string = CRS("+proj=longlat +datum=WGS84"))
xy.water <- spTransform(xy.water, CRS("++proj=tmerc +lat_0=-90 +lon_0=-69 +k=1 +x_0=2500000 +y_0=0 +ellps=GRS80 +units=m +no_defs"))
xy.water <- coordinates(xy.water)

dst1 <- get.knnx(xy.water, xy, k = 1)
dst1 <- dst1$nn.dist/1000

dist_water <- raster(molde)
dist_water[kpop] <- dst1

writeRaster(dist_water, file = "C:/Users/user/Documents/Analyses/Wild Boar ENM/Rasters GEE TIF/Dist_water_occurrence_90.tif", overwrite = TRUE)

rm(list=ls(all=TRUE))

setwd("C:\\Users\\user\\Documents\\Analyses\\Wild Boar ENM\\Rasters GEE TIF")

files <- list.files(pattern=".tif$", full.names = TRUE)
files
class(files)

mystack <- stack(files[c(1:55, 65)])
dim(mystack)

stackSave(mystack, "Stack")

# Collinearity analysis using variance inflation factor

mysample <- sampleRandom(mystack, size = 50000)
test <- vifstep (mysample, th = 10)
test

class(test)


# Hacer corplot de las variables que quedan de acuerdo a VIFs
colnames(cor.matrix) <- c("Bio02", "Bio01", "Bio03", "Bio05", "Bio11", "Bio09",
                          "Bio10",  "Bio08", "Bio06", "Bio19", "Bio14", "Bio17", 
                          "Bio15", "Bio18", "Bio13", "Bio16", "Bio12_max", 
                          "Bio12_mean", "Bio12_max", "Bio12_min", "Bio07", "Bio04", 
                          "MODIS_dayLST_cv", "MODIS_dayLST_max", "MODIS_dayLST_med", 
                          "MODIS_dayLST_min", "MODIS_dayLST_sd", "DEM, Dist_water_20",
                          "Dist_water_30", "Dist_water_40", "Dist_water_50", "Dist_water_60", "Dist_water_70",
                          "Dist_water_80", "Dist_water_90", "MODIS_EVI_cv", "MODIS_EVI_max", "MODIS_EVI_med", 
                          "MODIS_EVI_min", "MODIS_EVI_sd", "ESA_Global_Land_Cover", "IPSE", "MODIS_Land_Cover",
                          "MODIS_NDVI_cv", "MODIS_NDVI_max", "MODIS_NDVI_med","MODIS_NDVI_min",
                          "MODIS_NDVI_sd", "MODIS_nightLST_cv", "MODIS_nightLST_max", "MODIS_nightLST_med",
                          "MODIS_nightLST_min", "MODIS_nightLST_sd", "GPM_Precip_anual_mean",
                          "GPM_Precip_month_mean", "Worlp_Pop")


rownames(cor.matrix) <- c("Bio02", "Bio01", "Bio03", "Bio05", "Bio11", "Bio09",
                          "Bio10",  "Bio08", "Bio06", "Bio19", "Bio14", "Bio17", 
                          "Bio15", "Bio18", "Bio13", "Bio16", "Bio12_max", 
                          "Bio12_mean", "Bio12_max", "Bio12_min", "Bio07", "Bio04", 
                          "MODIS_dayLST_cv", "MODIS_dayLST_max", "MODIS_dayLST_med", 
                          "MODIS_dayLST_min", "MODIS_dayLST_sd", "DEM, Dist_water_20",
                          "Dist_water_30", "Dist_water_40", "Dist_water_50", "Dist_water_60", "Dist_water_70",
                          "Dist_water_80", "Dist_water_90", "MODIS_EVI_cv", "MODIS_EVI_max", "MODIS_EVI_med", 
                          "MODIS_EVI_min", "MODIS_EVI_sd", "ESA_Global_Land_Cover", "IPSE", "MODIS_Land_Cover",
                          "MODIS_NDVI_cv", "MODIS_NDVI_max", "MODIS_NDVI_med","MODIS_NDVI_min",
                          "MODIS_NDVI_sd", "MODIS_nightLST_cv", "MODIS_nightLST_max", "MODIS_nightLST_med",
                          "MODIS_nightLST_min", "MODIS_nightLST_sd", "GPM_Precip_anual_mean",
                          "GPM_Precip_month_mean", "Worlp_Pop")


# Collinearity analysis using correlation matrix

mystack <- stackOpen("Stack")
class(mystack)

k <- which(!is.na(mystack[[1]][]))
class(k)
is.vector(k)
length(k)  # 10053509
head(k)

k <- sample(k, size = 10000)
class(k)

k <- raster::extract(mystack, k)
class(k)  # Matrix
length(k)

length(which(is.na(k)))

cor.matrix <- cor(k, use = "pairwise.complete.obs")  

head(cor.matrix)
dim(cor.matrix)

DF <- as.data.frame(cor.matrix)

# Install package named WriteXLS

install.packages("xlsx")
library(xlsx)

write.xlsx(DF, "Cor_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

write.table(cor.matrix, file = "Correlation_matrix_variables.csv", col.names = TRUE, row.names = FALSE, sep = ",")

install.packages("corrplot")
library(corrplot)

corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
         mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex = 0.5, p.mat = p.mat)

ggsave(...)  # No funciona


##########################################################################################33

# Occurrences processing

# Spatial thinning

library(spThin)

occ_all <- read.csv("Sus_scrofa.csv", sep = ";")
head(occ_all)


thin(occ_all, lat.col = "Latitude", long.col = "Longitude", spec.col = "Species",
     thin.par = 10, reps = 10, write.files = TRUE, max.files = 10, out.dir = "data", out.base = "cmex",
     write.log.file = FALSE, verbose = TRUE)

############################################################################################
############################################################################################

# Training and testing data splitting. Randomly 75% for training and 25% for testing

if(!require(kuenm)){
  devtools::install_github("marlonecobos/kuenm")
}

library(kuenm)

kuenm_start("modelado")

occ_thinn <- read.csv("data/cmex_thin1.csv")

all <- unique(occ_thinn)
head(all)
nrow(all)

all$check <- paste(all[,2], all[,3], sep = "_")
head(all)

train <- all[sample(nrow(all), round((length(all[,1])/4*3))), ]
head(train)

test <- all[!all[,4] %in% train[,4], ]
head(test)

nrow(all)
nrow(train)
nrow(test)

all$check <- NULL
train$check <- NULL
test$check <- NULL

write.csv(all, file = "C:/Users/user/Documents/Analyses/Wild boar ENM/Maxent R/Sp_joint.csv", row.names = FALSE)
write.csv(train, file = "C:/Users/user/Documents/Analyses/Wild boar ENM/Maxent R/Sp_train.csv", row.names = FALSE)
write.csv(test, file = "C:/Users/user/Documents/Analyses/Wild boar ENM/Maxent R/Sp_test.csv", row.names = FALSE)

# The next chunk of code is for preparing the arguments for using the function following the modularity principle. 
# These variables can be changed according to each case.

occ_joint <- "Sp_joint.csv"
occ_tra <- "Sp_train.csv"
M_var_dir <- "M_variables"
batch_cal <- "Candidate_models"
out_dir <- "Candidate_Models"
reg_mult <- c(1, 2)
f_clas <- c("qp","lq")
args <- NULL
maxent_path <- "C:/Users/User/Desktop/maxent"
wait <- FALSE   # Runs Maxent outside of R
run <- TRUE

setwd("C:/Users/User/Documents/Analyses/Wild boar ENM/Maxent R")

kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, batch = batch_cal,
          out.dir = out_dir, reg.mult = reg_mult, f.clas = f_clas, args = args,
          maxent.path = maxent_path, wait = wait, run = run)


### Evaluation and selection of best models

# Evaluation is a crucial step in model calibration. This step centers on selecting candidate 
# models and their associated parameters to identify the best models for the purposes of the 
# study. The kuenm_ceval function evaluates candidate models based on three distinct criteria: 
# statistical significance (based on partial ROC analyses), prediction ability (we use omission 
# rates, but other metrics, such as overall correct classification rate, can also be used), 
# and model complexity (here evaluated using AICc). 

help(kuenm_ceval)


occ_test <- "Sp_test.csv"
out_eval <- "Calibration_results"
threshold <- 5
rand_percent <- 50
iterations <- 500
kept <- TRUE
selection <- "OR_AICc"
paral_proc <- FALSE # make this true to perform MOP calculations in parallel, recommended
                    # only if a powerfull computer is used (see function's help)
                    # Note, some of the variables used here as arguments were already created for the previous function

cal_eval <- kuenm_ceval(path = out_dir, occ.joint = occ_joint, occ.tra = occ_tra, occ.test = occ_test,
                        batch = batch_cal, out.eval = out_eval, threshold = threshold,
                        rand.percent = rand_percent, iterations = iterations, kept = kept,
                        selection = selection, parallel.proc = paral_proc)

### Final model creation
# After selecting parametrizations that produce best models, the next step is to create the final models, and if needed transfer them to other environmental data sets (e.g., to other time periods or other geographic regions). The function help is called via this code:
  
help(kuenm_mod)

# For preparing the arguments for this function use the following chunk of code.

batch_fin <- "Final_models"
mod_dir <- "Final_Models"
rep_n <- 10
rep_type <- "Bootstrap"
jackknife <- FALSE
out_format <- "logistic"
project <- TRUE
G_var_dir <- "G_variables"
ext_type <- "all"
write_mess <- FALSE
write_clamp <- FALSE
wait1 <- FALSE
run1 <- TRUE
args <- NULL

# Again, some of the variables used here as arguments were already created for the previous functions


<br>
  
  The kuenm_mod function has the following syntax:
  
  ```{r, eval=FALSE}
kuenm_mod(occ.joint = occ_joint, M.var.dir = M_var_dir, out.eval = out_eval, batch = batch_fin,
          rep.n = rep_n, rep.type = rep_type, jackknife = jackknife, out.dir = mod_dir,
          out.format = out_format, project = project, G.var.dir = G_var_dir, ext.type = ext_type,
          write.mess = write_mess, write.clamp = write_clamp, maxent.path = maxent_path,
          args = args, wait = wait1, run = run1)
```

