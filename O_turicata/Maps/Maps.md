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
dt1 <- raster("./Final_models_rasters/cal_area_mean.tif")

# Load occurrences
occ <- read_delim("D:/LFLS/Analyses/Ticks ENM/Ocurrencias/O_turicata.csv", delim = ",") %>%
  filter(!is.na(Long),
         !is.na(Lat)) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326)

# Load calibration area vectors: ecoregions and countries
sa <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Vectors/O_turicata_M/O_turicata_dissolved.gpkg")
paises <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Vectors/O_turicata_M/paises_turicata.gpkg")

# Conversion to SpatialPointsData and then to dataframe for plotting in two steps  
full_pts <- rasterToPoints(dt1, spatial = TRUE)
full_df  <- data.frame(full_pts)

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
  theme(legend.key.size = unit(1.5, 'line'), 
        legend.key.height = unit(1.5, 'line'), 
        legend.key.width = unit(1, 'line'), 
        legend.title = element_text(size = 14, face = "bold"), 
        legend.text = element_text(size = 12)) + 
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
```

#### Mapping ENM on projection area

```r
# Load projected model (mean)
dt2 <- raster("./Final_models_rasters/proj_area_mean.tif")

# Load projection area vector
arg <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/ARG_adm/ARG_adm1.shp")
sa_ctroids1 <- cbind(arg, st_coordinates(st_centroid(arg)))
sa_ctroids2 <- sa_ctroids1 %>% mutate(STATE =
                                      case_when(NAME_1 == "Buenos Aires" ~ "B", 
                                                NAME_1 == "Córdoba" ~ "X",
                                                NAME_1 == "Catamarca" ~ "K",
                                                NAME_1 == "Chaco" ~ "H",
                                                NAME_1 == "Chubut" ~ "U",
                                                NAME_1 == "Ciudad de Buenos Aires" ~ "C",
                                                NAME_1 == "Corrientes" ~ "W",
                                                NAME_1 == "Entre Ríos" ~ "E",
                                                NAME_1 == "Formosa" ~ "P",
                                                NAME_1 == "Jujuy" ~ "Y",
                                                NAME_1 == "La Pampa" ~ "L",
                                                NAME_1 == "La Rioja" ~ "F",
                                                NAME_1 == "Mendoza" ~ "M",
                                                NAME_1 == "Misiones" ~ "N",
                                                NAME_1 == "Neuquén" ~ "Q",
                                                NAME_1 == "Río Negro" ~ "R",
                                                NAME_1 == "San Juan" ~ "J",
                                                NAME_1 == "San Luis" ~ "D",
                                                NAME_1 == "Santa Cruz" ~ "Z",
                                                NAME_1 == "Santa Fe" ~ "S",
                                                NAME_1 == "Santiago del Estero" ~ "G",
                                                NAME_1 == "Tierra del Fuego" ~ "V",
                                                NAME_1 == "Tucumán" ~ "T"))

# Conversion to SpatialPointsData and then to dataframe for plotting in two steps
full_pts <- rasterToPoints(dt2, spatial = TRUE)
full_df  <- data.frame(full_pts)

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
  theme(legend.key.size = unit(10, 'line'), 
        legend.key.height = unit(2.5, 'line'), 
        legend.key.width = unit(2, 'line'), 
        legend.title = element_text(size = 18, face = "bold"), 
        legend.text = element_text(size = 16)) + 
  theme(plot.margin = unit(c(4,0,4,0), "pt")) +
  geom_text(data = sa_ctroids2, aes(X, Y, label = STATE), size = 7,
            family = "sans", fontface = "bold") + 
  annotate("text", label = "A", x = -65.0, y = -25, color = "black", size = 7, fontface = 2)
p2
ggsave(plot = p2, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/Maps/Final_O.turicata_proj.png", width = 8.3, height = 11.7)
```

#### Ploting threshold models (maximum training sensitivity plus specificity)

```r
arg <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/ARG_adm/ARG_adm1.shp")
sa_ctroids1 <- cbind(arg, st_coordinates(st_centroid(arg)))
sa_ctroids2 <- sa_ctroids1 %>% mutate(STATE =
                                      case_when(NAME_1 == "Buenos Aires" ~ "B", 
                                                NAME_1 == "Córdoba" ~ "X",
                                                NAME_1 == "Catamarca" ~ "K",
                                                NAME_1 == "Chaco" ~ "H",
                                                NAME_1 == "Chubut" ~ "U",
                                                NAME_1 == "Ciudad de Buenos Aires" ~ "C",
                                                NAME_1 == "Corrientes" ~ "W",
                                                NAME_1 == "Entre Ríos" ~ "E",
                                                NAME_1 == "Formosa" ~ "P",
                                                NAME_1 == "Jujuy" ~ "Y",
                                                NAME_1 == "La Pampa" ~ "L",
                                                NAME_1 == "La Rioja" ~ "F",
                                                NAME_1 == "Mendoza" ~ "M",
                                                NAME_1 == "Misiones" ~ "N",
                                                NAME_1 == "Neuquén" ~ "Q",
                                                NAME_1 == "Río Negro" ~ "R",
                                                NAME_1 == "San Juan" ~ "J",
                                                NAME_1 == "San Luis" ~ "D",
                                                NAME_1 == "Santa Cruz" ~ "Z",
                                                NAME_1 == "Santa Fe" ~ "S",
                                                NAME_1 == "Santiago del Estero" ~ "G",
                                                NAME_1 == "Tierra del Fuego" ~ "V",
                                                NAME_1 == "Tucumán" ~ "T"))

# Load thresholded model
dt1 <- raster("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Final_models_rasters/proj_area_mean_thresh_MSS.tif")

# Conversion to SpatialPointsData and then to dataframe for plotting in two steps
full_pts <- rasterToPoints(dt1, spatial = TRUE)
full_df  <- data.frame(full_pts)

full_bin = full_df %>% mutate(Group =
                              case_when(proj_area_mean_thresh_MSS == 0 ~ "Absence", 
                                        proj_area_mean_thresh_MSS == 1 ~ "Presence"))

p3 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = arg, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Suitability") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), 
        legend.key.height = unit(2, 'line'), 
        legend.key.width = unit(1.5, 'line'), 
        legend.title = element_text(size = 16, face = "bold"), 
        legend.text = element_text(size = 14)) + #change legend text font size
  scale_fill_manual(values=c("#ffff66","#ff0066")) + 
  geom_text(data = sa_ctroids2, aes(X, Y, label = STATE), size = 7,
            family = "sans", fontface = "bold") + 
  annotate("text", label = "A", x = -65.0, y = -25, color = "black", size = 7, fontface = 2)
