# Collinearity analysis using variance inflation factor

rm(list=ls(all=TRUE))
gc()

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Raster data/O_turicata/Calibration_historical/GTIFF")

files <- list.files(pattern=".tif$", full.names = TRUE)
files

#------------------------------------------------------------------------
# Check spatial resolution and raster extent for layers
#------------------------------------------------------------------------

mytable <- NULL

for(i in 1:26){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable

write.csv(mytable, file = "Raster properties.csv")
xlsx::write.xlsx(mytable, file = "./Raster_properties.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

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
                        ggtheme = ggplot2::theme_gray)
                        
corr_plot

save_plot(plot = corr_plot, filename = "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Cor_plot_calibration.png", type = "cairo", dpi = 600)

