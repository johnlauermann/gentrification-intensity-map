# National Gentrification Intensity Map
#### Team: [John Lauermann](https://www.pratt.edu/people/john-lauermann/), [Ziqi Wang](https://www.linkedin.com/in/ziqi-wang-0623/), [Anna Feldman](https://www.linkedin.com/in/annaelsafeldman/), [Yuanhao Wu](https://www.linkedin.com/in/yuanhao-wu-80603723a/), [Nathan Smash](https://www.linkedin.com/in/nathan-smash-b6b93a24a/)
This repository contains code and data related to a national longitudinal tract database on gentrification patterns in American cities. It includes two data products:

#### Gentrification patterns on 2020 tract boundaries
Gentrification-related data from 1990 to 2020, adjusted to 2020 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from [National Historical GIS](https://www.nhgis.org/) using the [IPUMS API](ttps://developer.ipums.org/docs/v2/get-started/). Crosswalks are based on the [NHGIS Geographic Crosswalk](https://www.nhgis.org/geographic-crosswalks) methodology. 

#### Historical data on 2010 tract boundaries
Gentrification indicators from 1970 to 2020, adjusted to 2010 census tract boundaries. This is based on Decennial Census and American Community Survey data, drawn from from [National Historical GIS](https://www.nhgis.org/) using the [IPUMS API](https://developer.ipums.org/docs/v2/get-started/). Crosswalks are based on methods from both [NHGIS Geographic Crosswalks](https://www.nhgis.org/geographic-crosswalks) and the [Longitudinal Tract Data Base](https://s4.ad.brown.edu/projects/diversity/researcher/bridging.htm).


## How to use
The replication code are available in the `code` folder, including annotated scripts explaining how to choose different Census/ACS variables in your workflow. The workflow primarily runs on R. Each script defines its required packages, uses the [IPUMS API](https://developer.ipums.org/docs/v2/apiprogram/) to call source data, and uses [here](https://here.r-lib.org/) to create and save project-oriented workflows with relative file paths. To run the scripts, simply download them to your local drive and then run locally. You'll also need a free IPUMS account and API key ([register here](https://developer.ipums.org/docs/v2/get-started/)).  

The finished GIS data are available in the replication data cited below on Harvard Dataverse. Most data are available there in geodatabase format (for open-source users, here's how to read a geodatabase in [QGIS](https://qgis-in-mineral-exploration.readthedocs.io/en/latest/source/how_to/esri_files.html), [R](https://r.esri.com/assets/arcgisbinding-vignette.html), or [Python](https://geopandas.org/en/v0.6.0/io.html)). 



## Related data & publications
Lauermann, John, Alexander, Zoe, & Wang, Ziqi (2025) Mapping super-gentrification in large US cities, 1990-2020, _Urban Geography_, https://doi.org/10.1080/02723638.2025.2528418

Lauermann, John, Wang, Ziqi, Feldman, Anna, Wu, Yuanhao, & Smash, Nathan (2025) "Replication Data for: Mapping super-gentrification in large US cities, 1990 to 2020",  Harvard Dataverse, V2, https://doi.org/10.7910/DVN/BSAF99


