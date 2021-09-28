## Model calibration

The following code generates candidate models to test multiple parameter combinations, including distinct regularization multiplier values, various feature classes, and different environmental variables in the same set.   

```r
occ_joint <- "occ_joint.csv"     
occ_tra <- "occ_train.csv"       
M_var_dir <- "Calibration_M"     
batch_cal <- "Candidate_Models"   

out_dir <- "Candidate_Models"    
candir <- "Candidate_models"
reg_mult <- c(0.1, 0.25, 0.5, 0.75, 1, 2.5, 5)
f_clas <- "basic"
args <- NULL
mxpath <- "C:/Users/User/Desktop/maxent"
wait <- FALSE
run <- TRUE

kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, 
          batch = batch_cal, out.dir = out_dir, 
          reg.mult = reg_mult, f.clas = f_clas, args = args, 
          maxent.path = mxpath, wait = wait, run = run)
```
