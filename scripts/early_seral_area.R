# This just loads historical fire perimeters that were divided by state and ecoregion in Arcmap and calculates some 
# tabular area stats


library(dplyr)


date <- Sys.Date()

data_dir <- file.path("..", "data")

# USFS R6 perimeters pre-1900, identitied with ecoregions and states
henderson_path <- file.path(data_dir, "historical_fire", "henderson_perims_ecoregion_state.shp")
# Gannett, Elliott, and Harrington perimeters identitied with ecoregions and states
hist_path <- file.path(data_dir, "historical_fire", "historical_perims_ecoregion_state.shp")
ecoregion_path <- file.path(data_dir, "ecoregions", "ecoregions_20200929_state.shp")

target_crs <- "EPSG:26910"

henderson <- henderson_path %>%
  sf::st_read() %>%
  sf::st_transform(target_crs) %>%
  sf::st_make_valid()

perims <- hist_path %>%
  sf::st_read() %>%
  sf::st_transform(target_crs) %>%
  sf::st_make_valid()

ecoregions <- ecoregion_path %>%
  sf::st_read() %>%
  sf::st_transform(target_crs) %>%
  sf::st_make_valid()


perims_df <- data.frame()
for(state in c("OR", "WA")) {
  for(region in c("Olympic Peninsula", "Western Cascades")) {
    subregion <- ecoregions %>%
      subset(NA_L3NAME == region & STUSPS == state)
    
    
    for(source in c("Henry Gannett", "F.A. Elliott", "Constance A. Harrington")) {
      if (source == "Henry Gannett")
        year <- 1902
      else if (source == "F.A. Elliott")
        year <- 1914
      else 
        year <- 1936
      
      # The Olympic Peninsula should be split at the state line into the Coast Range, but it isn't
      region_label <- if(state == "OR" & region == "Olympic Peninsula") "Coast Range" else region
      subregion_area <- units::set_units(sum(sf::st_area(subregion)), "hectares")
      
      perim_subregion <- perims %>%
        subset(NA_L3NAME == region & STUSPS == state & SOURCEAUTH == source)
      
      perim_area <- units::set_units(sum(sf::st_area(perim_subregion)), "hectares")
      percent_of_region <- perim_area / subregion_area
      
      row <- data.frame(source_author=source, year=year, state=state, ecoregion=region_label, hectares=perim_area, percent_region=percent_of_region)
      
      perims_df <- rbind(perims_df, row)
    }
  }
}

write.csv(perims_df, paste0("early_seral_area_", date, ".csv"), row.names=FALSE)


century_range <- seq(1000, 1800, by=100)
henderson_df <- data.frame()
for(region in c("Olympic Peninsula", "Western Cascades")) {
  subregion <- ecoregions %>%
    subset(NA_L3NAME == region & STUSPS == "WA")
  subregion_area <- units::set_units(sum(sf::st_area(subregion)), "hectares")
  
  for(century in century_range) {
    perim_subregion <- henderson %>%
      subset(NA_L3NAME == region & STUSPS == state & FIREYEAR >= century & FIREYEAR < century + 100)
    
    perim_area <- units::set_units(sum(sf::st_area(perim_subregion)), "hectares")
    percent_of_region <- perim_area / subregion_area
    
    row <- data.frame(source_author="Henderson", century=century, state=state, ecoregion=region, hectares=perim_area, percent_region=percent_of_region)
    
    henderson_df <- rbind(henderson_df, row)
  }
}
write.csv(henderson_df, paste0("henderson_area_", date, ".csv"), row.names=FALSE)

