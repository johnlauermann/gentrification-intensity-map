# Mapping gentrification patterns on 2020 tract boundaries
Gentrification-related data from 1990 to 2020, adjusted to 2020 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from National Historical GIS using the IPUMS API. Crosswalks are based on the NHGIS Geographic Crosswalk methodology. 

## How to use
Code was written to be deployed in the following order:

_Query data from API & geographically crosswalk to modern boundaries_
- [data_1990to2020tracts.R](data_1990to2020tracts.R), which generates `tractdata_1990_2020tr.csv'
- [data_2000to2020tracts.R](data_2000to2020tracts.R), which generates `tractdata_2000_2020tr.csv'
- [data_2010to2020tracts.R](data_2010to2020tracts.R), which generates `tractdata_2010_2020tr.csv'
- [data_2020to2020tracts.R](data_2020to2020tracts.R), which generates `tractdata_2020_2020tr.csv'

_Combine the CSVs above into a longitudinal series and calculate rates of change_
- [data_combineallyears_2020tr.R](data_combineallyears_2020tr.R), which generates 'metrotracts_data_2020tr.csv` 

_Calculate gentrification intensity scores using he longitudinal series_
- [gentrificationscores_2020tr.R](gentrificationscores_2020tr.R), which generates 'metrotracts_gentscores_2020tr.csv'
