### Extrapolation Risk
>The following code calculates a mobility-oriented parity (MOP) layer by comparing environmental values between the calibration area and the area or scenario to which an ecological niche model is transferred (i.e., Argentina) 

```r
# Create raster stack for M and save as tif

path = ("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/Calibration_M_red")
files_M <- list.files(path = path, pattern = ".asc$", full.names = T)
stack_M <- stack(files_M)
stack_M <- rast(stack_M)  
terra::writeRaster(stack_M, filename="D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/MOP_mop/Stack_M.tif", overwrite=TRUE)

# Create raster stack for G and save as tif

path = ("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/Projection_G_red")
files_G <- list.files(path = path, pattern = ".asc$", full.names = T)
stack_G <- stack(files_G)
stack_G <- rast(stack_G)
terra::writeRaster(stack_G, filename="D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/MOP_mop/Stack_G.tif", overwrite=TRUE)

gvars <- raster::stack("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/MOP_mop/Stack_G.tif")
names(gvars)
mvars <- raster::stack("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/MOP_mop/Stack_M.tif")

mop <- kuenm_mop(M.variables = mvars,
           G.stack = gvars,
           percent = 10,
           comp.each = 2000,
           parallel = FALSE)

writeRaster(mop, "D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Ciclo_1/MOP_mop/Mop_output.tif") 
```