#------------------------------------------------------------------------------------
# Correlation analysis for variable selection
#------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

library(tidyverse)
library(sf)
library(stars)
library(magrittr)
library(stars)

path1 = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Calibration_M/")
path2 = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Projection_G/")

files1 <- list.files(path = path1, pattern = ".asc$", full.names = TRUE)
files1

#------------------------------------------------------------------------
# Check spatial resolution and raster extent for layers
#------------------------------------------------------------------------

library(raster)

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





# Identify cells with data

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

ssize = 10000
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

# Extract each variable in turn and the run the flattenCorrMatrix function:

while(length(to.remove) > 0){
  
  dt <- dt %>%
    dplyr::select(-to.remove[1])
  cr <- get.corr(dt)
  to.remove <- names(sort(table(c(cr$v1,cr$v2)),decreasing=TRUE))
}

#----------------------------------------------------------------
# Luciano. Correlation (no loop included)
#----------------------------------------------------------------

cor = Hmisc::rcorr(as.matrix(dt), type = "spearman")
class(cor)
str(cor)

cor$r
cor$P

DF <- cor$r

class(DF)  # Matrix

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

install.packages("corrplot")
library(corrplot)

corr_plot <- corrplot(DF, method = "color", type = "lower", 
                      mar = c(0,0,0,0), order = "alphabet", tl.col = "black", tl.cex = 0.5)

install.packages("ggcorrplot")
library(ggcorrplot)

write.xlsx(cor$r, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_r_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)
write.xlsx(cor$P, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_P_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

install.packages("ggcorrplot")
library(ggcorrplot)


# Compute a matrix of correlation p-values

p.mat <- cor_pmat(DF)
p.mat

plot.new()

corr_plot <- ggcorrplot(DF, outline.col = "white", type = "lower", 
                        tl.cex = 12, tl.col = "black", tl.srt = 90, 
                        ggtheme = ggplot2::theme_gray, sig.level = 0.05, 
                        insig = "pch", p.mat = p.mat)

corr_plot

cowplot::save_plot(plot = corr_plot, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_plot.png", type = "cairo", base_height = 8, base_width = 8)












mystack <- stack(files[c(1:26)])
dim(mystack)  # 230454 pixels

stackSave(mystack, "Stack")

#-------------------------------------------------------------------------
# Collinearity analysis using variance inflation factor
# Identify cells with data
#-------------------------------------------------------------------------

# Collinearity analysis using correlation matrix

mystack <- stackOpen("Stack")
class(mystack)

k <- which(!is.na(mystack[[1]] []))
class(k)
is.vector(k)
length(k)  # 56817
head(k)

k <- sample(k, size = 10000)
class(k)

k <- raster::extract(mystack, k)
class(k)   # Matrix
length(k)  # 260000

length(which(is.na(k)))

cor.matrix <- cor(k, use = "pairwise.complete.obs")  

head(cor.matrix)
dim(cor.matrix)

DF <- as.data.frame(cor.matrix)

colnames(cor.matrix) <- c("Bio1","Bio10","Bio11","Bio12","Bio13","Bio14",
                          "Bio15","Bio16","Bio17","Bio18","Bio19","Bio2", 
                          "Bio3","Bio4","Bio5","Bio6","Bio7", 
                          "Bio8","Bio9","prec_mean","solar_rad_mean","tavg_mean", 
                          "tmax_mean","tmin_mean","vapor_mean","wind_mean")


rownames(cor.matrix) <- c("Bio1","Bio10","Bio11","Bio12","Bio13","Bio14",
                          "Bio15","Bio16","Bio17", "Bio18", "Bio19","Bio2", 
                          "Bio3","Bio4","Bio5","Bio6","Bio7", 
                          "Bio8","Bio9","prec_mean","solar_rad_mean","tavg_mean", 
                          "tmax_mean","tmin_mean","vapor_mean","wind_mean")



# Install package named WriteXLS

install.packages("xlsx")
library(xlsx)

write.xlsx(DF, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

install.packages("corrplot")
library(corrplot)

corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
                      mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex = 0.5)

install.packages("ggcorrplot")
library(ggcorrplot)

# Compute a matrix of correlation p-values

p.mat <- cor_pmat(cor.matrix)
p.mat

plot.new()

corr_plot <- ggcorrplot(cor.matrix, outline.col = "white", type = "lower", 
                        tl.cex = 8, tl.col = "black", tl.srt = 90, 
                        ggtheme = ggplot2::theme_gray, p.mat = p.mat)
                        
corr_plot

save_plot(plot = corr_plot, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_plot_calibration.png", type = "cairo", dpi = 600)

