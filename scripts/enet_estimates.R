# CC Earn Data
## Will Doyle
## 2021-10-13

library(tidyverse)
library(rscorecard)
library(tidycensus)
library(ipumsr)
library(janitor)
library(here)
library(tidymodels)


## Presets

hardhat::default_recipe_blueprint(allow_novel_levels = TRUE)

## Load Data
cb_df<-read_rds(here("data","cleaned","cb_df.Rds"))

## Create resampled dataset
cb_rs<-vfold_cv(cb_df,v = 20)

## set formula
earn_formula<-("earn_mdn_hi_1yr~.")

## Pre-processing via recipe
earn_recipe<-recipe(cb_df,earn_formula) %>%
  step_zv(all_predictors())%>%
  step_nzv(all_numeric_predictors())%>%
  update_role(-opeid6,new_role="predictor")%>%
  update_role(earn_mdn_hi_1yr,new_role="outcome")%>%
  update_role(opeid6,new_role="id variable")%>%
  step_naomit(all_predictors())%>%
  step_other(all_nominal_predictors(),threshold = .005)%>%
  step_dummy(all_nominal_predictors())%>%
  step_zv(all_predictors(),skip=TRUE) %>%
  step_nzv(all_numeric_predictors(),skip=TRUE)%>%
  step_normalize(all_numeric_predictors())%>%
  step_corr(all_numeric_predictors(),skip=TRUE,threshold = .95)

## Check dataset
ck_df<-earn_recipe%>%prep()%>%bake(cb_df)

## Create empty workflow
earn_wf<-workflow()

## Add recipe
earn_wf<-earn_wf%>%
  add_recipe(earn_recipe)

## Add enet model
enet_fit<-
  linear_reg(penalty=tune(),
             mixture=tune()) %>%
  set_engine("glmnet")

## Set tuning grid
enet_grid<-expand_grid(penalty=seq(0,1,by=.333),
                       mixture=seq(0.05,1,by=.45))

## Add model to workflow
earn_wf<-earn_wf%>%
  add_model(enet_fit)

doParallel::registerDoParallel(cores = 20)

earn_wf_fit<- tune_grid(earn_wf,
                        resamples=cb_rs, ##resampling plan
                        grid=enet_grid)

save(earn_wf_fit,file = "earn_wf_fit.Rdata")
