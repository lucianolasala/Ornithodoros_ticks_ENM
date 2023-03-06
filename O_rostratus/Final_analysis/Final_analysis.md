### Final analysis
>The following scrips produce rasters sumarizing model outputs in the clibrarion and 
projection areas using mean, standard deviation and median.

#### Loading libraries
```r
pkgs <- c("tidyverse","sf","stars","stringr","raster","terra")
new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs)) install.packages(new.pkgs)
lapply(pkgs, require, character.only = TRUE)
```

#### Merging all output
```r
selected <- read_csv("./Best_models/best_candidate_models_OR_AICc.csv")
selected_grid <- expand_grid(mod = selected$Model, mn = 0:9)
```

#### Calibration area
```r
paths <- str_c("./Final_models_no_proj/", selected_grid$mod, "/Ornithodoros_rostratus_", selected_grid$mn, ".asc")  # Selecciona ASC correspondientes a calibracion
names <- str_c(selected_grid$mod, "Ornithodoros_rostratus_", selected_grid$mn)

mean <- read_stars(paths) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = mean) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models_rasters/cal_area_mean.tif", chunk_size = c(2000, 2000), NA_value = -9999)

sd <- read_stars(paths) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = function (x) sd(as.vector(x))) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models_rasters/cal_area_sd.tif", chunk_size = c(2000, 2000), NA_value = -9999)

median <- read_stars(paths1) %>%
  set_names(names1) %>%
  merge() %>%
  st_apply(MARGIN = c(1, 2), FUN = median) %>%
  st_set_crs(4326) %>%
  write_stars("./Final_models_rasters/cal_area_median.tif", chunk_size = c(2000, 2000), NA_value = -9999)
```

#### Thresholding: maximum training sensitivity plus specificity
```r
paths <- str_c("./Final_models_no_proj/", selected$Model, "/maxentResults.csv")

get.thresholds <- function(x){
  th <- read_csv(x) %>%
    pull("Maximum training sensitivity plus specificity Cloglog threshold")
  th <- th[1:10]
  return(th)
}

th <- map(paths, get.thresholds) %>%
  unlist() %>%
  mean()

mean1.th <- read_stars("./Final_models_rasters/cal_area_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when(z >= th ~ 1,
                       z < th ~ 0)) %>%
  write_stars("./Final_models_rasters/cal_area_mean_thresh_MSS.tif")
```
