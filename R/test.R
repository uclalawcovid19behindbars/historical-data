## Define package list
Packages<-c("tidyverse", "devtools")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)

devtools::install_github("uclalawcovid19behindbars/behindbarstools")


a <- 1:5
df <- tibble(a, a * 2, Sys.time())

write.csv(df, "data/test.csv")
