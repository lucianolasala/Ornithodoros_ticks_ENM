### SRTM Digital Elevation Data Version 4

```r
// Display DEM model
var DEM = ee.Image('CGIAR/SRTM90_V4')
.select('elevation')
.clip(G)

print('DEM', DEM.projection().nominalScale())
print('DEM', DEM)

// Get information about the DEM projection.
var DEMProjection = DEM.projection();
print('DEM projection:', DEMProjection);

Map.addLayer(G, {}, 'G')
Map.addLayer(DEM, {}, 'DEM')

// Create region
var ExportArea = ee.Geometry.Rectangle([-74,-55,-53,-21]);
Map.addLayer(ExportArea, {color: 'FF0000'}, 'poly');

Export.image.toDrive({
image: DEM, 
description: 'DEM_G',
folder: 'Ticks_ENM',
crs: 'EPSG:4326', 
maxPixels: 1e13, 
region: ExportArea,});
```
