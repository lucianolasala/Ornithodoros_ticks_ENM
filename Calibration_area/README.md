
### Predicting the distribution of domestic birds in Argentina

The script file is named [Calibration_projection_areas.R](./Calibration_projection_areas.R).


```r
devtools::install_github("marlonecobos/kuenm")

rm(list=ls(all=TRUE))

if(!require(devtools)){
  install.packages("devtools")
}

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 

```