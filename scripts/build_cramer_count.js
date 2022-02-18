/*
This GEE script calculates the pixel-wise count of cumulative hours spent above the Cramer 1957
major east wind event threshold of > 4 m/s wind speed, < 36% RH, and 15-165 deg. wind direction.
*/

// See https://github.com/aazuspan/geeTools
var fire = require("users/aazuspan/geeTools:fire.js");
var climate = require("users/aazuspan/geeTools:climate.js");

var rtma = ee.ImageCollection("NOAA/NWS/RTMA");

var extent = ee.Geometry.Polygon([
  [-127.95869082399632,38.16635058488577],
  [-116.34215718032829,38.16635058488577],
  [-116.34215718032829,49.62802378354546],
  [-127.95869082399632,49.62802378354546],
  [-127.95869082399632,38.16635058488577],
])


var WIND_THRESHOLD = 4;
var RH_THRESHOLD = 36;
// Threshold for wind direction, in degrees
var WDIR_LOW_THRESHOLD = 15;
var WDIR_HIGH_THRESHOLD = 165;

// Hourly grids
var start = ee.String("2020-09-04T00");
// Include through the 13th, but not the 14th
var end = ee.String("2020-09-13T23");
var timeDelta = 1;


// Convert time delta in hours to milliseconds
var msDelta = timeDelta * 3.6e6;

// Millisecond epoch time of each day in the time series
var periodList = ee.List.sequence(
  ee.Date(start).millis(),
  ee.Date(end).millis(),
  msDelta
);

// Calculate hourly median weather
var weather = ee.ImageCollection(periodList.map(function(time) {
  var imgStart = ee.Date(time);
  var imgEnd = imgStart.advance(timeDelta, "hour");
  
  var w = rtma
    .filterDate(imgStart, imgEnd)
    .median()
    .select(["GUST", "PRES", "TMP", "DPT", "UGRD", "VGRD", "SPFH", "WDIR", "WIND"]);
  
  // Calculate relative humidity and add as a band
  var q = w.select("SPFH");
  var p = w.select("PRES");
  var t = w.select("TMP");
  var RH = climate.relativeHumidity(q, p, t);
  w = w.addBands(RH);
  
  var dateString = imgStart.format("yyyy_MM_dd_HH");
  w = w.set("start_date", imgStart, "end_date", imgEnd, "system:id", ee.String("weather_").cat(dateString));
    
  return w;
}))


// Create a collection of binary masks showing hourly pixels above the Cramer
// thresholds based on gust speed
var gustThreshold = weather.map(function(img) {
  var gust = img.select("GUST");
  var rh = img.select("RH");
  var wdir = img.select("WDIR");
  
  var windMask = ee.Image(0).where(gust.gt(WIND_THRESHOLD), 1);
  var rhMask = ee.Image(0).where(rh.lt(RH_THRESHOLD), 1);
  var wdirMask = ee.Image(0).where(wdir.gt(WDIR_LOW_THRESHOLD).and(wdir.lt(WDIR_HIGH_THRESHOLD)), 1);
  var mask = windMask.multiply(rhMask).multiply(wdirMask);
  
  return mask;
})

// Calculate the total number of hours during the time period spent above the
// Cramer threshold
var countGust = gustThreshold.reduce(ee.Reducer.sum()).uint8();

Map.addLayer(countGust, {min: 0, max: 60, palette: ['#2c7bb6', '#ffffbf', '#d7191c']}, "gust");

Export.image.toDrive({
  image: countGust,
  description: "maj_EW_count",
  scale: 2500,
  region: extent,
  crs: "EPSG:5070"
});
