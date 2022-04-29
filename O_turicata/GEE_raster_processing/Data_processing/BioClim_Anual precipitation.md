### WorldClim BIO Variables V1

Link to product: https://developers.google.com/earth-engine/datasets/catalog/WORLDCLIM_V1_BIO 

```r
// Add shapefile of calibration region

Map.addLayer(M,{},'M');

var precip = ee.Image("WORLDCLIM/V1/BIO")
.select("bio12")
.clip(M)

print('Precip', precip.projection().nominalScale())

// Create palette

var visParams = {
  min: 33.66,
  max: 2053.46,
  palette: ['blue', 'purple', 'cyan', 'green', 'yellow', 'red'],
};


// Create region
var ExportArea = ee.Geometry.Rectangle([-83,-56,-33,10]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

var bandNames = precip.bandNames();
print("Band names: ", bandNames);

// Get scale in meters
var scale = precip.select("bio12").projection().nominalScale();
print("Band scale: ", scale);

Map.addLayer(precip, visParams, 'Annual Precipitation');

Export.image.toDrive({
  image: precip,
  description: "Bioclim_Annual_Precipitation",
  scale: 1000,  
  region: ExportArea,  
  fileFormat: "GeoTIFF",
  folder: "WildBoar",
  crs: 'EPSG:4326',
  maxPixels: 1e13,});
```
