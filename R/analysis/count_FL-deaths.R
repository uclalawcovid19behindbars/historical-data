library(tidyverse)
library(behindbarstools)

FL <- read_csv("https://raw.githubusercontent.com/uclalawcovid19behindbars/historical-data/main/data/FL-historical-data.csv")

FL %>%
  filter(Jurisdiction != "county") %>%
  filter(Date < as.Date("2021-01-01")) %>%
  group_by(Name, Facility.ID) %>%
  arrange(desc(Date)) %>%
  slice(1) %>%
  ungroup() %>%
  summarise(behindbarstools::sum_na_rm(Residents.Deaths))