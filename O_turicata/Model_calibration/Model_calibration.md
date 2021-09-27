
# Model calibration

´´´r
devtools::install_github("marlonecobos/kuenm")

rm(list=ls(all=TRUE))

if(!require(devtools)){
  install.packages("devtools")
}
´´´

#-------------------------------------------------------------------------------
# Calibration of candidate models
#-------------------------------------------------------------------------------

# En modelado 3, solar_rad_mean is removed according to results in modelado 2

gc()
rm(list=ls(all=TRUE))

library(kuenm)

setwd("C:/Users/User/Documents/Analyses/Ticks ENM/Modeling/O_turicata/Modelado 3")

occ_joint <- "occ_joint.csv"     # All occurrences
occ_tra <- "occ_train.csv"       # Training set
M_var_dir <- "Calibration_M"     # Directory containing environmental variables
batch_cal <- "Candidate_Models"  # Creates objet "batch_cal" which after calling kuenm_cal runs models in batch mode
# and dumps them into Candidate_Models directory

out_dir <- "Candidate_Models"    # The folder Candidate_Models has two folders or models for each combination
# of RM, feature and set of variables (here, only one set is used). Why is that? 
# Because we test pROC and omission rate using models that are constructed only with
# training data ("_cal"), but you test AICc with models that are created
# with the complete set of occurrences ("_all").

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

