## Enet postestimation

library(tidyverse)
library(tidymodels)
library(here)

cb_df<-read_rds(here("data","cleaned","cb_df.Rds"))

load(here("data","cleaned","earn_wf_fit.Rdata"))

earn_wf_fit%>%
  collect_metrics()

## Last fit

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
enet_fit<-linear_reg(penalty=tune(),
                     mixture=tune()) %>%
  set_engine("glmnet")

## Add model to workflow
earn_wf<-earn_wf%>%
  add_model(enet_fit)


## Model fit
enet_fit <- earn_wf_fit%>%
  unnest(.metrics)%>%
  filter(.metric=="rmse")%>%
  mutate(tune_id=paste0("penalty=",prettyNum(penalty),
                        ", mixture=",prettyNum(mixture))) %>%
  select(tune_id,.estimate)%>%
  rename(RMSE=.estimate)

## %>%
##   ggplot(aes(x=RMSE,color=tune_id,fill=tune_id))+
##   geom_density(alpha=.1)+
##   scale_x_continuous(labels=dollar_format())

save(enet_fit,file = here("data","cleaned","enet_fit.Rdata"))

## Variable Chart

lowest_rmse <- earn_wf_fit %>%
  select_best("rmse")

final_wf <- finalize_workflow(
 earn_wf,
  lowest_rmse
)

final_fit<-final_wf%>%
  fit(cb_df)

final_rmse<-earn_wf_fit%>%
  select_best(metric = "rmse")

final_enet<- finalize_workflow(
    earn_wf,
    lowest_rmse
  )

final_enet<-final_enet%>%fit(cb_df)


vi_final<-final_enet%>%extract_fit_parsnip()%>%vip::vi(scale=TRUE)

save(vi_final, file = here("data","cleaned","enet_vi_final.Rdata"))

gg<-vi_final%>%
  slice(1:25)%>%
  ggplot(aes(y=Importance,x=fct_reorder(Variable,.x=Importance),fill=Sign))+
  geom_col()+
  coord_flip()+
  theme(legend.position="bottom")+
  xlab("")+
  ylab("")

save(gg,file="enet_vi.Rdata")



