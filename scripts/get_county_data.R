# CC Earn Data
## Olivia Morales
## 2022-1-10

library(tidyverse)
library(tidycensus)
library(noncensus)
library(cwi)
data(states)

## pull/wrangle data
my_acs_key<-readLines("~/Desktop/projects/csc/my_acs_key",warn = FALSE)
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

educ<-get_acs(geography=my_geo,
              variables=var_list,
              output="wide",
              year = 2019)

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
var_list<-paste0("B19001_",c("001",
                             "013",
                             "014",
                             "015",
                             "016",
                             "017"
))
income<-get_acs(my_geo,
                variables=var_list,
                output="wide",
                year=2019
)
names(income)<-tolower(names(income))
income<-income%>%
  group_by(name)%>%
  mutate(
    income_75 = ((
      b19001_013e +
        b19001_014e +
        b19001_015e +
        b19001_016e +
        b19001_017e 
    ) / b19001_001e)*100
  )%>%
  select(name,geoid,income_75)
var_list<-paste0("B27001_",c("001",
                             "004",
                             "007",
                             "010",
                             "013",
                             "016",
                             "019",
                             "022",
                             "025",
                             "028",
                             "032",
                             "035",
                             "038",
                             "041",
                             "044",
                             "047",
                             "041",
                             "050",
                             "053",
                             "056"                                                                             ))
health<-get_acs(my_geo,
                variables=var_list,
                output="wide",
                year=2019
)
names(health)<-tolower(names(health))
health<-health%>%
  mutate(insured_num=rowSums(.[4:dim(health)[2]]))%>%
  mutate(perc_insured=(insured_num/b27001_001e)*100)%>%
  select(name,perc_insured)
var_list<-paste0("B23025_",c("001",
                             "002"))

labor<-get_acs(my_geo,
               variables=var_list,
               output="wide",
               year=2019
)
names(labor)<-tolower(names(labor))
labor<-labor %>%
  group_by(name)%>%
  mutate(
    perc_in_labor_force = (
      b23025_002e / b23025_001e)*100
  )%>%
  select(name,perc_in_labor_force)
var_list<-paste0("B07003_",c("001","013" ))
mobility<-get_acs(my_geo,
                  variables=var_list,
                  output="wide",
                  year=2019
)
names(mobility)<-tolower(names(mobility))
mobility<-mobility%>%
  group_by(name)%>%
  mutate(perc_moved_in=(b07003_013e/b07003_001e)*100)%>%
  select(name,perc_moved_in)
var_list<-paste0("B08134_",c("001","007","008","009","010"))
commute<-get_acs(my_geo,
                 variables=var_list,
                 output="wide",
                 year=2019)
names(commute)<-tolower(names(commute))
commute<-commute%>%
  mutate(commute_num=rowSums(.[4:dim(commute)[2]]))%>%
  mutate(perc_commute_30p=(commute_num/b08134_001e)*100)%>%
  select(name,perc_commute_30p)
var_list<-paste0("B25008_",c("001","002"))
homeown<-get_acs(my_geo,
                 variables=var_list,
                 output="wide",
                 year=2019
)
names(homeown)<-tolower(names(homeown))
homeown<-
  homeown%>%
  mutate(perc_homeown=(b25008_002e/ b25008_001e)*100)%>%
  select(name,perc_homeown)



