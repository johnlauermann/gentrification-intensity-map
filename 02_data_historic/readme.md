# Mapping gentrification patterns on 2010 tract boundaries
Gentrification indicators from 1970 to 2020, adjusted to 2010 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from from [National Historical GIS](https://www.nhgis.org/) using the [IPUMS API](https://developer.ipums.org/docs/v2/get-started/). Crosswalks are based on methods from both [NHGIS Geographic Crosswalks](https://www.nhgis.org/geographic-crosswalks) and the [Longitudinal Tract Data Base](https://s4.ad.brown.edu/projects/diversity/researcher/bridging.htm). 

## How to use
Code was written to be deployed in the following order:

_Query data from API & geographically crosswalk to modern boundaries_
- [data_1970to2010tracts.R](data_1970to2010tracts.R), which generates `tractdata_1970_2010tr.csv`
- [data_1980to2010tracts.R](data_1980to2010tracts.R), which generates `tractdata_1980_2010tr.csv`
- [data_1990to2010tracts.R](data_1990to2010tracts.R), which generates `tractdata_1990_2010tr.csv`
- [data_2000to2010tracts.R](data_2000to2010tracts.R), which generates `tractdata_2000_2010tr.csv`
- [data_2010to2010tracts.R](data_2010to2010tracts.R), which generates `tractdata_2010_2010tr.csv`
- [data_2020to2010tracts.R](data_2020to2010tracts.R), which generates `tractdata_2020_2010tr.csv`

_Combine the CSVs above into a longitudinal series and calculate rates of change_
- [data_combineallyears_2010tr.R](data_combineallyears_2010tr.R), which generates `metrotracts_data_2010tr.csv` 

_Calculate gentrification intensity scores using he longitudinal series_
- [gentrificationscores_2010tr.R](gentrificationscores_2010tr.R), which generates `metrotracts_gentscores_2010tr.csv`.

This final `csv` will contain gentrification intensity scores for ~46,500 census tracts in ~860 core-based statistical areas. It can be joined to boundary data from the [`03_spatial`](/03_spatial/) folder for mapping the data. 

