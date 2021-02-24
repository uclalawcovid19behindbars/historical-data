## Define package list
Packages<-c("tidyverse", "devtools", "purrr", "glue", "readr")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)
devtools::install_github("uclalawcovid19behindbars/behindbarstools")

update_historical_data <- function(state_in) {
  state_select <- substr(state_in, 1, 2)
  
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
    behindbarstools::reorder_cols(add_missing_cols = TRUE, rm_extra_cols = FALSE) 
  
  no_match <- latest_dat %>%
    filter(name_match == "FALSE") %>%
    mutate(state = state_select,
           date = Date,
           warning_type = "no match",
           warning = scrape_name_clean) %>%
    select(state, date, warning_type, warning) 
  
  ## Read data from historical data repo for x state
  hist_dat <- file.path('data', state_in) %>%
    read_csv(col_types = cols(
      Date = "D",
      Jurisdiction = "c",
      State = "c",
      Name = "c",
      source = "c",
      Facility.ID = "d",
      Residents.Confirmed = "d",
      Staff.Confirmed = "d",
      Residents.Deaths = "d",
      Staff.Deaths = "d",
      Residents.Recovered = "d",
      Staff.Recovered = "d",
      Residents.Tadmin = "d",
      Staff.Tested = "d",
      Residents.Negative = "d",
      Staff.Negative = "d",
      Residents.Pending = "d",
      Staff.Pending = "d",
      Residents.Quarantine = "d",
      Staff.Quarantine = "d",
      Residents.Active = "d",
      Residents.Tested = "d",
      Residents.Population = "d",
      Residents.Initiated = "d",
      Residents.Completed = "d",
      Residents.Vadmin = "d",
      Staff.Initiated = "d",
      Staff.Completed = "d",
      Staff.Vadmin = "d",
      Population.Feb20 = "d",
      Zipcode = "c",
      Latitude = "d",
      Longitude = "d",
      County.FIPS = "c",
      HIFLD.ID = "c",
      Capacity = "d",
      BJS.ID = "c",
      Security = "c",
      Different.Operator = "c",
      jurisdiction_scraper = "c",
      Is.Different.Operator = "l",
      ICE.Field.Office = "c",
      Age = "c",
      Gender = "c",
      Description = "c"
      )) %>%
    ## account for any changes in facility xwalks
    behindbarstools::clean_facility_name(., debug = TRUE) %>%
    dplyr::rename(Facility.ID = Facility.ID.y) %>%
    select(-Facility.ID.x)

  ## Get non-matches from historical data
  no_match_hist <- hist_dat %>%
    filter(name_match == FALSE) %>% 
    mutate(state = state_select,
           date = Date,
           warning_type = "no match",
           warning = scrape_name_clean) %>%
    select(state, date, warning_type, warning)
  
  hist_dat_merging <- hist_dat %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE, rm_extra_cols = TRUE)
  
  latest_dat_merging <- latest_dat %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE, rm_extra_cols = TRUE)
  
  ## Append historical data and latest data
  check_bindable <- all_equal(hist_dat_merging, latest_dat_merging, ignore_col_order = FALSE)
  
  all_dat <- hist_dat_merging %>%
    bind_rows(latest_dat_merging) %>%
    unique() # only keep unique rows 
  
  ## Write results to historical data repo 
  write_csv(all_dat, glue('data/{state_in}'))
  
  ## Write warnings to log
  latest_warnings <- tibble(state = state_select,
                            date = Sys.Date(),
                            warning = latest$warnings) %>%
    filter(warning != "Missing column names filled in: 'X1' [1]",
           !str_detect(warning, 'multiple values that do not match for column scrape_name_clean'),
           !str_detect(warning, 'Input data has 5 additional columns'), # no warning on debug columns (these get rm'd later)
           !str_detect(warning, 'unique values state, state'), # no warning on coalesce by jurisdiction if both = state
           !str_detect(warning, 'column `State`: character vs character')
           ) %>%
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
  
  warnings <- read_csv('logs/log.csv', col_types = "cDcc") 
  warnings_out <- warnings %>%
    bind_rows(latest_warnings) %>%
    distinct(state, warning, .keep_all = TRUE) # only keep new warnings
  
  # copy the log to a text file
  write_csv(warnings_out, 'logs/log.csv')
}

file.list <- dir(path = 'data', pattern = "*-historical-data.csv")
lapply(file.list, update_historical_data)
