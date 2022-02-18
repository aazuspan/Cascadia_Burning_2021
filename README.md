# Cascadia Burning

This repository contains data and code for [Cascadia Burning: The historic, but not historically unprecedented, 2020 wildfires in the Pacific Northwest, USA]() by Reilly et. al., 2021. Most of the data used in analysis is included here, with the exception of a) unmodified data from external sources that is linked and b) large datasets that can be re-generated from included scripts. 

Scripts and datasets are described below, organized [by filename](#by-file) and [by in-text reference](#by-reference).

## By File

### Scripts
- [build_cramer_count.js](scripts/build_cramer_count.js): Generates count of hours exceeding the Cramer major east wind threshold [[4]](#4).
- [build_hourly_masks.js](scripts/build_hourly_masks.js): Generates cumulative hourly hotspot detection grids from [GOES-16/17 ABI data](https://developers.google.com/earth-engine/datasets/catalog/NOAA_GOES_16_FDCC?hl=en) [[2]](#2).
- [daily_gridmet_to_netcdf.ipynb](scripts/daily_gridmet_to_netcdf.ipynb): Parses the annual grids generated by [download_daily_gridmet.ipynb](scripts/download_daily_gridmet.ipynb) into a single NetCDF file.
- [download_daily_gridmet.ipynb](scripts/download_daily_gridmet.ipynb): Downloads daily weather grids from [gridMET](https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_GRIDMET) [[3]](#3) for use in identifying historical dry east wind statistics.
- [early_seral_area.R](scripts/early_seral_area.R): Calculates historical burned areas.
- [fire_size_and_severity.ipynb](scripts/fire_size_and_severity.ipynb): Calculates percent high severity fire for all historical fires and plots against fire size.
- [fire_size_distribution.ipynb](scripts/fire_size_distribution.ipynb): Generates fire size distributions from [MTBS](https://mtbs.gov/direct-download) [[6]](#6) and [NIFC](https://data-nifc.opendata.arcgis.com/) [[7]](#7) fire perimeters.
- [fire_stats_data.ipynb](scripts/fire_stats_data.ipynb): Calculates area burned, stratified by year, structural class, and ecoregion.
- [fire_stats_supp.ipynb](scripts/fire_stats_supp.ipynb): Takes tabular data from [fire_stats_data.ipynb](scripts/fire_stats_data.ipynb) and calculates miscellaneous statistics used throughout the paper.
- [fire_stats_table.ipynb](scripts/fire_stats_table.ipynb): Takes tabular data from [fire_stats_data.ipynb](scripts/fire_stats_data.ipynb) and summarizes into a table.
- [get_max_wdir.js](scripts/get_max_wdir.js): Generates a grid of wind gust and direction from [RTMA](https://developers.google.com/earth-engine/datasets/catalog/NOAA_NWS_RTMA) [[5]](#5) at the time of the maximum regional gust velocity between September 4 and 13.
- [hourly_area.ipynb](scripts/hourly_area.ipynb): Calculates hourly fire sizes from masks generated by [build_hourly_masks.js](scripts/build_hourly_masks.js).
- [identify_gridmet_events.ipynb](scripts/identify_gridmet_events.ipynb): Identifies pixel-wise dry east wind events from daily data generated by [daily_gridmet_to_netcdf.ipynb](scripts/daily_gridmet_to_netcdf.ipynb) and calculate historical event statistics.
- [patch_size.R](scripts/patch_size.R): Calculates high severity patch sizes from historical fire data.
- [rdnbr_analysis.R](scripts/rdnbr_analysis.R): Performs random forest analysis of 2020 burn severity data`.
- [rdnbr_sampling.js](scripts/rdnbr_sampling.js): Generates random samples for burn severity modeling.
- [severity.js](scripts/severity.js): Generates annual Landsat burn severity grids.

### Data
- [cumulative_hourly_masks.tif](data/cumulative_hourly_masks.tif): Cumulative hourly hotspot detection grids used.
- [east_wind.zip](data/east_wind.zip): Dry east wind frequency grid.
- [ecoregions/](data/ecoregions/): Ecoregions adapted from [EPA Level III Ecoregions](https://www.epa.gov/eco-research/).
- [fire_stats_data_20210802.csv](data/fire_stats_data_20210802.csv): Area burned by year, ecoregion, severity class, and forest structure.
- [LSR/](data/LSR/): Late Successional Reserve boundaries adapted from [here](https://www.fs.fed.us/r6/reo/library/maps.php).
- [maj_EW_count.tif](data/maj_EW_count.tif): Count of hours exceeding the Cramer major east wind threshold [[4]](#4).
- [max_wdir.tif](data/max_wdir.tif): A grid of RTMA [[5]](#5) wind gust and direction at the time of the maximum regional gust velocity between September 4 and 13.
- [NIFC/](data/NIFC/): Fire boundary polygons for 2020 retrieved from [NIFC](https://data-nifc.opendata.arcgis.com/) [[7]](#7).
- [NWFP/](data/NWFP/): Northwest forest plan boundary available [here](https://www.fs.fed.us/r6/reo/library/maps.php).
- [patch_size/](data/patch_size/): Annual fire patch sizes calculated by [patch_size.R](scripts/patch_size.R).
- [RAWS/](data/RAWS/): RAWS weather data for the 2020 Labor Day fires and the 2017 Eagle Creek Fire.
- [rdnbr_samples_20210811_v2.csv](data/rdnbr_samples_20210811_v2.csv): Randomly sampled data used for burn severity modeling.
- [study_area.gpkg](data/study_area.gpkg): The Coast Range, Olympic Peninsula, and Western Cascades ecoregions adapted from [EPA Level III Ecoregions](https://www.epa.gov/eco-research/level-iii-and-iv-ecoregions-continental-united-states).
- [summary_may-oct_gridMET.tif](data/summary_may-oct_gridMET.tif): Magnitude and duration of dry east wind events.

## By Reference

### Figure 1

- Data
    - [NIFC fire perimeters](data/NIFC/)

### Figure 2

- Scripts
    - [build_hourly_masks.js](scripts/build_hourly_masks.js)
    - [hourly_area.ipynb](scripts/hourly_area.ipynb)
- Data
    - [cumulative_hourly_masks.tif](data/cumulative_hourly_masks.tif)

### Figure 3

- Data
    - [NIFC fire perimeters](data/NIFC/)

### Figure 4

- Scripts
    - [download_daily_gridmet.ipynb](scripts/download_daily_gridmet.ipynb)
    - [daily_gridmet_to_netcdf.ipynb](scripts/daily_gridmet_to_netcdf.ipynb)
    - [identify_gridmet_events.ipynb](scripts/identify_gridmet_events.ipynb)
- Data
    - [East wind frequency](data/east_wind.zip)
    - [East wind duration and magnitude](data/summary_may-oct_gridMET.tif)

### Figure 5

- Data
    - [NIFC fire perimeters](data/NIFC/)
    - [gridMET ERC](https://developers.google.com/earth-engine/datasets/catalog/IDAHO_EPSCOR_GRIDMET)
    - [gridMET EDDI](https://developers.google.com/earth-engine/datasets/catalog/GRIDMET_DROUGHT)

### Figure 6

- Data
    - [Raws data](data/RAWS/)

### Figure 7

- Scripts
    - [build_cramer_count.js](scripts/build_cramer_count.js)
    - [get_max_wdir.js](scripts/get_max_wdir.js)
- Data
    - [Cumulative east wind hours](data/maj_EW_count.tif)
    - [2020 wind direction](data/max_wdir.tif)

### Figure 8

- Scripts
    - [severity.js](scripts/severity.js)
    - [fire_size_distribution.ipynb](scripts/fire_size_distribution.ipynb)
    - [fire_size_and_severity.ipynb](scripts/fire_size_and_severity.ipynb)
    - [patch_size.R](scripts/patch_size.R)
- Data
    - [Patch sizes](data/patch_size/)
    - [NIFC fire perimeters](data/NIFC/)
    - [MTBS fire perimeters](https://www.mtbs.gov/direct-download)

### Figure 9

- Scripts
    - [rdnbr_sampling.js](scripts/rdnbr_sampling.js)
    - [rdnbr_analysis.R](scripts/rdnbr_analysis.R)
- Data
    - [Sample plots](data/rdnbr_samples_20210811_v2.csv)

### Appendix 2

- Scripts
    - [early_seral_area.R](scripts/early_seral_area.R)
- Data
    - [Ecoregions](data/ecoregions/)

### Appendix 3 and 4

- Data
    - [RAWS data](data/RAWS/)

### Appendix 5
 
- Scripts
    - [severity.js](scripts/severity.js)

### Appendix 6

- Scripts
    - [rdnbr_analysis.R](scripts/rdnbr_analysis.R)

### Appendix 7

- Scripts
    - [severity.js](scripts/severity.js)
    - [fire_stats_data.ipynb](scripts/fire_stats_data.ipynb)
    - [fire_stats_table.ipynb](scripts/fire_stats_table.ipynb)
    - [fire_stats_supp.ipynb](scripts/fire_stats_supp.ipynb)

- Data
    - [LSR](data/LSR/)
    - [Fire stats](data/fire_stats_data_20210802.csv)
    - [GNN OGSI data](https://lemma.forestry.oregonstate.edu/data/structure-maps)

### Appendix 8

- Scripts
    - [early_seral_area.R](scripts/early_seral_area.R)
- Data
    - [Ecoregions](data/ecoregions/)

# References

<a id="1">[1]</a> Gorelick, N., Hancher, M., Dixon, M., Ilyushchenko, S., Thau, D., & Moore, R. (2017). Google Earth Engine: Planetary-scale geospatial analysis for everyone. Remote Sensing of Environment, 202, 18–27. https://doi.org/10.1016/j.rse.2017.06.031    
<a id="2">[2]</a> Schmidt, C. (2020). Monitoring Fires with the GOES-R Series. In The GOES-R Series (pp. 145–163). Elsevier. https://doi.org/10.1016/B978-0-12-814327-8.00013-5    
<a id="3">[3]</a> Abatzoglou, J.T. 2013. Development of gridded surface meteorological data for ecological applications and modelling. International Journal of Climatology 33: 121–131.   
<a id="4">[4]</a> Cramer, O.P. 1957. Frequency of dry east winds over northwest Oregon and southwest Washington. USDA Forest Service PNW Old Series Research Paper No. 24: 1-19  
<a id="5">[5]</a> De Pondeca, M. S. F. V., Manikin, G. S., DiMego, G., Benjamin, S. G., Parrish, D. F., Purser, R. J., Wu, W.-S., Horel, J. D., Myrick, D. T., Lin, Y., Aune, R. M., Keyser, D., Colman, B., Mann, G., & Vavra, J. (2011). The real-time mesoscale analysis at NOAA’s National Centers for Environmental Prediction: Current status and development. Weather and Forecasting, 26(5), 593–612. https://doi.org/10.1175/WAF-D-10-05037.1   
<a id="6">[6]</a> Eidenshink, J., Schwind, B., Brewer, K., Zhu, Z.-L., Quayle, B., Howard, S. 2007. A project for monitoring trends in burn severity. Fire Ecology, 3(1), 3–21.   
<a id="7">[7]</a> National Interagency Fire Center. 2021. Wildland Fire Perimeters Full History. Available at https://data-nifc.opendata.arcgis.com/datasets/wfigs-wildland-fire-perimeters-full-history.  
