## Define package list
Packages<-c("tidyverse")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)

a <- 1:5
df <- tibble(a, a * 2)

write.csv(df, "data/test.csv")
