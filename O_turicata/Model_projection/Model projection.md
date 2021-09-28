### Calibration of models

The function kuenm_cal creates and executes a batch file for generating Maxent candidate models that will be written in subdirectories, named as the parameterizations selected, inside the output directory (Figure 1, light green area). Calibration models will be created with multiple combinations of regularization multipliers, feature classes, and sets of environmental predictors. For each combination, this function creates one Maxent model with the complete set of occurrences and another with training occurrences only. On some computers, the user will be asked if ruining the batch file is allowed before the modeling process starts in Maxent.

Maxent will run in command-line interface (do not close the application) and its graphic interface will not show up, to avoid interfering with activities other than the modeling process.
