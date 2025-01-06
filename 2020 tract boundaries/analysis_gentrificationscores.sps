* Encoding: UTF-8.
*This script: 
    1) Queries the national longitudinal tract database for relevant variables and geographies
    2) Calculates neighborhood class statistics based on factor analysis
    3) Identifies gentrified tracts based on patterns of neighborhood class change. 

* import longitudinal dataset with relevant variables. 
PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="Your directory\metrodata_allyears_2020tr.csv"
  /ENCODING='UTF8'
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /LEADINGSPACES IGNORE=YES
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  tr2020gj AUTO
  GEOID AUTO
  STATEFP AUTO
  COUNTYFP AUTO
  TRACTCE AUTO
  CBSAFP AUTO
  CBSA_NAME AUTO
  CBSA_NAMELSAD AUTO
  LOCALE AUTO
  LocaleType AUTO
  Bach_pct_1990 AUTO
  Bach_pct_2000 AUTO
  Bach_pct_2010 AUTO
  Bach_pct_2020 AUTO
  Bach_pct_chg_1990to2000 AUTO
  Bach_pct_chg_1990to2020 AUTO
  Bach_pct_chg_2000to2010 AUTO
  Bach_pct_chg_2010to2020 AUTO
  ConRent_mean_1990 AUTO
  ConRent_mean_2000 AUTO
  ConRent_mean_2010 AUTO
  ConRent_mean_2020 AUTO
  ConRent_mean_chg_1990to2000 AUTO
  ConRent_mean_chg_1990to2020 AUTO
  ConRent_mean_chg_2000to2010 AUTO
  ConRent_mean_chg_2010to2020 AUTO
 HHIncome_mean_1990 AUTO
  HHIncome_mean_2000 AUTO
  HHIncome_mean_2010 AUTO
  HHIncome_mean_2020 AUTO
  HHIncome_mean_chg_1990to2000 AUTO
  HHIncome_mean_chg_1990to2020 AUTO
  HHIncome_mean_chg_2000to2010 AUTO
  HHIncome_mean_chg_2010to2020 AUTO
 HouseValue_mean_1990 AUTO
  HouseValue_mean_2000 AUTO
  HouseValue_mean_2010 AUTO
  HouseValue_mean_2020 AUTO
  HouseValue_mean_chg_1990to2000 AUTO
  HouseValue_mean_chg_1990to2020 AUTO
  HouseValue_mean_chg_2000to2010 AUTO
  HouseValue_mean_chg_2010to2020 AUTO
  Population_sum_1990 AUTO
  Population_sum_2000 AUTO
  Population_sum_2010 AUTO
  Population_sum_2020 AUTO
  Poverty_pct_1990 AUTO
  Poverty_pct_2000 AUTO
  Poverty_pct_2010 AUTO
  Poverty_pct_2020 AUTO
  Poverty_pct_chg_1990to2000 AUTO
  Poverty_pct_chg_1990to2020 AUTO
  Poverty_pct_chg_2000to2010 AUTO
  Poverty_pct_chg_2010to2020 AUTO
  WhiteCollar_pct_1990 AUTO
  WhiteCollar_pct_2000 AUTO
  WhiteCollar_pct_2010 AUTO
  WhiteCollar_pct_2020 AUTO
  WhiteCollar_pct_chg_1990to2000 AUTO
  WhiteCollar_pct_chg_1990to2020 AUTO
  WhiteCollar_pct_chg_2000to2010 AUTO
  WhiteCollar_pct_chg_2010to2020 AUTO
  /MAP.
RESTORE.
CACHE.
EXECUTE.


*Query large metropolitan regions, with 2020 populations > 1mn.
SORT CASES BY CBSAFP.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /PRESORTED
  /BREAK=CBSAFP
  /metro_Population_sum_2020=SUM(Population_sum_2020).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (metro_Population_sum_2020  >= 1000000).
EXECUTE.


