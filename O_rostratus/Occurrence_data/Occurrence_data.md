### Occurrence data processing for kuenm
>Split occurrence files in training and testing data

```r
occs <- read.csv("D:/LFLS/Analyses/MNE_garrapatas/Modelado_rostratus/Occs/O_rostratus.csv")
head(occs)
train_prop <- 0.5
method = "random"
data_split <- kuenm_occsplit(occ = occs, train.proportion = train_prop,
                             method = method, save = T, name = "occ")
```