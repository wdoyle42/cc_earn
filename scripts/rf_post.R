# Random forest postestimation



load("tune_res.Rdata")

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

