
## Niche Modeling for *Ornithodoros* spp. Ticks in Argentina.

<img align="right" width="100" height="100" src="https://user-images.githubusercontent.com/20196847/121586179-ba0f1880-ca09-11eb-9a69-e4f534fafc6b.jpg">

<img align="right" width="100" height="100" src="https://user-images.githubusercontent.com/20196847/121600383-c3ed4780-ca1a-11eb-812c-e30c7c034790.png">


>* **Luciano F. La Sala**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.  
>* **Nicolás Caruso**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.
>* **M. Jimena Marfil**, Facultad de Ciencias Veterinarias, Universidad de Buenos Aires. 

Introduction 
----------  
This repository contains the R scripts and details of methods employed for the development and transfer of ecological niche models (henceforth ENM) for *Ornithodoros* spp. ticks in contiguous Argentina and neighboring countries.
This repository serves as a dynamic document for other parties interested on the ecology of Wild boar and it will be updated as additional data is gathered and new methodological methods are developed. 
The code included in the repository is divided into a series of separate scripts that should be run sequentially.

A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/).   

Table of Contents 
----------

### General

[1. Modeling workflow](./Modeling_workflow.md)

#### <ins>*Ornithodoros turicata*</ins>

[1. Geospatial data processing](./O_turicata/GEE_raster_processing/README.md)  
- [Variables](./O_turicata/GEE_raster_processing/Variables.md)
- [Links scripts Engine](./O_turicata/GEE_raster_processing/Links_scripts.md)

[2. Environmental variables selection](./O_turicata/Environmental_variables_selection/Variables_selection.md) 

[3. Calibration area](./O_turicata/Calibration_area/Calibration_area.md)

[4. Occurrence data preparation](./O_turicata/Occurrence_data/Occurrence_data.md)

[5. Model calibration, evaluation, final model creation & model projection](./O_turicata/Model_cal_eval_proj/Model_cal_eval_proj.md)

[6. Extrapolation risk analysis](./O_turicata/Extrapolation_risk/Extrapolation_risk.md)

[7. Final analysis](./O_turicata/Final_analysis/Final_analysis.md)

[8. Suitability maps](./O_turicata/Maps/Maps.md)

#### <ins>*Ornithodoros coriaceus*</ins> p

[1. Geospatial data processing](./O_rostratus/GEE_raster_processing/README.md)  
- [Variables](./O_rostratus/GEE_raster_processing/Variables.md)
- [Links scripts Engine](./O_rostratus/GEE_raster_processing/Links_scripts.md)

[2. Environmental variables selection](./O_rostratus/Environmental_variables_selection/Variables_selection.md) 

[3. Calibration area](./O_rostratus/Calibration_area/Calibration_area.md)

[4. Calibration area](./O_rostratus/Calibration_area/Calibration_area.md)

[5. Occurrence data preparation](./O_rostratus/Occurrence_data/Occurrence_data.md)

[6. Model calibration, evaluation & final model creation ](./O_rostratus/Model_cal_eval/Model_cal_eval_final.md)

[7. Final analysis](./O_rostratus/Final_analysis/Final_analysis.md)

[8. Suitability maps](./O_rostratus/Maps/Maps.md)

#### <ins>*Ornithodoros rostratus*</ins>

[1. Geospatial data processing](./O_rostratus/GEE_raster_processing/README.md)  
- [Variables](./O_rostratus/GEE_raster_processing/Variables.md)
- [Links scripts Engine](./O_rostratus/GEE_raster_processing/Links_scripts.md)

[2. Environmental variables selection](./O_rostratus/Environmental_variables_selection/Variables_selection.md) 

[3. Calibration area](./O_rostratus/Calibration_area/Calibration_area.md)

[4. Calibration area](./O_rostratus/Calibration_area/Calibration_area.md)

[5. Occurrence data preparation](./O_rostratus/Occurrence_data/Occurrence_data.md)

[6. Model calibration, evaluation & final model creation ](./O_rostratus/Model_cal_eval/Model_cal_eval_final.md)

[7. Final analysis](./O_rostratus/Final_analysis/Final_analysis.md)

[8. Suitability maps](./O_rostratus/Maps/Maps.md)

