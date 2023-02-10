```r

rm(list=ls(all=TRUE))

library(tidyverse)
library(stars)
library(sf)
library(paletteer)
library(gridExtra)
library(readr)
library(magrittr)
library(raster)

setwd("D:/LFLS/Analyses/Jabali_ENM/Modelado_7")


#---------------------------------------------------------
# Plot LFLS
#---------------------------------------------------------

rm(list=ls(all=TRUE))
ls()

setwd("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata")

# Load cal and proj areas

dt1 <- raster("./Final_models_rasters/cal_area_mean.tif")

# Load occurrences

occ <- read_delim("D:/LFLS/Analyses/Ticks ENM/Ocurrencias/O_turicata.csv", delim = ",") %>%
  filter(!is.na(Long),
         !is.na(Lat)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

# Load calibration area

sa <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Vectors/O_turicata_M/O_turicata_dissolved.gpkg")
paises <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Vectors/O_turicata_M/paises_turicata.gpkg")

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(dt1, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)

#--------------------------------------------------
# Map calibration area
#--------------------------------------------------

p1 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = cal_area_mean)) +
  geom_sf(data = paises, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 20),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 20), 
        axis.text.x = element_text(colour = "black", size = 16),
        axis.text.y = element_text(colour = "black", size = 16)) +
  theme(legend.position = c(0.9, 0.25)) +
  theme(legend.key.size = unit(1.5, 'line'), # Change legend key size
        legend.key.height = unit(1.5, 'line'), # Change legend key height
        legend.key.width = unit(1, 'line'), # Change legend key width
        legend.title = element_text(size = 14, face = "bold"), #change legend title font size
        legend.text = element_text(size = 12)) + # Change legend text font size
  
  annotate(geom = "text", x = -105, y = 45, label = "US", color="black", size=7) +
  annotate(geom = "text", x = -102.5, y = 25, label = "MX", color="black", size=7) +
  annotate(geom = "text", x = -87, y = 17, label = "BZ", color="black", size=7) +
  annotate(geom = "text", x = -89, y = 12.5, label = "SV", color="black", size=7) +
  annotate(geom = "text", x = -92, y = 13, label = "GT", color="black", size=7) +
  annotate(geom = "text", x = -86.5, y = 10.5, label = "NI", color="black", size=7) +
  annotate(geom = "text", x = -84.5, y = 17, label = "HN", color="black", size=7) +
  theme(plot.margin = unit(c(0.5,8,-8,8), "pt")) # top, right, bottom, left

p1

ggsave(plot = p1, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Maps/Final_O.turicata_cal.png", width = 14, height = 14)


#--------------------------------------------------
# Map projection area
#--------------------------------------------------

rm(list=ls(all=TRUE))

setwd("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata")

# Load projected model

dt2 <- raster("./Final_models_rasters/proj_area_mean.tif")

# Load projection area

arg <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/ARG_adm/ARG_adm1.shp")
st_crs(argentina)  # WGS 84

# Convert to a df for plotting in two steps,
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(dt2, spatial = TRUE)

# Then to a 'conventional' dataframe

full_df  <- data.frame(full_pts)
head(full_df)

p2 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = proj_area_mean)) +
  geom_sf(data = arg, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.20)) +
  theme(legend.key.size = unit(10, 'line'), # Change legend key size
        legend.key.height = unit(2.5, 'line'), # Change legend key height
        legend.key.width = unit(2, 'line'), # Change legend key width
        legend.title = element_text(size = 18, face = "bold"), #change legend title font size
        legend.text = element_text(size = 16)) + # Change legend text font size
  theme(plot.margin = unit(c(4,0,4,0), "pt"))
  
p2

ggsave(plot = p2, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Maps/Final_O.turicata_proj.png", width = 8.3, height = 11.7)


#-------------------------------------------------------------------------
# Plots threshold models (Maximum training sensitivity plus specificity
# as threshold)
#-------------------------------------------------------------------------

rm(list=ls(all=TRUE))

arg <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/ARG_adm/ARG_adm1.shp")
st_crs(arg)  # WGS 84
arg$NAME_1

sa_ctroids1 <- cbind(arg, st_coordinates(st_centroid(arg)))

sa_ctroids2 <- sa_ctroids1 %>% mutate(STATE =
                                        case_when(NAME_1 == "Buenos Aires" ~ "B", 
                                                  NAME_1 == "Córdoba" ~ "X",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ "",
                                                  NAME_1 == "" ~ ""))

# Load thresholded calibration and projection areas

dt1 <- raster("D:/LFLS/Analyses/Ticks ENM/Modelado/Final_models_rasters/proj_area_mean_thresh_MSS.tif")

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(dt1, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)
head(full_df)

full_bin = full_df %>% mutate(Group =
                              case_when(proj_area_mean_thresh_MSS == 0 ~ "Absence", 
                                        proj_area_mean_thresh_MSS == 1 ~ "Presence")) 
head(full_bin)
class(full_bin)

p3 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = argentina, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), #change legend title font size
        legend.text = element_text(size = 14)) + #change legend text font size
  scale_fill_manual(values=c("#ffff66","#ff0066")) 
#  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
#            family = "sans", fontface = "bold")
p3

ggsave(plot = p3, "D:/LFLS/Analyses/Ticks ENM/Modelado/Mapas/Final_plot_thresh_MSS.png", width = 8.3, height = 11.7)



#---------------------------------------------------------
# Plots thresholded models (5% omission error as threshold)
#---------------------------------------------------------

rm(list=ls(all=TRUE))

sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Saco Malvinas

sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
               case_when(NAME == "ARGENTINA" ~ "Arg", 
                         NAME == "BOLIVIA" ~ "Bol",
                         NAME == "BRAZIL" ~ "Bra",
                         NAME == "CHILE" ~ "Chi",
                         NAME == "PARAGUAY" ~ "Par",
                         NAME == "URUGUAY" ~ "Uru"))
  

# Load thresholded calibration and projection areas

dt1 <- raster("./Final_models/cal_area_median_thresh_5.tif")
dt2 <- raster("./Final_models/proj_area_median_thresh_5.tif")

# Merging rasters

full <- raster::merge(dt1, dt2)
class(full)

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)
head(full_df)

full_bin = full_df %>% mutate(Group =
                    case_when(layer == 0 ~ "Absence", 
                              layer == 1 ~ "Presence")) 
head(full_bin)

p5 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), #change legend title font size
        legend.text = element_text(size = 14)) + #change legend text font size
        scale_fill_manual(values=c("#ffff66","#ff0066")) +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
  p5

ggsave(plot = p5, "./Plots/Final_plot_thresh.png", width = 8.3, height = 11.7)



#--------------------------------------------------------------
# MOP binary
#--------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("D:/LFLS/Analyses/Jabali_ENM/Modelado_7")

sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Saco Malvinas

sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))

# Load MOP rasters for calibration and projection areas

dt1 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_cal.tif")
dt2 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_proj.tif")

# Merging rasters

full <- raster::merge(dt1, dt2)

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)

full_bin = full_df %>% mutate(Group =
                                case_when(layer == 0 ~ "Present", 
                                          layer <= 1 ~ "Absent")) 
head(full_bin)

p6 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
        labs(fill = "Extrapolation risk") +
  scale_fill_manual(values=c("#ffff66","#ff0066")) +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
p6

ggsave(plot = p6, "./Plots/MOP_binary.png", width = 8.3, height = 11.7)

#--------------------------------------------------------------
# MOP continuous
#--------------------------------------------------------------

rm(list=ls(all=TRUE))

setwd("D:/LFLS/Analyses/Jabali_ENM/Modelado_6")

sa <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina_and_bordering_WGS84.shp")

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(sa)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Saco Malvinas

sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))

# Load MOP rasters for calibration and projection areas

dt1 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_cal.tif")
dt2 <- raster("./MOP_results/Set_1/MOP_50%_Scenario_proj.tif")

# Merging rasters

full <- raster::merge(dt1, dt2)

# Convert to a dataframe for plotting in two steps:
# First, to a SpatialPointsDataFrame

full_pts <- rasterToPoints(full, spatial = TRUE)

# Second, to a "conventional" dataframe

full_df  <- data.frame(full_pts)
head(full_df)

p7 <- ggplot() +
  geom_raster(data = full_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(data = sa, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  scale_fill_paletteer_binned("oompaBase::jetColors", na.value = "transparent", n.breaks = 9) +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
  labs(fill = "Extrapolation risk") +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
p7

ggsave(plot = p7, "./Plots/MOP_continuous.png", width = 8.3, height = 11.7)

#----------------------------------------------------------
# Study region and ecoregions
#----------------------------------------------------------

eco_cal <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Ecorregions_study_region_occ_dissolved.shp")
eco_cal

eco_proj <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Ecorregions_study_region_wo_occ_dissolved.shp") 
eco_proj

countries <- st_read("D:/LFLS/Analyses/Jabali_ENM/Vectors/Argentina and bordering countries.shp")
st_crs(countries)  # Coordinate Reference System: NA

count_crs = st_crs(4326)

countries_WGS = countries %>% st_set_crs(count_crs)
st_crs(countries_WGS)

sa_ctroids1 <- cbind(sa, st_coordinates(st_centroid(countries_WGS)))
sa_ctroids2 <- sa_ctroids1[-7,]  # Saco Malvinas

sa_ctroids3 <- sa_ctroids2 %>% mutate(COUNTRY =
                                        case_when(NAME == "ARGENTINA" ~ "Arg", 
                                                  NAME == "BOLIVIA" ~ "Bol",
                                                  NAME == "BRAZIL" ~ "Bra",
                                                  NAME == "CHILE" ~ "Chi",
                                                  NAME == "PARAGUAY" ~ "Par",
                                                  NAME == "URUGUAY" ~ "Uru"))


p8 <- ggplot() +
  geom_sf(data = eco_cal, alpha = 1, color = "black", size = 0.5, aes(fill = NAME), show.legend = T) +
  geom_sf(data = eco_proj, alpha = 1, color = "black", size = 0.5, aes(fill = NAME), show.legend = T) + 
  geom_sf(data = countries_WGS, alpha = 0, color = "#e60000", size = 0.4) +
  scale_fill_manual(values = c("#2ECC71","#FFFFFF")) +
  labs(x = "Longitude", y = "Latitude") +
  coord_sf() +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), # Change legend key size
        legend.key.height = unit(2, 'line'), # Change legend key height
        legend.key.width = unit(1.5, 'line'), # Change legend key width
        legend.title = element_text(size = 16, face = "bold"), # Change legend title font size
        legend.text = element_text(size = 14)) + # Change legend text font size
  labs(fill = "Area") +
  geom_text(data = sa_ctroids3, aes(X, Y, label = COUNTRY), size = 8,
            family = "sans", fontface = "bold")
  
p8  

ggsave(plot = p8, "./SA_cal_proj.png", width = 8.3, height = 11.7)
´´´

#---------------------------------------------------------------
# Parking lot
#---------------------------------------------------------------

# annotate("text", x = -64.0, y = 0, label = "G", color = "black", size = 5, fontface = 2) 
```

