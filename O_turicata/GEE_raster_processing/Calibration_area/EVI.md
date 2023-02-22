### Enhanced Vegetation Index (EVI)

#### Visualization parameters

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

```r
var months = ee.List.sequence(1, 12);
var EVI_mensual = months.map(function(m) {
var EVI_mean = EVI.filter(ee.Filter.calendarRange(m, m, 'month')).mean();
  return EVI_mean;
});

var EVI_mensual = ee.ImageCollection(EVI_mensual);
print('EVI', EVI_mensual)
```

#### Intra-anual aggregation

```r
var EVI_mean = EVI_mensual.mean().rename('EVI-mean').clip(M)
var EVI_max = EVI_mensual.max().rename('EVI-max').clip(M)
var EVI_min = EVI_mensual.min().rename('EVI-min').clip(M)

Map.addLayer(EVI_mean,EVI_mean_params,'EVI_mean');
Map.addLayer(EVI_max,EVI_max_params,'EVI_max');
Map.addLayer(EVI_min,EVI_min_params,'EVI_min');

Map.centerObject(M, 4)

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
  ```