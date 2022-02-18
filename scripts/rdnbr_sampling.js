/*
This script generates tabular data for modeling of fire severity drivers in 2020.
Specifically, it generates random points stratified by structural condition and extracts
RdNBR, weather, topographic, and fire intensity data at each point.
*/


var struccond = ee.Image("users/aazuspan/struccond_2017"),
    nifc2020 = ee.FeatureCollection("users/aazuspan/fires/NIFC_2020"),
    rtma = ee.ImageCollection("NOAA/NWS/RTMA"),
    gridmet = ee.ImageCollection("IDAHO_EPSCOR/GRIDMET"),
    chili = ee.Image("CSP/ERGo/1_0/US/CHILI"),
    mtpi = ee.Image("CSP/ERGo/1_0/US/mTPI"),
    ned = ee.Image("USGS/NED"),
    goes16 = ee.ImageCollection("NOAA/GOES/16/FDCC"),
    evh = ee.ImageCollection("LANDFIRE/Vegetation/EVH/v1_4_0");



var fireList = [
    "Beachie Creek",
    "Riverside",
    "Holiday Farm",
    "Archie Creek",
    "BIG HOLLOW",
    "Lionshead"
  ];

var fires = nifc2020.filter(ee.Filter.inList("IncidentNa", fireList));

var extent = fires.geometry().bounds();

// load the LandTrendr.js module
var ltgee = require('users/emaprlab/public:Modules/LandTrendr.js');

var bandList = ['NBR'];


////////////////////////////////////////////////////////////////////////////
// GENERATING 2020 SEVERITY MAP (early estimate from late 2020 data using LTGEE)
////////////////////////////////////////////////////////////////////////////

var year = 2020;

// Set medoid composite date window
var startDay = '10-01';
var endDay = '11-01';

// Build medoid composite for every year 2019-2021.
var annualSRcollection2020 = ltgee.buildSRcollection(year - 1, year, startDay, endDay, extent);
// Return an image collection of NBR for each year.
var indexCollection2020 = ltgee.transformSRcollection(annualSRcollection2020, bandList);

// Create date strings for filtering LT composites
var prefireStart = (year - 1).toString().concat("-01-01");
var prefireEnd = (year - 1).toString().concat("-12-31");
var postfireStart = (year).toString().concat("-01-01");
var postfireEnd = (year).toString().concat("-12-31");

// Grab the prefire and postfire NBR medoids
var prefire = ee.Image(indexCollection2020.filterDate(prefireStart, prefireEnd).first());
var postfire = ee.Image(indexCollection2020.filterDate(postfireStart, postfireEnd).first());

// Calculate delta normalized burn ratio between prefire and postfire
var dnbr = prefire.subtract(postfire);
// Calculate relativized delta normalized burn ratio following Miller & Thode 2007
var rdnbrEarly = dnbr.divide(prefire.divide(1000).abs().pow(0.5)).rename("RdNBR_early");


//////////////////////////////////////////////////////////////////////////////
// GENERATING 2020 SEVERITY MAP (updated early estimate from mid 2021, LandTrendr)
//////////////////////////////////////////////////////////////////////////////

// Set medoid composite date window
var startDay = '04-01';
var endDay = '07-18';

// Build medoid composite for every year 2019-2021.
var annualSRcollection2020 = ltgee.buildSRcollection(2019, 2021, startDay, endDay, extent);
// Return an image collection of NBR for each year.
var indexCollection2020 = ltgee.transformSRcollection(annualSRcollection2020, bandList);

// Create date strings for filtering LT composites
var prefireStart = (2019).toString().concat("-01-01");
var prefireEnd = (2019).toString().concat("-12-31");
var postfireStart = (2021).toString().concat("-01-01");
var postfireEnd = (2021).toString().concat("-12-31");

// Grab the prefire and postfire NBR medoids
var prefire = ee.Image(indexCollection2020.filterDate(prefireStart, prefireEnd).first());
var postfire = ee.Image(indexCollection2020.filterDate(postfireStart, postfireEnd).first());

// Calculate delta normalized burn ratio between prefire and postfire
var dnbr = prefire.subtract(postfire).rename("dNBR");
// Calculate relativized delta normalized burn ratio following Miller & Thode 2007
var rdnbr = dnbr.divide(prefire.divide(1000).abs().pow(0.5)).rename("RdNBR_update");

var mask = ee.Image(1).clip(fires);

// Mask nonforest
struccond = struccond.updateMask(struccond.gt(0)).rename("struccond").updateMask(mask);

var samples = struccond.stratifiedSample({
  numPoints: 500,
  geometries: true
});


var maxGust = rtma.filterDate("2020-09-07", "2020-09-14").select("GUST").max().rename("max_gust");
var grid = gridmet.filterDate("2020-09-07", "2020-09-14").select(["erc", "bi", "fm100", "fm1000"]).median();
var slope = ee.Terrain.slope(ned);
var aspect = ee.Terrain.aspect(ned);
var max_frp = goes16.filterDate("2020-09-07", "2020-09-14").select("Power").max().rename("max_FRP");
var sum_frp = goes16.filterDate("2020-09-07", "2020-09-14").select("Power").sum().rename("sum_FRP");

evh = evh.filterBounds(extent).first();
// Mask all non-tree and convert to meters (https://landfire.gov/DataDictionary/evh.pdf)
evh = evh.mask(evh.gt(99).and(evh.lt(200))).subtract(100).unmask(0);

var features = rdnbr
  .addBands(rdnbrEarly)
  .addBands(maxGust)
  .addBands(grid)
  .addBands(chili.rename("CHILI"))
  .addBands(mtpi.rename("mTPI"))
  .addBands(slope)
  .addBands(aspect)
  .addBands(max_frp)
  .addBands(sum_frp)
  .addBands(evh);

var data = features.sampleRegions({
  collection: samples,
  scale: 30,
  tileScale: 4,
  geometries: true
});

Export.table.toDrive({
  collection: data,
  description: "rdnbr_samples_20210811_v2",
  fileFormat: "SHP"
});
