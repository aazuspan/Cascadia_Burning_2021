/*
This GEE script gets the wind gust and direction from RTMA during the maximum regional gust period.
*/


var extent = ee.Geometry.Polygon([
    [-127.95869082399632,38.16635058488577],
    [-116.34215718032829,38.16635058488577],
    [-116.34215718032829,49.62802378354546],
    [-127.95869082399632,49.62802378354546],
    [-127.95869082399632,38.16635058488577],
  ])

var scale = 2500;

var startDate = "2020-09-04";
var endDate = "2020-09-13T23";

var rtmaWindow = rtma
  .filterDate(startDate, endDate)

var gusts = rtmaWindow.select("GUST")
var maxGusts = ui.Chart.image.series({
  imageCollection: gusts,
  region: extent,
  reducer: ee.Reducer.max(),
  scale: scale,
})
print(maxGusts)


// Identified the time with the maximum gusts in the Beachie perimeter
// using the chart above.
var maxGustTime = ee.Date("2020-09-08T03")

// Get the gust and wind direction during the maximum gust period
var maxDir = rtmaWindow.filterDate(maxGustTime, maxGustTime.advance(1, "second")).first()
  .select(["GUST", "WDIR"])


Export.image.toDrive({
  image: maxDir,
  description: "max_wdir",
  scale: scale,
  crs: "EPSG:5070",
  region: extent
})

