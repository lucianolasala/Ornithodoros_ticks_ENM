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

