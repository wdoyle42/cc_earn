################################################################################
##
##
##
################################################################################

## libraries
libs <- c("tidyverse", "here", "tidymodels")
sapply(libs, require, character.only = TRUE)

## paths
dat_dir <- here("data")
cln_dir <- file.path(dat_dir, "cleaned")
fig_dir <- here("final_paper", "img")

## -----------------------------------------------------------------------------
## elastic net figures
## -----------------------------------------------------------------------------

load(file.path(cln_dir, "enet_fit.Rdata"))

gg <- enet_fit |>
  ggplot(aes(x=RMSE,color=tune_id,fill=tune_id))+
  geom_density(alpha=.1)+
  scale_x_continuous(labels=scales::dollar_format())

load(file.path(cln_dir, "enet_vi_final.Rdata"))

gg <- vi_final %>%
  slice(1:10) %>%
  mutate(Variable = factor(Variable,
                           levels = c("sch_deg_X3",
                                      "iclevel_X2",
                                      "lpstafford_amt",
                                      "creddesc_Undergraduate.Certificate.or.Diploma",
                                      "creddesc_Bachelors.Degree",
                                      "iclevel_X3",
                                      "dbrr1_fed_ug_rt",
                                      "pcip51",
                                      "grad_debt_mdn10yr",
                                      "age_entry"),
                           labels = c("Predominant degree: BA/BS",
                                      "Two year",
                                      "Federal loan balance (tot)",
                                      "Program is cert/diploma",
                                      "Program is BA/BS",
                                      "Sub-two year",
                                      "1-year repayment rate",
                                      "% health profession",
                                      "Median grad debt (10 year)",
                                      "Average age entry"))) |>
  ggplot(aes(y=Importance,x=fct_reorder(Variable,.x=Importance),fill=Sign))+
  geom_col()+
  coord_flip()+
  ## theme(legend.position="bottom")+
  xlab("")+
  ylab("") +
  theme_gray(base_size = 22)

ggsave(filename = file.path(fig_dir, "enet_fig.png"),
       plot = gg,
       width = 16,
       height = 9,
       units = "in",
       dpi = "retina")

## -----------------------------------------------------------------------------
## random forest figures
## -----------------------------------------------------------------------------

load(file.path(cln_dir, "tune_res.Rdata"))

gg<-tune_res%>%
  collect_metrics() %>%
  filter(.metric == "rmse")%>%
  select(mean,mtry,min_n)%>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "RMSE")

tune_res%>%
  collect_metrics() %>%
  filter(.metric == "rmse")%>%
  select(mean,mtry,min_n)%>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "RMSE")

load(file.path(cln_dir, "vi_final_rf.Rdata"))

gg<-vi_final_rf %>%
  slice(1:10) %>%
  mutate(Variable = factor(Variable,
                           levels = c("creddesc_Undergraduate.Certificate.or.Diploma",
                                      "creddesc_Bachelors.Degree",
                                      "dbrr1_fed_ug_rt",
                                      "age_entry",
                                      "md_faminc",
                                      "faminc_ind",
                                      "cdr3",
                                      "female",
                                      "first_gen",
                                      "pftftug1_ef"),
                           labels = c("Program is cert/diploma",
                                      "Program is BA/BS",
                                      "1-year repayment rate",
                                      "Average age entry",
                                      "Median family income",
                                      "Family income independent students",
                                      "3-year cohort default rate",
                                      "Female",
                                      "First generation",
                                      "Share FTFT UGs"))) |>
  ggplot(aes(x = Importance,
             y = fct_reorder(as_factor(Variable),
                            .x = Importance))) +
  geom_point(size = 5) +
  theme_gray(base_size = 22) +
  ylab("") +
  xlab("")

ggsave(filename = file.path(fig_dir, "rf_vi.png"),
       plot = gg,
       width = 16,
       height = 9,
       units = "in",
       dpi = "retina")

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
