### Occurrence data processing for kuenm
>Split occurrence files in training and testing data

```r
occs <- read.csv("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling_RSP/Occs/O_turicata.csv")
train_prop <- 0.5
method = "random"
data_split <- kuenm_occsplit(occ = occs, train.proportion = train_prop,
                             method = method, save = T, name = "occ")
```