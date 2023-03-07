### Mapping of model results

#### Loading libraries

```r
pkgs <- c("tidyverse","sf","stars","paletteer","gridExtra","readr","magrittr","raster)
new.pkgs <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(new.pkgs)) install.packages(new.pkgs)
lapply(pkgs, require, character.only = TRUE)
```

#### Mapping ENM on calibration area

```r
# Load calibration area raster (mean)
dt1 <- raster("./Masking_water/Masked_model.tif")

# Conversion to SpatialPointsData and then to dataframe for plotting in two steps  
full_pts <- rasterToPoints(dt1, spatial = TRUE)
full_df  <- data.frame(full_pts)

# Load occurrences
occ <- read_delim("./Occs/O_rostratus.csv", delim = ",") %>%
  filter(!is.na(Long),
         !is.na(Lat)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

# Load countries
countries <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/Countries_O_rostratus.gpkg")

# Compute countries centroids for labels
sa_ctroids <- cbind(countries, st_coordinates(st_centroid(countries)))
sa_ctroids1 <- sa_ctroids %>% mutate(COUNTRY =
                                     case_when(NAME_0 == "Argentina" ~ "Arg", 
                                               NAME_0 == "Bolivia" ~ "Bol",
                                               NAME_0 == "Brazil" ~ "Bra",
                                               NAME_0 == "Chile" ~ "Chi",
                                               NAME_0 == "Paraguay" ~ "Par",
                                               NAME_0 == "Uruguay" ~ "Uru"))
p1 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = Masked_model)) +
  geom_sf(data = countries, alpha = 0, color = "black", size = 0.5) +
  geom_sf(data= occ, alpha = 1, color = "black", size = 5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.8, 0.25)) +
  theme(legend.key.height = unit(2.5, 'line'), # Change legend key height
        legend.key.width = unit(2, 'line'), # Change legend key width
        legend.title = element_text(size = 15, face = "bold"), #change legend title font size
        legend.text = element_text(size = 13)) +
  geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 7,
            family = "sans", fontface = "bold")
p1

ggsave(plot = p1, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_rostratus/Plots/Model_cont.png", width = 8.3, height = 11.7)
```

#### Plots thresholded models (Maximum training sensitivity plus specificity)

```r
countries <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/Countries_O_rostratus.gpkg")

sa_ctroids <- cbind(countries, st_coordinates(st_centroid(countries)))
sa_ctroids1 <- sa_ctroids %>% mutate(COUNTRY =
                                     case_when(NAME_0 == "Argentina" ~ "Arg", 
                                               NAME_0 == "Bolivia" ~ "Bol",
                                               NAME_0 == "Brazil" ~ "Bra",
                                               NAME_0 == "Chile" ~ "Chi",
                                               NAME_0 == "Paraguay" ~ "Par",
                                               NAME_0 == "Uruguay" ~ "Uru"))

# Load thresholded model
dt1 <- raster("D:/LFLS/Analyses/MNE_garrapatas/Modelado_rostratus/Ciclo_4/Final_models_rasters/cal_area_mean_thresh_MSS.tif")

# Conversion to SpatialPointsData and then to dataframe for plotting in two steps
full_pts <- rasterToPoints(dt1, spatial = TRUE)
full_df  <- data.frame(full_pts)

full_bin = full_df %>% mutate(Group =
                              case_when(cal_area_mean_thresh_MSS == 0 ~ "Absence", 
                                        cal_area_mean_thresh_MSS == 1 ~ "Presence")) 

p2 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = countries, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.8, 0.25)) +
  theme(legend.key.height = unit(2.5, 'line'), # Change legend key height
        legend.key.width = unit(2, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), #change legend title font size
        legend.text = element_text(size = 13)) + #change legend text font size
  scale_fill_manual(values=c("#0099AB","#ff0066")) +
  geom_text(data = sa_ctroids1, aes(X, Y, label = COUNTRY), size = 7,
            family = "sans", fontface = "bold")
p2

ggsave(plot = p2, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_rostratus/Plots/Final_thresh.png", width = 8.3, height = 11.7)
```
