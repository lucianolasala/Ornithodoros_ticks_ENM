
## Niche Modeling for *Ornithodoros* spp. Ticks in Argentina

<img align="right" width="100" height="100" src="https://user-images.githubusercontent.com/20196847/121586179-ba0f1880-ca09-11eb-9a69-e4f534fafc6b.jpg">

<img align="right" width="100" height="100" src="https://user-images.githubusercontent.com/20196847/121600383-c3ed4780-ca1a-11eb-812c-e30c7c034790.png">


>* **Luciano F. La Sala**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.  
>* **Nicolás Caruso**, Instituto de Ciencias Biológicas y Biomédicas del Sur (CONICET-UNS), Bahía Blanca, Argentina.
>* **Julián M. Burgos**, Marine and Freshwater Research Institute, Iceland.  
>* **M. Jimena Marfil**, Facultad de Ciencias Veterinarias, Universidad de Buenos Aires. 

Introduction
----------  
This repository contains the R scripts and details of methods employed for the development and transfer of ecological niche models (henceforth ENM) for Wild boar (*Sus scrofa*) in contiguous Argentina and neighboring countries.
This repository serves as a dynamic document for other parties interested on the ecology of Wild boar and it will be updated as additional data is gathered and new methodological methods are developed. 
The code included in the repository is divided into a series of separate scripts that should be run sequentially.

A Maximum Entropy approach (https://biodiversityinformatics.amnh.org/open_source/maxent/) method was used inside the R programing environment (https://www.r-project.org/).   

Table of Contents 
----------
*Ornithodoros turicata*

### Modeling workflow

[1. Modeling workflow](./Modeling_workflow.md)

[2. Geospatial data processing](./O_turicata/GEE_raster_processing/README.md)  
- [Calibration area](./O_turicata/GEE_raster_processing/Calibration_area)
- [Projection area](./O_turicata/GEE_raster_processing/Projection_area)

[3. Environmental variables selection](./O_turicata/Environmental_variables_selection/README.md) 

### Modelling process

[4. Calibration and projection areas](./Calibration_projection_areas/README.md)

[5. Occurrence data and model calibration](./Occurrence_data_model_calibration.md)

[6. Model calibration](./Model_calibration/README.md)

[7. Model evaluation](./Model_calibration/README.md)

[8. Model projection](./Model_calibration/README.md)

[9. Model validation](./Validation/README.md)

[9. Suitability maps](./plots)

*Ornithodoros rostratus*

