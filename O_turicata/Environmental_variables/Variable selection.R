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
                      mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex = 0.5)
