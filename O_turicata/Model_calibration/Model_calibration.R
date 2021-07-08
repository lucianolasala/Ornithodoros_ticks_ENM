# Model calibration

devtools::install_github("marlonecobos/kuenm")

rm(list=ls(all=TRUE))

if(!require(devtools)){
  install.packages("devtools")
}


setwd("C:/Users/User/Documents/Analyses/Ticks ENM/") 

help(kuenm_cal)

occ_joint <- "occ_joint.csv"     # Todas las ocurrencias
occ_tra <- "occ_train.csv"       # Ocurrencias para training set
M_var_dir <- "M_variables"       # Directorio con variables ambientales
batch_cal <- "Candidate_Models"  # Creo un objeto "batch_cal" que despues al llamar
# dentro de kuenm_cal procesa todos los modelos en batch mode
# y los deposita en el directorio Candidate_Models

# The folder Candidate_models has two folders or models for each combination
# of RM, feature and set of variables. Why is that? Because you test pROC 
# and omission rate using models that are constructed only with
# training data ("_cal"), but you test AICc with models that are created
# with the complete set of occurrences ("_all").

out_dir <- "Candidate_Models"    
candir <- "Candidate_models"
reg_mult <- c(0.25,1)
f_clas <- c("l","q")
args <- NULL
mxpath <- "C:/Users/User/Desktop/maxent"
wait <- FALSE
run <- TRUE

kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, 
          batch = batch_cal, out.dir = out_dir, 
          reg.mult = reg_mult, f.clas = f_clas, args = args, 
          maxent.path = mxpath, wait = wait, run = run)