p3
ggsave(plot = p3, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Maps/Final_plot_thresh_MSS.png", width = 8.3, height = 11.7)
```

#### Extrapolation risk analysis (MOP) binary map
```r
arg <- st_read("D:/LFLS/Analyses/MNE_garrapatas/Vector data/Mapas politicos/ARG_adm/ARG_adm1.shp")
sa_ctroids1 <- cbind(arg, st_coordinates(st_centroid(arg)))
sa_ctroids2 <- sa_ctroids1 %>% mutate(STATE =
                                      case_when(NAME_1 == "Buenos Aires" ~ "B", 
                                                NAME_1 == "Córdoba" ~ "X",
                                                NAME_1 == "Catamarca" ~ "K",
                                                NAME_1 == "Chaco" ~ "H",
                                                NAME_1 == "Chubut" ~ "U",
                                                NAME_1 == "Ciudad de Buenos Aires" ~ "C",
                                                NAME_1 == "Corrientes" ~ "W",
                                                NAME_1 == "Entre Ríos" ~ "E",
                                                NAME_1 == "Formosa" ~ "P",
                                                NAME_1 == "Jujuy" ~ "Y",
                                                NAME_1 == "La Pampa" ~ "L",
                                                NAME_1 == "La Rioja" ~ "F",
                                                NAME_1 == "Mendoza" ~ "M",
                                                NAME_1 == "Misiones" ~ "N",
                                                NAME_1 == "Neuquén" ~ "Q",
                                                NAME_1 == "Río Negro" ~ "R",
                                                NAME_1 == "San Juan" ~ "J",
                                                NAME_1 == "San Luis" ~ "D",
                                                NAME_1 == "Santa Cruz" ~ "Z",
                                                NAME_1 == "Santa Fe" ~ "S",
                                                NAME_1 == "Santiago del Estero" ~ "G",
                                                NAME_1 == "Tierra del Fuego" ~ "V",
                                                NAME_1 == "Tucumán" ~ "T"))

# Load MOP raster, conversion to SpatialPointsData and then to dataframe for plotting in two steps
dt <- raster("./Mop_output.tif")
full_pts <- rasterToPoints(dt, spatial = TRUE)
full_df  <- data.frame(full_pts)

full_bin = full_df %>% mutate(Group =
                              case_when(Mop_output == 0 ~ "Extrapolation risk", 
                                        Mop_output <= 1 ~ "No extrapolation risk")) 

p4 <- ggplot() +
  geom_raster(data = full_bin, aes(x = x, y = y, fill = Group)) +
  geom_sf(data = arg, alpha = 0, color = "black", size = 0.5) +
  coord_sf() +
  labs(x = "Longitude", y = "Latitude", fill = "Wild boar") +
  theme(axis.title.x = element_text(margin = margin(t = 20, r = 0, b =0, l = 0), size = 22),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0), size = 22), 
        axis.text.x = element_text(colour = "black", size = 18),
        axis.text.y = element_text(colour = "black", size = 18)) +
  theme(legend.position = c(0.75, 0.15)) +
  theme(legend.key.size = unit(2, 'line'), 
        legend.key.height = unit(2, 'line'), 
        legend.key.width = unit(1.5, 'line'), 
        legend.title = element_text(size = 16, face = "bold"),
        legend.text = element_text(size = 14)) + 
        labs(fill = "Extrapolation risk") +
  scale_fill_manual(values=c("#ff0066","#D5DBDB")) +
  geom_text(data = sa_ctroids2, aes(X, Y, label = STATE), size = 7,
            family = "sans", fontface = "bold") + 
  annotate("text", label = "A", x = -65.0, y = -25, color = "black", size = 7, fontface = 2)
p4
ggsave(plot = p4, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/Maps/MOP_binary.png", width = 8.3, height = 11.7)
```


