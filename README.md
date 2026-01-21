# National Gentrification Intensity Map
#### Team: [John Lauermann](https://www.pratt.edu/people/john-lauermann/), [Yuanhao Wu](https://www.linkedin.com/in/yuanhao-wu-80603723a/), [Alice Viggiani](https://www.aliceviggiani.com/), [Anna Feldman](https://www.linkedin.com/in/annaelsafeldman/), [Ziqi Wang](https://www.linkedin.com/in/ziqi-wang-0623/), [Nathan Smash](https://www.linkedin.com/in/nathan-smash-b6b93a24a/)
This repository contains code and data related to a national longitudinal tract database on gentrification patterns in American cities. This is a spatial data science project that seeks to map varying degrees of gentrification intensity across most US metropolitan and micorpolitan communities. The map was developed by [John Lauermann's](https://www.pratt.edu/people/john-lauermann/) lab group in the [School of Information](https://www.pratt.edu/information/) at Pratt Institute. The work received support from the US National Science Foundation, [award #2306194](https://www.nsf.gov/awardsearch/show-award?AWD_ID=2306194). 

# Map products 

The map is available in two formats: 

#### Gentrification patterns on 2020 tract boundaries
Gentrification-related data from 1990 to 2020, adjusted to 2020 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from [National Historical GIS](https://www.nhgis.org/) using the [IPUMS API](ttps://developer.ipums.org/docs/v2/get-started/). Crosswalks are based on the [NHGIS Geographic Crosswalk](https://www.nhgis.org/geographic-crosswalks) methodology. It covers ~56,000 census tracts in ~880 core-based statistical areas, with all data crosswalked to 2020 census boundaries. We recommend using this version of the map for most applications. Replication code is in `01_data`.

#### Historical data on 2010 tract boundaries
Gentrification indicators from 1970 to 2020, adjusted to 2010 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from from [National Historical GIS](https://www.nhgis.org/) using the [IPUMS API](https://developer.ipums.org/docs/v2/get-started/). Crosswalks are based on methods from both [NHGIS Geographic Crosswalks](https://www.nhgis.org/geographic-crosswalks) and the [Longitudinal Tract Data Base](https://s4.ad.brown.edu/projects/diversity/researcher/bridging.htm). It covers ~49,000 census tracts in ~860 core-based statistical areas, with all data crosswalked to 2010 census boundaries. While this map may be useful for historical research, we do not recommend using it for most applications due to spatial noise introduced through the geographic crosswalking method. Replication code is in `02_data_historic`.


# How to use
The replication code are available three folders:
- `01_data` contains the code to construct gentrification indicator data, for the main map product (drawing information from 1990 to 2020, on 2020 tract boundaries)
- `02_data_historic` contains the code to construct the historical version of gentrification indicator data (drawing information from 1970 to 2020, on 2010 tract boundaries)
- `03_spatial` contains the code needed to code construct spatial boundary files. These can subsequently be joined to data from the prior two folders for mapping. 

The statistical workflow runs on R, primarily using `ipumsr` for querying APIs, `dplyr` for data management, and `psych` and `cluster` for calculating gentrification scores. The spatial boundary files are developed in Python, primarily using `ipumpspy` and `requests` for querying APIs and `geopandas` for geoprocessing. Each script defines its required packages, uses the [IPUMS API](https://developer.ipums.org/docs/v2/apiprogram/) to call source data, and uses project-oriented workflows with relative file paths. To run the scripts, simply download the entire folder structure to your local drive and then run from any directory folder. You'll also need a free IPUMS account and API key ([register here](https://developer.ipums.org/docs/v2/get-started/)).  

The spatial boundary files are developed in Python, primarily using `ipumpspy` and `requests` for querying data and `geopandas` for geoprocessing. The finished csv tables and boundary layers are available in the replication data cited below on Harvard Dataverse.

# How to cite
Lauermann, John, et al., 2025, "National Gentrification Intensity Map", https://doi.org/10.7910/DVN/DPKO3I, _Harvard Dataverse_, (https://dataverse.harvard.edu/previewurl.xhtml?token=c430da44-3ff2-4d1a-8eb0-451180015b4c)

# Related publications
Lauermann, John & Mallak, Khouloud (2023). Elite capture and urban geography: Analyzing geographies of privilege. _Progress in Human Geography_, 47(5), 645-663. https://doi.org/10.1177/03091325231186810

Lauermann, John, Viggiani, Alice, Wu, Yuanhao, & Smash, Nathan (forthcoming) National Gentrification Intensity Map: Mapping gentrification across US communities, 1970 to 2020, _The Professional Geographer_

Lauermann, John, Alexander, Zoe, & Wang, Ziqi (2025) Mapping super-gentrification in large US cities, 1990-2020, _Urban Geography_, https://doi.org/10.1080/02723638.2025.2528418
<br>
<br>
<br>

Shield: [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg
