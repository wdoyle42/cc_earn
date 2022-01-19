# CC Earn Data
## Olivia Morales
## 2022-1-12

library(tidyverse)
library(tidycensus)
library(noncensus)
library(devtools)
data(states)


## pull/wrangle data
my_acs_key<-readLines("./my_acs_key",warn = FALSE)
acs_key<-my_acs_key
census_api_key(acs_key)
my_geo<-"county"
v19 <- load_variables(2019, "acs5", cache = TRUE)
var_list<-paste0("B15002_",c("001",
                             "015",
                             "016",
                             "017",
                             "018",
                             "032",
                             "033",
                             "034",
                             "035"))

# creating educ df by county
educ<-get_acs(geography=my_geo,
              variables=var_list,
              output="wide",
              year = 2019)

names(educ)[names(educ)=='GEOID'] <- 'County ID (FIPS)'

names(educ)<-tolower(names(educ))
educ<-educ%>%
  group_by(name)%>%
  mutate(college_educ=((b15002_015e+
                          b15002_016e+
                          b15002_017e+
                          b15002_018e+
                          b15002_032e+
                          b15002_033e+
                          b15002_034e+
                          b15002_035e)/b15002_001e)*100) %>%
  select(name,college_educ)

#median income df by county
var_list<-paste0("B19013_",c("001"))

income<-get_acs(my_geo,
                variables=var_list,
                output="wide",
                year=2019)

names(income) <- tolower(names(income))
income = subset(income, select = -c(b19013_001m, geoid))

names(income)[names(income)=='b19013_001e'] <- 'median income'

#labor force participation df by county


var_list<-paste0("B23025_",c("001", "002"))

labor<-get_acs(my_geo,
               variables=var_list,
               output="wide",
               year=2019)
                                      
names(labor)<-tolower(names(labor))
labor<-labor %>%
    group_by(name)%>%
    mutate(perc_in_labor_force = (b23025_002e/b23025_001e) *100) %>%
    select(name,perc_in_labor_force)
  

#housing df by county

var_list<-paste0("B25008_",c("001","002"))

homeown<-get_acs(my_geo,
                  variables=var_list,
                  output="wide",
                  year=2019)

names(homeown) <- tolower(names(homeown))

homeown<-
   homeown%>%
   mutate(perc_homeown=(b25008_002e/ b25008_001e)*100)%>%
   select(name,perc_homeown)


area_data <- educ %>%
  left_join(homeown, by = "name")
  
area_data <- area_data %>%
  left_join(income, by = "name")
  
area_data <- area_data %>%
  left_join(labor, by = "name")

names(area_data)[names(area_data)=='college_educ'] <- '% college educated'
names(area_data)[names(area_data)=='perc_homeown'] <- '% of homeowners'
names(area_data)[names(area_data)=='perc_in_labor_force'] <- '% in labor force'

# small area estimates by county (BLS)

## One or More Series, Specifying Years 
   payload <- list('seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'), 'startyear'='2019', 'endyear'='2019') 
   response <- blsAPI(payload) 
   json <- fromJSON(response) 
   
blsAPI <- function(data=NA){ 
       require(rjson) 
       require(RCurl) 
       h = basicTextGatherer() 
       h$reset() 
       if(is.na(data)){ 
           message('blsAPI: No parameters specified.')} 
       
       else{if(is.list(data)){ 
                 ## Multiple Series or One or More Series, Specifying Years request 
                   curlPerform(url='https://api.bls.gov/publicAPI/v1/timeseries/data/', 
                                                httpheader=c('Content-Type' = "application/json;"), 
                                                postfields=toJSON(data), 
                                                verbose = FALSE,  
                                                writefunction = h$update)} 
                 else{ 
                   ## Single Series request 
                     curlPerform(url=paste0('https://api.bls.gov/publicAPI/v1/timeseries/data/',data), 
                                                  verbose = FALSE,  
                                                  writefunction = h$update)}}} 
   