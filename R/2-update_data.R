## Define package list
Packages<-c("tidyverse", "devtools", "purrr", "glue")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)
devtools::install_github("uclalawcovid19behindbars/behindbarstools")

update_historical_data <- function(state_in) {
  browser()
  state_select <- substr(state_in, 1, 2)
  ## columns for rbinding 
  historical_cols <- c("Facility.ID", "Jurisdiction", "State", "Name", "Date", "source", "Residents.Confirmed",
                       "Staff.Confirmed", "Residents.Deaths", "Staff.Deaths", "Residents.Recovered",
                       "Staff.Recovered", "Residents.Tadmin", "Staff.Tested", "Residents.Negative",
                       "Staff.Negative", "Residents.Pending", "Staff.Pending", "Residents.Quarantine",
                       "Staff.Quarantine", "Residents.Active", "Residents.Tested",
                       "Residents.Population", 
                       "Address", "Zipcode", "City", "County", "County.FIPS",
                       "Latitude", "Longitude",
                       "Description", "Security", "Age", "Gender", 
                       "Is.Different.Operator", "Different.Operator", 
                       "Population.Feb20", "Source.Population.Feb20",
                       "Capacity", "Source.Capacity", 
                       "HIFLD.ID", "BJS.ID",
                       "Website")
  
  ## columns that could be present but shouldn't be 
  to_rm <- c("Facility", "scrape_name_clean", "federal_bool", "xwalk_name_clean",
             "name_match", "Count.ID", "Population", "Residents.Released", "jurisdiction")
  
  state_full <- behindbarstools::translate_state(state_select)
  
  ## Read latest data from “data” repo
  quiet_read_scrape_data <- quietly(behindbarstools::read_scrape_data)
  latest <- quiet_read_scrape_data(state = state_full,
                                   debug = TRUE)
  latest_dat <- latest$result %>%
    filter(Jurisdiction != "federal") %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE) %>%
    mutate(Zipcode = as.numeric(Zipcode),
           County.FIPS = as.numeric(County.FIPS))
  
  no_match <- latest_dat %>%
    filter(name_match == "FALSE") %>%
    mutate(state = state_select,
           date = Sys.Date(),
           warning = glue("no match: {scrape_name_clean}")) %>%
    select(state, date, warning) %>%
    unique() 

  latest_dat <- latest_dat %>%
    select(-any_of(to_rm)) %>%
    relocate(any_of(historical_cols))

  ## Read data from historical data repo for x state
  hist_dat <- file.path('data', state_in) %>%
    read_csv(col_types = cols()) %>%
    ## account for any changes in facility xwalks
    behindbarstools::clean_facility_name(., debug = TRUE) %>% 
    rename(Facility.ID = Facility.ID.y) %>%
    select(-Facility.ID.x)
  
  ## Get non-matches from historical data
  no_match_hist <- hist_dat %>%
    filter(name_match == FALSE) %>% 
    mutate(state = state_select,
           date = Sys.Date(),
           warning = glue("no match: {scrape_name_clean}")) %>%
    select(state, date, warning) %>%
    unique()
  
  ## Clean up historical data columns
  hist_dat_merging <- hist_dat %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE) %>%
    select(-any_of(to_rm)) %>%
    relocate(any_of(historical_cols))
  
  ## Append historical data and latest data
  check_bindable <- all_equal(hist_dat_merging, latest_dat, ignore_col_order = FALSE)
  
  all_dat <- hist_dat %>%
    bind_rows(latest_dat) %>%
    unique() # only keep unique rows 
  
  ## Write results to historical data repo 
  write_csv(all_dat, glue('data/{state_in}'))
  
  ## Write warnings to log
  latest_warnings <- tibble(state = state_select,
                            date = Sys.Date(),
                            warning = latest$warnings) %>%
    filter(warning != "Missing column names filled in: 'X1' [1]",
           !str_detect(warning, 'multiple values that do not match for column scrape_name_clean')) %>%
    add_row(state = state_select,
            date = Sys.Date(),
            warning = check_bindable) %>%
    bind_rows(no_match) %>%
    bind_rows(no_match_hist) 
  
  if(state_select != "federal"){
    latest_warnings <- latest_warnings %>%
      filter(!str_detect(warning, 'State: Federal'),
             !str_detect(warning, 'Jurisdiction: federal'))
  }
  
  warnings <- read_csv('logs/log.csv', col_types = "cDc") 
  warnings_out <- warnings %>%
    bind_rows(latest_warnings) %>%
    distinct(state, warning, .keep_all = TRUE) # only keep new warnings
  
  # copy the log to a text file
  write_csv(warnings_out, 'logs/log.csv')
}

file.list <- dir(path = 'data', pattern = "*-historical-data.csv")
lapply(file.list, update_historical_data)