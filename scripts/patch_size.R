# This script handles generating tabular data of high severity patch size for each year of fire severity data in 
# the westside ecoregions. Results are saved to CSV because the process takes a long time and is prone to crashing.


library(dplyr)

data_dir <- file.path("..", "data")
aoi_path <- file.path(data_dir, "study_area.gpkg")

target_crs <- "EPSG:5070"

aoi <- aoi_path %>%
  sf::st_read() %>%
  sf::st_transform(target_crs) %>%
  sf::st_make_valid()

# Generate a raster mask of the AOI. Takes some time, but makes masking each severity raster MUCH quicker.
aoi_mask <- raster::raster(file.path(data_dir, "severity", "severity_2016.tif"))
aoi_mask[] <- 1
aoi_mask <- raster::mask(aoi_mask, aoi)


# Create a binary mask where high severity = 1. This is a lot faster than directly replacing values by indexing
high_severity_mask <- function(r) {
  # 5 and 6 are high severity
  rcl <- matrix(c(
    -Inf, 5, NA,
    5, Inf, 1
  ), ncol=3, byrow=TRUE
  )
  
  high_sev <- raster::reclassify(r, rcl, right=FALSE)
  
  return(high_sev)
}


yr_range <- 1985:2020

# Return a dataframe of patch area metrics for a given year of burn severity data
get_high_severity_patch_area <- function(yr) {
  sev_path <- file.path(data_dir, "severity", paste0("severity_", yr, ".tif"))
  sev <- raster::raster(sev_path)
  
  # Severity masked to the AOI. Overwrite the data each time to avoid storing it all in RAM
  sev <- sev * aoi_mask
  
  # High severity only
  sev <- high_severity_mask(sev)
  
  # Count total number of high severity pixels. Much faster than getting length of values
  freq <- rasterDT::freqDT(sev, useNA="no")
  n_pixels <- freq$freq
  
  # If there are no pixels, it will return integer(0)
  if(length(n_pixels) == 0) {
    n_pixels <- 0
    yr_patch <- data.frame(id=0, metric="area", value=0)
  }
  else {
    yr_patch <- landscapemetrics::lsm_p_area(sev, directions=8)
  }
  
  yr_patch$yr <- yr
  yr_patch$n_pixels <- n_pixels
  
  yr_patch <- dplyr::select(yr_patch, c("id", "metric", "value", "yr", "n_pixels"))

  write.csv(yr_patch, file.path(data_dir, "patch_size", paste0("patch_area_", yr, ".csv")), row.names=FALSE)
  
  return(yr_patch)
}


cores <- 2
cl <- parallel::makeCluster(cores)
parallel::clusterExport(cl, c("yr_range", "data_dir", "high_severity_mask", "get_high_severity_patch_area", "aoi_mask", "proj_dir"))
patches <- parallel::parLapply(cl, yr_range, get_high_severity_patch_area)
parallel::stopCluster(cl)
