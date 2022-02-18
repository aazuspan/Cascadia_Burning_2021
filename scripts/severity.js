// load the LandTrendr.js module
var ltgee = require('users/emaprlab/public:Modules/LandTrendr.js');

// Set medoid composite date window
var startDay = '04-01';
var endDay = '07-18';
var startYear = 1984;
var endYear = 2021;

var bandList = ['NBR'];

var mtbs = ee.FeatureCollection("users/aazuspan/fires/mtbs_1984_2018");
var nifc = ee.FeatureCollection("users/aazuspan/fires/NIFC_2020");

var extent = ee.Geometry.Polygon([
    [-127.95869082399632,38.16635058488577],
    [-116.34215718032829,38.16635058488577],
    [-116.34215718032829,49.62802378354546],
    [-127.95869082399632,49.62802378354546],
    [-127.95869082399632,38.16635058488577],
  ]);


// Build medoid composite for every year 1984-2020.
var annualSRcollection = ltgee.buildSRcollection(startYear, endYear, startDay, endDay, extent);
// Return an image collection of NBR for each year.
var indexCollection = ltgee.transformSRcollection(annualSRcollection, bandList);


//////////////////////////////////////////////////////////////////////////////
// GENERATING 1985-2020 SEVERITY MAPS (LandTrendr)
//////////////////////////////////////////////////////////////////////////////

for (var yr = 1985; yr < 2021; yr++) {
  // Create date strings for filtering LT composites
  var prefireStart = (yr - 1).toString().concat("-01-01");
  var prefireEnd = (yr - 1).toString().concat("-12-31");
  var postfireStart = (yr + 1).toString().concat("-01-01");
  var postfireEnd = (yr + 1).toString().concat("-12-31");
  
  // Grab the prefire and postfire NBR medoids
  var prefire = ee.Image(indexCollection.filterDate(prefireStart, prefireEnd).first());
  var postfire = ee.Image(indexCollection.filterDate(postfireStart, postfireEnd).first());
  
  // Calculate delta normalized burn ratio between prefire and postfire
  var dnbr = prefire.subtract(postfire);
  // Calculate relativized delta normalized burn ratio following Miller & Thode 2007
  var rdnbr = dnbr.divide(prefire.divide(1000).abs().pow(0.5));
  // Remap RdNBR into fire severity classes using thresholds from Matt Reilly. 0 = nodata
  var severity = ee.Image(0)
            .where(rdnbr.lte(166.4848), 1) // very low or unchanged
            .where(rdnbr.gt(166.4848).and(rdnbr.lte(235.195)), 2) // low
            .where(rdnbr.gt(235.195).and(rdnbr.lte(406.48)), 3) // low / moderate
            .where(rdnbr.gt(406.48).and(rdnbr.lte(648.725)), 4) // moderate
            .where(rdnbr.gt(648.725).and(rdnbr.lte(828.1328)), 5) // high
            .where(rdnbr.gt(828.1328), 6); // very high
  
  if (yr <= 2018) {
    // MTBS only covers 1984 to 2018
    var yearPerims = mtbs.filterMetadata("Year", "equals", yr);
  }
  else if (yr == 2019) {
    // NIFC has 2019 perimeters
    yearPerims = nifc.filterMetadata("fireyear", "equals", yr);
  }
  else {
    yearPerims = nifc2020;
  }
  
  // Clip to year perimeters. GEE will set these values to 0 in the output.
  severity = severity.clip(yearPerims);

  
  Export.image.toDrive({
    image: severity.unmask(0).uint8(),
    description: "severity_" + yr,
    region: extent,
    crs: "EPSG:5070",
    scale: 30,
    maxPixels: 1e12
  });
}
