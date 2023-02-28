### Model calibration

>The following code generates candidate models to test multiple parameter combinations, including distinct regularization multiplier values, various feature classes, and different environmental variables in the same set.   

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

### Model Evaluation
>The following code evaluates candidate models in terms of statistical significance (partial ROC), prediction ability (omission rates), and model complexity (AICc). After evaluation, this function selects the best models based on user-defined criteria.  

```r
cresdir <- "Candidate_Models"
occ_joint <- "occ_joint.csv"
occ_tra <- "occ_train.csv"
occ_test <- "occ_test.csv"
batch_cal <- "Candidate_Models"
out_eval <- "Best_models"
threshold <- 5  
rand_percent <- 50
iterations <- 100
kept <- TRUE
selection <- "OR_AICc"
paral_proc <- FALSE

kuenm_ceval(path=cresdir, occ.joint=occ_joint, occ.tra=occ_tra, 
            occ.test=occ_test, batch=batch_cal, out.eval=out_eval,
            threshold=threshold, rand.percent=rand_percent, 
            iterations=iterations, kept=kept, selection=selection, 
            parallel.proc=paral_proc)
```

### Creation of final models with projection
>The following code creates and executes a batch file (bash for Unix) for generating Maxent models using parameters previously selected with the kuenm_ceval function.

```r
occ_joint <- "./Occs/occ_joint.csv" 
batch_fin <- "Final_models"
moddir <- "Final_models_with_proj"
M_var_dir <- "Calibration_M_fixed"
G_var_dir <- "Projection_G"
out_eval <- "Best_models"
args <- NULL
mxpath <- "C:/Program Files/maxent"

kuenm_mod(occ.joint=occ_joint, M.var.dir=M_var_dir, G.var.dir=G_var_dir, 
          out.eval=out_eval, batch=batch_fin, rep.n=10, args=args,             
          rep.type="Bootstrap", jackknife=TRUE, out.dir=moddir, max.memory=1000, 
          out.format="cloglog", project=TRUE, 
          write.mess=FALSE, write.clamp=FALSE, 
          maxent.path=mxpath, wait=FALSE, run=TRUE)
```
