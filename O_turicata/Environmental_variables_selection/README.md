## Correlation analysis for variable selection
>Loading libraries 

```r
rm(list=ls(all=TRUE))

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(sf) # Simple Features for R
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(magrittr) # A Forward-Pipe Operator for R
library(raster) # Geographic Data Analysis and Modeling
library(xlsx) # Read, Write, Format Excel 2007 and Excel 97/2000/XP/2003 Files
library(corrplot) # Visualization of a Correlation Matrix
library(ggcorrplot) # Visualization of a Correlation Matrix using 'ggplot2'
```

## Correlation analysis

```r
path = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii/")

files <- list.files(path = path, pattern = ".asc$", full.names = T)
files

mystack <- stack(files)
class(mystack)
dim(mystack)

mystack@layers  # 22

k <- which(!is.na(mystack[[1]][]))  # Por que  [] ?
class(k)
is.vector(k)
length(k)  # 4887074
head(k)

n.samp = length(k)*.2
n.samp
k.samp <- sample(k, size = 20000)
class(k.samp)
head(k.samp)

k.final <- raster::extract(mystack, k.samp)
class(k.final)  # Matrix
dim(k.final)  # 20000    22

length(which(is.na(k.final)))  # 364

cor.matrix <- cor(k.final, use = "pairwise.complete.obs")  

head(cor.matrix)
dim(cor.matrix)  # 22*22

write.xlsx(DF, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)
write.csv(cor.matrix,"C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.csv")
```

## Plotting correlation matrix

