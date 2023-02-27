## Correlation analysis for variable selection

### Loading libraries 

```r
pkgs <- c("tidyverse","sf","stars","magrittr","raster","xlsx","corrplot","ggcorrplot","openxlsx","Hmisc")

new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs)) install.packages(new.pkgs)

lapply(pkgs, require, character.only = TRUE)
```

### Check spatial resolution and raster extent of raster layers

```r
path = ("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Rasters/Calibration_ascii") 

files <- list.files(path = path, pattern = ".asc$", full.names = TRUE)
mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 8)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable <- as.data.frame(mytable)

write_xlsx(mytable, "D:/Trabajo/Analisis/MNE_garrapata/Rasters/Calibration_ascii_props/Rasters_props.xlsx")
```

### Correlation analysis

```r
path = ("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii/")

files <- list.files(path = path, pattern = ".asc$", full.names = T)

mystack <- stack(files)
k <- which(!is.na(mystack[[1]][]))
n.samp = round(length(k)*.005, 0)
k.samp <- sample(k, size = n.samp)

k.final <- raster::extract(mystack, k.samp)
cor.matrix <- cor(k.final, use = "pairwise.complete.obs")  

# Write as Excel for our own records
write.xlsx(DF, "C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.xlsx", sheetName = "Sheet1", col.names = TRUE, row.names = TRUE, append = FALSE)

# Write as csv for later processing
write.csv(cor.matrix,"C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.csv")

# Save output matrix as dataframe (Excel) with rows and columns names

DF <- as.data.frame(cor.matrix)

# Add names to columns and rows

files <- list.files(path = path, pattern = ".asc$", full.names = F)
colnames(DF) <- files.1
rownames(DF) <- files.1

openxlsx::write.xlsx(DF,"D:/Trabajo/Analisis/MNE_garrapata/Rasters/Calibration_ascii_props/Cor_matrix.xlsx", rowNames = TRUE, colNames=T, overwrite = TRUE)
```

### Plotting correlation matrix

```r
cor.matrix <- read.csv("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Rasters/Calibration_ascii_props/Cor_matrix.csv")

corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
             mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex =                 0.5, is.corr = FALSE)
```

#### Feature selection

```r
DF <- read.table("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Rasters/Calibration_ascii_props/Cor_matrix.csv")

is.data.frame(DF)
ncol(DF)
nrow(DF)
dim(DF)

colnames(DF)
rownames(DF)

# La matriz DF es la matriz de correlacion anterior que tiene todos los valores de
# correlacion. The function findCorrelation searches through a "correlation matrix" and returns a 
# vector of integers corresponding to columns to remove to reduce pair-wise correlations.
# Apply correlation filter at 0.8

DF.mat <- as.matrix(DF)
is.matrix(DF.mat)
dim(DF.mat)

highlyCor <- findCorrelation(cor(as.matrix(DF.mat)), cutoff = 0.80)  # x has to be matrix
highlyCor  # 13 3 14 8 7 20 19 17 16 1 21 5 11 (13 columns to remove)
length(highlyCor)  # 13

Filtered <- DF.mat[,-highlyCor]
class(Filtered)
dim(Filtered)  # 22 9 (13 removed)

Filtered
colnames(Filtered)

# Como colnames no tiene nombre claro, asignarlos

path = ("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Rasters/Calibration_ascii")

files <- gsub(".asc$","", list.files(path = path, pattern = ".asc$", full.names = F))
files

colnames(DF.mat) <- files
rownames(DF.mat) <- files
head(DF.mat)

# "V2"  "V4"  "V6"  "V9"  "V10" "V12" "V15" "V18" "V22"

mat_keep_rows <- c("Bulk_density_10cm_M","dayLST_mean_M","DEM_M",
                   "EVI_min_M","nightLST_mean_M","nightLST_max_M",
                   "Soil_clay_0cm_M","Soil_H2O_10cm_M","Soil_sand_10cm_M")

mat_keep_cols <- c("Bulk_density_10cm_M","dayLST_mean_M","DEM_M",
                   "EVI_min_M","nightLST_mean_M","nightLST_max_M",
                   "Soil_clay_0cm_M","Soil_H2O_10cm_M","Soil_sand_10cm_M")

mat_subset <- DF.mat[rownames(DF.mat) %in% mat_keep_rows, colnames(DF.mat) %in% mat_keep_cols]  # Extract rows from matrix
mat_subset  # matrix
mat_subset_DF <- as.data.frame(mat_subset)
is.data.frame(mat_subset_DF)

corrplot(mat_subset, method = "color", type = "lower", 
                      mar = c(1,1,1,1), order = "alphabet", tl.col = "black", tl.cex = 0.6, is.corr = FALSE)


# Using ggcorplot

png(height=800, width=800, file="D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Rasters/Calibration_ascii_props/Cor_plot_final.png", type = "cairo")

ggcorrplot(mat_subset, method = "square", type = "upper", ggtheme = ggplot2::theme_minimal, title = "",
           show.legend = F, show.diag = FALSE,
           colors = c("blue", "white", "red"), outline.color = "gray",
           hc.order = FALSE, hc.method = "complete", lab = T,
           lab_col = "black", lab_size = 7, p.mat = NULL, sig.level = 0.05,
           insig = c("pch", "blank"), pch = 4, pch.col = "black",
           pch.cex = 5, tl.cex = 20, tl.col = "black", tl.srt = 45,
           digits = 2)

dev.off()
```
