### Google Earth Engine: a cloud-computing platform for global-scale earth observation data and analysis

Clould computing using Google Earth Engine (https://earthengine.google.com/) is described for each of the variables included in model calibration and projection.
For the present work, two different assets (i.e. calibration and projection areas) were defined using vector files (ESRI shapefiles). These areas were defined as M and G, respectively. All the analyses were implemented using the Earth Engine API available in JavaScript. 

##### Table 1. Elevation, climate and vegetation variables 

|Variable          |Band             |Reducer      |Spatial resol. |Temporal resol. |GEE snippet<sup>*</sup> |   
|------------------|-----------------|-------------| --------------|--------------- |----------------------- |
|DEM               |elevation        |NA           |90 m           |NA              |CGIAR/SRTM90_V4         |
|Vegetation index  |EVI              |Mean         |1 km           |2000-2020       |MODIS/006/MOD13A2       |           |Global precip.    |precipitationCal |Anual mean   |0.1 deg.       |2000-2021	      |NASA/GPM_L3/IMERG_V06   |    
|Land surface temp.|LST_Day_1km      |Mean         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|                  |                 |Min.         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|                  |                 |Max.         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|Land surface temp.|LST_Night_1km    |Mean         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|                  |                 |Min.         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|                  |                 |Max.         |1 km           |2000-2021       |MODIS/006/MOD11A1       |
|Gross prim. prod. |GPP              |Mean         |500 m          |2002-2017       |CAS/IGSNRR/PML/V2       |
|Intercept. canopy |Ei               |Mean         |500 m          |2002-2017       |CAS/IGSNRR/PML/V2       |
|Soil transp.      |Es               |Mean         |500 m          |2002-2017       |CAS/IGSNRR/PML/V2       |
|Vegetation transp.|Ec               |Mean         |500 m          |2002-2017       |CAS/IGSNRR/PML/V2       |


##### Table 2. Soil variables   

|Variable          |Band             |Reducer      |Spatial resol. |Temporal resol. |GEE snippet<sup>*</sup> |   
|------------------|-----------------|-------------| --------------|--------------- |----------------------- |
|Bulk density      |b0               |Mean         |250 m          |1950-2018      |OpenLandMap/SOL/SOL_BULKDENS-FINEEARTH_USDA-4A1H_M/v02 |
|                  |b10              |Mean         |250 m          |1950-2018      | |
|Clay content      |b0               |Mean         |250 m          |1950-2018       |OpenLandMap/SOL/SOL_CLAY-WFRACTION_USDA-3A1A1A_M/v02 |
|                  |b10              |Mean         |250 m          |1950-2018      | |
|Sand content      |b0               |Mean         |250 m          |1950-2018 |OpenLandMap/SOL/SOL_SAND-WFRACTION_USDA-3A1A1A_M/v02 | 
|                  |b10              |Mean         |250 m          |1950-2018      | |
|Water content     |b0               |Mean         |250 m          |1950-2018 |OpenLandMap/SOL/SOL_WATERCONTENT-33KPA_USDA-4B1C_M/v01 |
|                  |b10              |Mean         |250 m          |1950-2018      | |
|Soil pH           |b0               |Mean         |250 m          |1950-2018|OpenLandMap/SOL/SOL_PH-H2O_USDA-4C1A2A_M/v02 |
|                  |b10              |Mean         |250 m          |1950-2018      | | 

***
<sup>*</sup>GEE (Google Earth Engine) collection snippets provide direct reference to data sources.  
 