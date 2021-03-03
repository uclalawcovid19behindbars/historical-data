## Define package list
Packages<-c("tidyverse", "devtools", "purrr", "glue", "readr", "plyr")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)
devtools::install_github("uclalawcovid19behindbars/behindbarstools")

## update one state's historical data by reading data from the server,
## logging any mis-matches, and any other warnings along the way
update_historical_data <- function(state_in) {
  ## columns that could be present but shouldn't be 
  to_rm <- c("Facility", "scrape_name_clean", "federal_bool", "xwalk_name_clean",
             "name_match", "Count.ID", "Population", "Residents.Released", "jurisdiction")
  
  state_full <- behindbarstools::translate_state(state_in)
  
  ## Read latest data from “data” repo
  quiet_read_scrape_data <- quietly(behindbarstools::read_scrape_data)
  latest <- quiet_read_scrape_data(state = state_full,
                                   all_dates = TRUE,
                                   debug = TRUE)
  latest_dat <- latest$result %>%
    filter(Jurisdiction != "federal") %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE, rm_extra_cols = FALSE) 
  
  no_match <- latest_dat %>%
    filter(name_match == "FALSE") %>%
    mutate(state = state_in,
           date = Date,
           warning_type = "no match",
           warning = scrape_name_clean) %>%
    select(state, date, warning_type, warning) 

  ## rm cols from debug setting
  out <- latest_dat %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE, 
                                  rm_extra_cols = TRUE)
  
  ## Write results to historical data repo 
  write_csv(out, glue('data/{state_in}-historical-data.csv'))
  
  ## Write warnings to log
  latest_warnings <- tibble(state = state_in,
                            date = Sys.Date(),
                            warning = latest$warnings) %>%
    filter(warning != "Missing column names filled in: 'X1' [1]",
           !str_detect(warning, 'multiple values that do not match for column scrape_name_clean'),
           !str_detect(warning, 'Input data has 5 additional columns'), # no warning on debug columns (these get rm'd later)
           !str_detect(warning, 'unique values state, state'), # no warning on coalesce by jurisdiction if both = state
           !str_detect(warning, 'column `State`: character vs character')
           ) %>%
    bind_rows(no_match) 
  
  if(state_in != "federal"){
    latest_warnings <- latest_warnings %>%
      filter(!str_detect(warning, 'State: Federal'),
             !str_detect(warning, 'Jurisdiction: federal'))
  }
  
  warnings <- read_csv('logs/log.csv', col_types = "cDcc") 
  warnings_out <- warnings %>%
    bind_rows(latest_warnings) %>%
    distinct(state, warning, .keep_all = TRUE) # only keep new warnings
  
  # copy the log to a text file
  write_csv(warnings_out, 'logs/log.csv')
}

## run update_historical_data on some or all states, depending 
## on settings in config.yaml
run_main <- function(settings) {
  settings <- plyr::compact(lapply(settings, function(x)
  { if(x$run) {return(x)}}))
  
  states_to_clean <- settings %>% 
    .[[1]] %>% 
    purrr::pluck("states")  
  
  if (names(settings) == "all") {
    lapply(states_to_clean, update_historical_data)
  } 
  else {
    cat("Updating + cleaning a subset of states: ", states_to_clean)
    lapply(states_to_clean, update_historical_data)
  }
}

## read config file and either clean all states, or a subset of them 
config <- yaml::read_yaml("./config.yaml")
cleaning_settings <- config$`cleaning-settings`
run_main(cleaning_settings)
