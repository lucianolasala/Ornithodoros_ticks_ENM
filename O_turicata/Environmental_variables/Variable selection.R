#------------------------------------------------------------------------------------
# Correlation analysis for variable selection
#------------------------------------------------------------------------------------

gc()
Hola puta madre

rm(list=ls(all=TRUE))

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(sf) # Simple Features for R
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(magrittr) # A Forward-Pipe Operator for R
library(raster) # Geographic Data Analysis and Modeling
library(xlsx) # Read, Write, Format Excel 2007 and Excel 97/2000/XP/2003 Files
library(virtualspecies) # Generation of Virtual Species Distributions
library(corrplot) # Visualization of a Correlation Matrix
library(ggcorrplot) # Visualization of a Correlation Matrix using 'ggplot2'


path1 = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/")
path2 = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Projection_G/")

files1 <- list.files(path = path1, pattern = ".asc$", full.names = TRUE)
files1

#------------------------------------------------------------------------
# Check spatial resolution and raster extent for layers
#------------------------------------------------------------------------

mytable1 <- NULL

for(i in 1:26){
  r <- raster(files1[i])
  mytable1 <- rbind(mytable1, c(files1[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable1) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable1

xlsx::write.xlsx(mytable, file = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Raster_props_calibration.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

files2 <- list.files(path = path2, pattern = ".asc$", full.names = TRUE)
files2

mytable2 <- NULL

for(i in 1:26){
  r <- raster(files2[i])
  mytable2 <- rbind(mytable2, c(files2[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable2) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")

mytable2

xlsx::write.xlsx(mytable2, file = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Raster_props_projection.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)


#------------------------------------------------------------------------------------
# Identify cells with data
#------------------------------------------------------------------------------------

st1 <- read_stars(files1[1]) %>% set_names("z")
n1 <- which(!is.na(st1$z))  # 71% of non-na cells in both areas
length(n1)  # 56817 = 58.6%

st2 <- read_stars(files2[1]) %>% set_names("z")
n2 <- which(!is.na(st2$z))  # 29% of non-na cells in both areas
length(n2)  # 40061 = 41.4% 

p1 = length(n1)/(length(n1)+length(n2))  
p1

p2 = length(n2)/(length(n1)+length(n2))  
p2

#----------------------------------------------------------------
# Draw random sample from rasters
#----------------------------------------------------------------

set.seed(100)

ssize = 5000
sm1 <- sample(n1, size = floor(ssize * p1))
sm2 <- sample(n2, size = floor(ssize * p2))

length(sm1)
length(sm2)

## Sample data 

dt <- NULL

for(i in 1:26){
  st1 <- read_stars(files1[i]) %>% set_names("z")
  st2 <- read_stars(files2[i]) %>% set_names("z")
  dt <- cbind(dt, c(st1$z[sm1], st2$z[sm2]))
}

dt

class(dt)  # matrix
dim(dt)    # 4999 (cells) * 26 (variables)


#----------------------------------------------------------------
# Julian. Explore correlation and remove highly correlated variables
# Remove each variable in turn and re-run this chunk until all correlations are below 0.8
#----------------------------------------------------------------

get.corr <- function(x){
  crr <- Hmisc::rcorr(as.matrix(x), type = "spearman")
  ut <- upper.tri(crr$r)
  vnames <- colnames(crr$r)
  crr <- data.frame(v1 = vnames[row(crr$r)[ut]],
                    v2 = vnames[col(crr$r)[ut]],
                    cor = crr$r[ut]) %>%
    as_tibble() %>%
    mutate(cor = abs(cor)) %>%
    arrange(desc(cor)) %>%
    filter(cor >= .8)
  return(crr)
}

cr <- get.corr(dt)
to.remove <- names(sort(table(c(cr$v1,cr$v2)), decreasing = TRUE))

# Extract each variable in turn and then run the flattenCorrMatrix function:

while(length(to.remove) > 0){
  
  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1,cr$v2)), decreasing=TRUE))
}

#----------------------------------------------------------------
# LFLS. Correlation (no loop included)
# Uso de funcion rcorr del paquete Hmisc
#----------------------------------------------------------------

cor1 = Hmisc::rcorr(dt, type = "spearman")
class(cor1)
str(cor1)
is.list(cor1)

cor1$r
cor1$P
cor1$n

# Extraigo el elemento r de la lista  

DF <- cor1$r

class(DF)  # Matrix
dim(DF)    # 26 26

colnames(DF) <- c("Bio1","Bio10","Bio11","Bio12","Bio13","Bio14",
                  "Bio15","Bio16","Bio17","Bio18","Bio19","Bio2", 
                  "Bio3","Bio4","Bio5","Bio6","Bio7", 
                  "Bio8","Bio9","prec_mean","solar_rad_mean","tavg_mean", 
                  "tmax_mean","tmin_mean","vapor_mean","wind_mean")

rownames(DF) <- c("Bio1","Bio10","Bio11","Bio12","Bio13","Bio14",
                  "Bio15","Bio16","Bio17", "Bio18", "Bio19","Bio2", 
                  "Bio3","Bio4","Bio5","Bio6","Bio7", 
                  "Bio8","Bio9","prec_mean","solar_rad_mean","tavg_mean", 
                  "tmax_mean","tmin_mean","vapor_mean","wind_mean")
DF

class(DF)  # Matrix

corr_plot_1 <- corrplot(DF, method = "color", type = "lower", 
                      mar = c(0,0,0,0), order = "alphabet", tl.col = "black", tl.cex = 0.5)


write.xlsx(cor1$r, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Corr_matrices/Matrix_r.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)
write.xlsx(cor1$P, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Corr_matrices/Matrix_P.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

write.xlsx(DF, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Corr_matrices/Matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)


# Compute a matrix of correlation p-values

p.mat <- cor_pmat(DF)
p.mat
plot.new()

corr_plot_1 <- ggcorrplot(DF, outline.col = "white", type = "lower", 
                        tl.cex = 12, tl.col = "black", tl.srt = 90, 
                        ggtheme = ggplot2::theme_gray, sig.level = 0.05, 
                        insig = "pch", p.mat = p.mat)

corr_plot_1

corr_plot_2 <- corrplot(DF, order = "hclust")

cowplot::save_plot(plot = corr_plot, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_plot.png", type = "cairo", base_height = 8, base_width = 8)

#-------------------------------------------------------------------------
# Introduction to Feature selection for bioinformaticians using R, 
# correlation matrix filters, PCA & backward selection
# https://www.r-bloggers.com/2013/10/introduction-to-feature-selection-for-bioinformaticians-using-r-correlation-matrix-filters-pca-backward-selection/
#-------------------------------------------------------------------------

install.packages("caret")
library(caret) # Classification and Regression Training

dim(DF)
class(DF)

# La matriz DF es la matriz de correlacion anterior que tiene todos los valores de
# correlacion
# The function findCorrelation searches through a "correlation matrix" and returns a 
# vector of integers corresponding to columns to remove to reduce pair-wise correlations.
# Apply correlation filter at 0.8

highlyCor <- findCorrelation(DF, cutoff = 0.80)
highlyCor  # 25 24 13 22  1 23 15 18 14 10  2  7 16  5  9 (15 columns to remove)
length(highlyCor)  # 15


# Remove all the variable correlated with more 0.8.

Filtered <- DF[,-highlyCor]
class(Filtered)
dim(Filtered)  # 26 11 (se sacaron 15)

mat_keep_rows <- c("Bio11","Bio12","Bio14","Bio16","Bio19","Bio2",
                   "Bio7","Bio9","prec_mean","solar_rad_mean","wind_mean")

mat_keep_cols <- c("Bio11","Bio12","Bio14","Bio16","Bio19","Bio2",
                   "Bio7","Bio9","prec_mean","solar_rad_mean","wind_mean")

mat_subset <- DF[rownames(DF) %in% mat_keep_rows, colnames(DF) %in% mat_keep_cols]  # Extract rows from matrix
mat_subset

write.xlsx(mat_subset, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Corr_matrices/Matrix_subset.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)


# Ahora, si hiciera un analisis de correlacion sobre esa nueva seleccion de variables
# no deberia haber variables con correlacion > 0.8.