*calculate factor scores for decadal changes.
FACTOR
  /VARIABLES Bach_pct_chg_1990to2000 ConRent_mean_chg_1990to2000 HHIncome_mean_chg_1990to2000 HouseValue_mean_chg_1990to2000 Poverty_pct_chg_1990to2000 WhiteCollar_pct_chg_1990to2000
  /MISSING MEANSUB
  /ANALYSIS Bach_pct_chg_1990to2000 ConRent_mean_chg_1990to2000 HHIncome_mean_chg_1990to2000 HouseValue_mean_chg_1990to2000 Poverty_pct_chg_1990to2000 WhiteCollar_pct_chg_1990to2000
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_1990to2000 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR
  /VARIABLES Bach_pct_chg_2000to2010 ConRent_mean_chg_2000to2010 HHIncome_mean_chg_2000to2010 HouseValue_mean_chg_2000to2010 Poverty_pct_chg_2000to2010 WhiteCollar_pct_chg_2000to2010
  /MISSING MEANSUB
  /ANALYSIS Bach_pct_chg_2000to2010 ConRent_mean_chg_2000to2010 HHIncome_mean_chg_2000to2010 HouseValue_mean_chg_2000to2010 Poverty_pct_chg_2000to2010 WhiteCollar_pct_chg_2000to2010
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_2000to2010 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR
  /VARIABLES Bach_pct_chg_2010to2020 ConRent_mean_chg_2010to2020 HHIncome_mean_chg_2010to2020 HouseValue_mean_chg_2010to2020 Poverty_pct_chg_2010to2020 WhiteCollar_pct_chg_2010to2020
  /MISSING  MEANSUB
  /ANALYSIS Bach_pct_chg_2010to2020 ConRent_mean_chg_2010to2020 HHIncome_mean_chg_2010to2020 HouseValue_mean_chg_2010to2020 Poverty_pct_chg_2010to2020 WhiteCollar_pct_chg_2010to2020
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAXVARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_2010to2020 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR
  /VARIABLES Bach_pct_chg_1990to2020 ConRent_mean_chg_1990to2020 HHIncome_mean_chg_1990to2020 HouseValue_mean_chg_1990to2020 Poverty_pct_chg_1990to2020  WhiteCollar_pct_chg_1990to2020 
  /MISSING  MEANSUB
  /ANALYSIS Bach_pct_chg_1990to2020 ConRent_mean_chg_1990to2020 HHIncome_mean_chg_1990to2020 HouseValue_mean_chg_1990to2020 Poverty_pct_chg_1990to2020  WhiteCollar_pct_chg_1990to2020 
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_1990to2020 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.


*calculate factor scores for each decade.
FACTOR 
  /VARIABLES Bach_pct_1990 ConRent_mean_1990 HHIncome_mean_1990 HouseValue_mean_1990 Poverty_pct_1990 WhiteCollar_pct_1990
  /MISSING  MEANSUB
  /ANALYSIS Bach_pct_1990 ConRent_mean_1990 HHIncome_mean_1990 HouseValue_mean_1990 Poverty_pct_1990 WhiteCollar_pct_1990
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_1990 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR 
  /VARIABLES Bach_pct_2000 ConRent_mean_2000 HHIncome_mean_2000 HouseValue_mean_2000 Poverty_pct_2000 WhiteCollar_pct_2000
  /MISSING  MEANSUB
  /ANALYSIS Bach_pct_2000 ConRent_mean_2000 HHIncome_mean_2000 HouseValue_mean_2000 Poverty_pct_2000 WhiteCollar_pct_2000
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_2000 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR 
  /VARIABLES Bach_pct_2010 ConRent_mean_2010 HHIncome_mean_2010 HouseValue_mean_2010 Poverty_pct_2010 WhiteCollar_pct_2010
  /MISSING MEANSUB
  /ANALYSIS Bach_pct_2010 ConRent_mean_2010 HHIncome_mean_2010 HouseValue_mean_2010 Poverty_pct_2010 WhiteCollar_pct_2010
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_2010 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.

FACTOR 
  /VARIABLES Bach_pct_2020 ConRent_mean_2020 HHIncome_mean_2020 HouseValue_mean_2020 Poverty_pct_2020 WhiteCollar_pct_2020
  /MISSING  MEANSUB
  /ANALYSIS Bach_pct_2020 ConRent_mean_2020 HHIncome_mean_2020 HouseValue_mean_2020 Poverty_pct_2020 WhiteCollar_pct_2020
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT BLANK(.30)
  /PLOT EIGEN
  /CRITERIA FACTORS(1) ITERATE(25)
  /EXTRACTION PC
  /CRITERIA ITERATE(25)
  /ROTATION VARIMAX
  /SAVE REG(ALL)
  /METHOD=CORRELATION.
COMPUTE FAC_2020 = FAC1_1.
EXECUTE.
DELETE VARIABLES  FAC1_1.
EXECUTE.


*aggregate factor scores by metro.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=CBSAFP
  /metro_FAC_1990=MEAN(FAC_1990) 
  /metro_FAC_1990to2000=MEAN(FAC_1990to2000) 
  /metro_FAC_2000=MEAN(FAC_2000) 
  /metro_FAC_2000to2010=MEAN(FAC_2000to2010) 
  /metro_FAC_2010=MEAN(FAC_2010) 
  /metro_FAC_2010to2020=MEAN(FAC_2010to2020)
  /metro_FAC_2020=MEAN(FAC_2020).
EXECUTE.



