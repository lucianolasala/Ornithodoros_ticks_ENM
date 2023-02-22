### Enhanced Vegetation Index (EVI)

```r
var EVI_mean_params = {
  min: 115.33827861952862,
  max: 5906.39822706229,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

var EVI_max_params = {
  min: 137.7,
  max: 6915.1,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

var EVI_min_params = {
  min: 140.575,
  max: 4336.525,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

var EVI_cv_params = {
  min: 0.0158520700045807,
  max: 3.9815492876551066,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

var EVI_sd_params = {
  min: 14.950802381391862,
  max: 2103.6074562973745,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

Map.addLayer(M, {}, 'M')

var EVI = ee.ImageCollection('MODIS/006/MOD13A2')
.filterDate('2001-01-01', '2020-12-31')
.select('EVI');

var scale = EVI.first().projection().nominalScale()
print("Band scale: ", scale);
```

#### Inter-anual aggregation
> Functions to calculate mean year at month resolution
Las siguientes lineas de codigo calculan el año medio es decir 
a partir de la serie temporal de 18 años * 12 meses, genera una serie de 
1 año con 12 meses. La primer imagen de la coleccion es el promedio de los 18 eneros de toda 
la serie, la segunda es el promedio de los 18 febreros y asi sucesivamente 
hasta diciembre. Basicamente generamos una serie anual que considera la 
variabilidad INTER-ANUAL.


```r


var months = ee.List.sequence(1, 12); // Jan through Dec

// EVI
var EVI_mensual = months.map(function(m) {

// Filter to 1 month
var EVI_mean = EVI.filter(ee.Filter.calendarRange(m, m, 'month')).mean();


// ee.Filter.calendarRange(start, end, field)

// add month band for MMax
  return EVI_mean;
});

var EVI_mensual = ee.ImageCollection(EVI_mensual);

// Esa linea lo único que hace es "declararle" al GEE que lo que sale de la función es una 
// colección de imágenes

print('EVI', EVI_mensual)

/*
El print lo agrega a la consola y se puede ver la estructura de la coleccion 
de imagens (cantidad de bandas, properties, etc..) pero el valor depende de 
cada pixel. Para ver los valores hay que agregarlo al mapa con Map.addLayer() 
y explorar el raster con el inspector.
*/

// #############################################################################

// AGREGACION TEMPORAL INTRA-ANUAL
// EVI

var EVI_mean = EVI_mensual.mean().rename('EVI-mean').clip(M)
var EVI_max = EVI_mensual.max().rename('EVI-max').clip(M)
var EVI_min = EVI_mensual.min().rename('EVI-min').clip(M)
var EVI_sd = EVI_mensual.reduce(ee.Reducer.stdDev()).rename('EVI-sd').clip(M)
var EVI_cv = EVI_sd.divide(EVI_mean).rename('EVI-cv').clip(M)

// Add shapefile M


Map.addLayer(EVI_mean,EVI_mean_params,'EVI_mean');
Map.addLayer(EVI_max,EVI_max_params,'EVI_max');
Map.addLayer(EVI_min,EVI_min_params,'EVI_min');
Map.addLayer(EVI_sd,EVI_sd_params,'EVI_sd');
Map.addLayer(EVI_cv,EVI_cv_params,'EVI_cv');

Map.centerObject(M, 4)

// Create region or export area

var ExportArea = ee.Geometry.Rectangle([-125,11,-79.5,46]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

Export.image.toDrive({
  image:EVI_mean, 
  description:'EVI_mean_M',
  folder:'Ticks_ENM',
  crs:'EPSG:4326', 
  maxPixels: 1e13, 
  region:ExportArea,});
  
  
  Export.image.toDrive({
  image:EVI_max, 
  description:'EVI_max_M',
  folder:'Ticks_ENM',
  crs:'EPSG:4326', 
  maxPixels: 1e13, 
  region:ExportArea,});
  
  Export.image.toDrive({
  image:EVI_min, 
  description:'EVI_min_M',
  folder:'Ticks_ENM',
  crs:'EPSG:4326', 
  maxPixels: 1e13, 
  region:ExportArea,});
  
  Export.image.toDrive({
  image:EVI_sd, 
  description:'EVI_sd_M',
  folder:'Ticks_ENM',
  crs:'EPSG:4326', 
  maxPixels: 1e13,
  region:ExportArea,});
  
  Export.image.toDrive({
  image:EVI_cv, 
  description:'EVI_cv_M',
  folder:'Ticks_ENM',
  crs:'EPSG:4326', 
  maxPixels: 1e13, 
  region:ExportArea,});
  ```