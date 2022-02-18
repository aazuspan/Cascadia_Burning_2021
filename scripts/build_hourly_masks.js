/*
This GEE script generates hourly and cumulative burn masks from GOES-16 and 17 
hotspot detections, which can be used to calculate fire growth. The masks
are exported as images with time stored in the band-dimension.
*/

// See https://github.com/aazuspan/geeTools
var fire = require("users/aazuspan/geeTools:fire.js");


var start = "2020-09-04";
var end = "2020-09-14";
var timeDelta = 1;

var extent = ee.Geometry.Polygon([
  [-127.95869082399632,38.16635058488577],
  [-116.34215718032829,38.16635058488577],
  [-116.34215718032829,49.62802378354546],
  [-127.95869082399632,49.62802378354546],
  [-127.95869082399632,38.16635058488577],
])
var scale = 2500;


// Get hourly fire masks
var burned = fire.periodicFireBoundaries(start, end, extent, {timeDelta: timeDelta, smooth: false, cumulative: false})
var burnedCumulative = fire.periodicFireBoundaries(start, end, extent, {timeDelta: timeDelta, smooth: false, cumulative: true})

// How many times was a given pixel detected as burning during this period?
var burnCount = burned.reduce(ee.Reducer.sum());
Map.addLayer(burnCount)


// Build an image where each band is an hourly GOES fire mask
var burnMasks = burned.map(function(mask) {
    // var imgStart = ee.Date(mask.get("start_date"));
    var imgEnd = ee.Date(mask.get("end_date"));
    var dateString = imgEnd.format("yyyy_MM_dd_HH");
    
    return mask.rename(dateString);
}).toBands()

// Build an image where each band is an accumulated GOES fire mask
var burnMasksCumulative = burned.map(function(mask) {
    // var imgStart = ee.Date(mask.get("start_date"));
    var imgEnd = ee.Date(mask.get("end_date"));
    var dateString = imgEnd.format("yyyy_MM_dd_HH");
    
    return mask.rename(dateString);
}).toBands()
  


Export.image.toDrive({
  image: burnMasks,
  description: "burn_masks",
  region: extent,
  scale: scale,
  crs: "EPSG:5070",
  maxPixels: 1e13
})

Export.image.toDrive({
  image: burnMasksCumulative,
  description: "cumulative_burn_masks",
  region: extent,
  scale: scale,
  crs: "EPSG:5070",
  maxPixels: 1e13
})