* identify middle class tracts with factor scores, controlling to remove any small tracts (less than 100 people).
IF  ((FAC_1990 >= metro_FAC_1990) AND (Population_sum_1990 >=100)) MiddleorUpperClass_1990=1.
IF  (FAC_1990 < metro_FAC_1990) MiddleorUpperClass_1990=0.
IF  ((FAC_2000 >= metro_FAC_2000) AND (Population_sum_2000 >= 100)) MiddleorUpperClass_2000=1.
IF  (FAC_2000 < metro_FAC_2000) MiddleorUpperClass_2000=0.
IF  ((FAC_2010 >= metro_FAC_2010) AND (Population_sum_2010 >= 100)) MiddleorUpperClass_2010=1.
IF  (FAC_2010 < metro_FAC_2010) MiddleorUpperClass_2010=0.
IF  ((FAC_2020 >= metro_FAC_2020) AND (Population_sum_2020 >= 100)) MiddleorUpperClass_2020=1.
IF  (FAC_2020 < metro_FAC_2020) MiddleorUpperClass_2020=0.
EXECUTE.


* identify gentrified tracts based on factor scores and class patterns.
IF ((FAC_1990to2000 >= metro_FAC_1990to2000) AND (Population_sum_1990 >=100)) Gentrifying_90to00 = 1. 
IF (FAC_1990to2000 < metro_FAC_1990to2000) Gentrifying_90to00 = 0. 
IF ((FAC_2000to2010 >= metro_FAC_2000to2010) AND (Population_sum_2000 >= 100)) Gentrifying_00to10 = 1.
IF (FAC_2000to2010 < metro_FAC_2000to2010) Gentrifying_00to10 = 0.
IF ((FAC_2010to2020 >= metro_FAC_2010to2020) AND (Population_sum_2010 >= 100)) Gentrifying_10to20 = 1. 
IF (FAC_2010to2020 < metro_FAC_2010to2020) Gentrifying_10to20 = 0. 
EXECUTE.

COMPUTE Gentrified_90to00= 0. 
IF (MiddleorUpperClass_1990=0 AND Gentrifying_90to00=1 AND MiddleorUpperClass_2000=1 AND Population_sum_1990 >= 100) Gentrified_90to00 = 1. 
COMPUTE Gentrified_00to10 = 0. 
IF ((MiddleorUpperClass_1990=0 OR MiddleorUpperClass_2000= 0) AND Gentrifying_00to10= 1 AND MiddleorUpperClass_2010=1 AND Population_sum_2000 >= 100) Gentrified_00to10 = 1. 
COMPUTE Gentrified_10to20 = 0. 
IF ((MiddleorUpperClass_1990=0 OR MiddleorUpperClass_2000=0 OR MiddleorUpperClass_2010=0) AND Gentrifying_10to20=1 AND MiddleorUpperClass_2020=1 AND
    Population_sum_2010 >= 100) Gentrified_10to20 = 1. 
EXECUTE. 

COMPUTE Gentrified = 0. 
IF (Gentrified_90to00 = 1 OR Gentrified_00to10 = 1 OR Gentrified_10to20=1) Gentrified = 1. 
EXECUTE. 


*identify super-gentrification with factor scores.
COMPUTE SuperGentrified_90to10 = 0.
IF  ((Gentrified_90to00 = 1) AND (Gentrifying_00to10 = 1)) SuperGentrified_90to10 = 1.
COMPUTE SuperGentrified_00to20 = 0.
IF  ((Gentrified_90to00 = 1 OR Gentrified_00to10 = 1) AND (Gentrifying_10to20 = 1)) SuperGentrified_00to20 = 1.
EXECUTE.

COMPUTE SuperGentrified = 0.
IF (SuperGentrified_90to10 = 1 OR SuperGentrified_00to20 = 1) SuperGentrified = 1. 
EXECUTE. 


*identify historically affluent with factor scores.
COMPUTE HistoricallyAffluent = 0. 
IF  ((MiddleorUpperClass_1990 = 1 AND MiddleorUpperClass_2000 = 1 AND MiddleorUpperClass_2010 = 1 AND MiddleorUpperClass_2020 = 1) 
     AND Gentrified = 0 AND SuperGentrified = 0 AND Population_sum_1990 >= 100)    
     HistoricallyAffluent = 1.
EXECUTE.

*classify by class type.
STRING classtype (a22).
EXECUTE.
COMPUTE classtype = 'not gentrified'.
IF SuperGentrified = 1 classtype = 'super-gentrified'. 
IF (Gentrified = 1 AND SuperGentrified = 0) classtype = 'gentrified'. 
IF (HistoricallyAffluent = 1) classtype = 'historically affluent'. 
EXECUTE. 

*save results back to a CSV.
SAVE TRANSLATE OUTFILE="C:\Users\johnl\My Drive (jlauerma@pratt.edu)\Research\Gentrification mapping\data\largemetros_allyears_2020tr.csv"
  /ENCODING='UTF8'
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.
