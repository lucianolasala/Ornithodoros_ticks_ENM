## Modeling Workflow.

Here, models were built in sequential cycles (i.e., Cycle 1, Cycle 2, etc.), each of which consisted of three main steps: 

1) Calibration of candidate models: we used the function *kuenm_cal*, which generates candidate models to test multiple parameter combinations, including distinct regularization multiplier values (RM), various feature classes (FC), and different environmental variables.

2) Evaluation of candidate models: we used the function *kuenm_ceval*, which evaluates candidate models in terms of statistical significance (partial ROC), prediction ability (omission rates), and model complexity (AICc). After evaluation, this function selects the best models based on user-defined criteria.