```r
rm(list=ls(all=TRUE))



cor.matrix <- read.csv("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.csv")
is.matrix(cor.matrix)  # TRUE. La fc corrplot tiene que correr sobre una matriz

corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
                      mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex = 0.5, is.corr = FALSE)

#-------------------------------------------------------------------------------
# Function rcorr in Hmisc package
#-------------------------------------------------------------------------------

library(Hmisc)

path = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii/")

files <- list.files(path = path, pattern = ".asc$", full.names = T)
files

mystack <- stack(files)
class(mystack)
dim(mystack)

mystack@layers  # 22

k <- which(!is.na(mystack[[1]][]))  # Por que  [] ?
class(k)
is.vector(k)
length(k)  # 4887074
head(k)

n.samp = length(k)*.2
n.samp
k.samp <- sample(k, size = 10000)
class(k.samp)
head(k.samp)

k.final <- raster::extract(mystack, k.samp)
class(k.final)  # Matrix
dim(k.final)  # 20000    22

length(which(is.na(k.final)))  # 416

cor2 = Hmisc::rcorr(k.final, type = "spearman")

class(cor2) # "rcorr"

cor2$r
cor2$P
cor2$n

# Extraigo el elemento r de la lista  

DF1 <- cor2$r

class(DF1)  # Matrix
dim(DF1)    # 22 22



colnames(DF1) <- c("Bulk_density_0cm","Bulk_density_10",        
                  "dayLST_max","dayLST_mean",              
                  "dayLST_min","DEM",                      
                  "EVI_max","EVI_mean",                 
                  "EVI_min","nightLST_mean",            
                  "nightLST_min","nightyLST_max",            
                  "GPP","Precip. anual mean", 
                  "Soil_clay_0cm","Soil_clay_10cm",           
                  "Soil_H2O_0cm","Soil_H2O_10cm",            
                  "Soil_H2O_ph_0cm","Soil_H2O_ph_10cm",         
                  "Soil_sand_0cm","Soil_sand_10cm")

rownames(DF1) <- c("Bulk_density_0cm","Bulk_density_10",        
                  "dayLST_max","dayLST_mean",              
                  "dayLST_min","DEM",                      
                  "EVI_max","EVI_mean",                 
                  "EVI_min","nightLST_mean",            
                  "nightLST_min","nightyLST_max",            
                  "GPP","Precip. anual mean", 
                  "Soil_clay_0cm","Soil_clay_10cm",           
                  "Soil_H2O_0cm","Soil_H2O_10cm",            
                  "Soil_H2O_ph_0cm","Soil_H2O_ph_10cm",         
                  "Soil_sand_0cm","Soil_sand_10cm")
DF1

class(DF1)  # Matrix
str(DF1)

write.xlsx(cor2$r, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix_r.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)  # Writes matrix with r values
write.xlsx(cor2$P,"C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix_P.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)  # Writes matrix with P values
write.xlsx(DF1, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)  # Writes matrix with r values


# Compute a matrix of correlation p-values

plot.new()

p.mat <- cor_pmat(DF1)
corr_plot_1 <- ggcorrplot(p.mat, outline.col = "white", type = "upper", 
                        tl.cex = 12, tl.col = "black", tl.srt = 90, 
                        ggtheme = ggplot2::theme_gray, sig.level = 0.05, 
                        insig = "pch", p.mat = p.mat)
corr_plot_1

r.mat <- cor2$r
corr_plot_2 <- ggcorrplot(r.mat, outline.col = "white", type = "upper", 
                          tl.cex = 12, tl.col = "black", tl.srt = 90, 
                          ggtheme = ggplot2::theme_gray, sig.level = 0.05, 
                          insig = "pch", p.mat = p.mat)
corr_plot_2

cowplot::save_plot(plot = corr_plot, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_plot.png", type = "cairo", base_height = 8, base_width = 8)

#-------------------------------------------------------------------------
# Introduction to Feature selection for bioinformaticians using R, 
# correlation matrix filters, PCA & backward selection
# https://www.r-bloggers.com/2013/10/introduction-to-feature-selection-for-bioinformaticians-using-r-correlation-matrix-filters-pca-backward-selection/
#-------------------------------------------------------------------------

install.packages("caret")
library(caret) # Classification and Regression Training

DF <- read.xlsx("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix_r.xlsx", sheetIndex = 1)
DF <- read.csv("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix_r.csv", header = T)

is.data.frame(DF)
ncol(DF)
nrow(DF)
dim(DF)
class(DF)

colnames(DF)
rownames(DF)

# La matriz DF es la matriz de correlacion anterior que tiene todos los valores de
# correlacion.
# The function findCorrelation searches through a "correlation matrix" and returns a 
# vector of integers corresponding to columns to remove to reduce pair-wise correlations.
# Apply correlation filter at 0.8

highlyCor <- findCorrelation(DF1, cutoff = 0.80)  # DF1 has to be matrix
highlyCor  # 3, 13, 8, 7, 20, 19, 17, 16, 4, 22, 11, 5, 2 (13 columns to remove)
length(highlyCor)  # 13


# Remove all the variable correlated with more 0.8.

Filtered <- DF1[,-highlyCor]
class(Filtered)
dim(Filtered)  # 22 9 (se sacaron 13)

Filtered
colnames(Filtered)

mat_keep_rows <- c("Bulk_density_0cm_M","DEM_M","EVI_min_M","nightLST_mean_M",
                   "nightyLST_max_M","Precipitation_anual_mean_M",
                   "Soil_clay_0cm_M","Soil_H2O_10cm_M","Soil_sand_0cm_M")

mat_keep_cols <- c("Bulk_density_0cm_M","DEM_M","EVI_min_M","nightLST_mean_M",
                   "nightyLST_max_M","Precipitation_anual_mean_M",
                   "Soil_clay_0cm_M","Soil_H2O_10cm_M","Soil_sand_0cm_M")

mat_subset <- DF1[rownames(DF1) %in% mat_keep_rows, colnames(DF1) %in% mat_keep_cols]  # Extract rows from matrix
mat_subset

write.xlsx(mat_subset, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Matrix_subset.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

# Ahora, si hiciera un analisis de correlacion sobre esa nueva seleccion de variables
# no deberia haber variables con correlacion > 0.8.