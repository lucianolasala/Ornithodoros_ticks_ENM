## Extrapolation Risk

The following code calculates a mobility-oriented parity (MOP) layer by comparing environmental values between the calibration area and the area or scenario to which an ecological niche model is transferred (i.e., Argentina) 

```r
outmop <- "MOP_results"
M_var_dir <- "Calibration_M"
G_var_dir <- "Projection_G"

kuenm_mop(G.var.dir = G_var_dir, M.var.dir = M_var_dir, sets.var = "Set_1", 
           out.mop = outmop, percent = 0.5, comp.each = 100, is.swd = FALSE)
```