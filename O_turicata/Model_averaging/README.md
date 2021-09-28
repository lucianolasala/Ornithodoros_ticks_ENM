## Model Averaging

The following code calculates raster layers with selected descriptive statistics of all model replicates across multiple parameter settings. All of this, discriminating among models transferred to distinct projection areas (scenarios).


```r
sp_name <- "O_turicata"
fmod_dir <- "Final_models"
format <- "asc"
project <- TRUE

stats <- c("med", "mean", "sd", "min", "max", "range")
rep <- TRUE
out_dir <- "Final_Model_Stats"
ext_type <- c("E","EC","NE")
scenarios <- "Current" 

kuenm_modstats(sp.name = sp_name, fmod.dir = fmod_dir, format = format, project = project,
               statistics = stats, ext.type = ext_type, proj.scenarios = scenarios, replicated = rep,
               out.dir = out_dir)
```
