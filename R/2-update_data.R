## Define package list
Packages<-c("tidyverse", "devtools", "purrr", "glue")
.packages = Packages
## Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
## Load packages into session 
lapply(.packages, require, character.only=TRUE)
devtools::install_github("uclalawcovid19behindbars/behindbarstools")


update_historical_data <- function(state_select) {
  ## columns for rbinding 
  historical_cols <- c("ID", "jurisdiction", "State", "Name", "Date", "source", "Residents.Confirmed",
                       "Staff.Confirmed", "Residents.Deaths", "Staff.Deaths", "Residents.Recovered",
                       "Staff.Recovered", "Residents.Tadmin", "Staff.Tested", "Residents.Negative",
                       "Staff.Negative", "Residents.Pending", "Staff.Pending", "Residents.Quarantine",
                       "Staff.Quarantine", "Residents.Active", "Residents.Tested",
                       "Residents.Population", 
                       "Address", "Zipcode", "City", "County", "Latitude", "Longitude", "County.FIPS",
                       "hifld_id", "TYPE", "SECURELVL", "CAPACITY", "federal_prison_type", "HIFLD.Population",
                       "Website","Notes")
  
  ## columns that could be present but shouldn't be 
  to_rm <- c("Facility", "scrape_name_clean", "federal_bool", "xwalk_name_clean",
             "name_match", "Count.ID", "Population", "Residents.Released")
  
  state_full <- behindbarstools::translate_state(state_select)
  
  ## Read latest data from “data” repo
  quiet_read_scrape_data <- quietly(behindbarstools::read_scrape_data)
  latest <- quiet_read_scrape_data(state = state_full,
                                   debug = TRUE)
  latest_dat <- latest$result %>%
    filter(jurisdiction != "federal") %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE)
  
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
  hfile_end <- '_adult_facility_covid_counts_historical.csv'
  hfile <- glue('{state_select}{hfile_end}')
  
  hist_dat <- file.path('data', hfile) %>%
    read_csv(col_types = cols()) %>%
    behindbarstools::reorder_cols(add_missing_cols = TRUE) %>%
    select(-any_of(to_rm)) %>%
    relocate(any_of(historical_cols))
  
  ## Append historical data and latest data
  check_bindable <- all_equal(hist_dat, latest_dat, ignore_col_order = FALSE)
  
  all_dat <- hist_dat %>%
    bind_rows(latest_dat) %>%
    unique() # only keep unique rows 
  
  ## Write results to historical data repo 
  write_csv(all_dat, glue('data/{hfile}'))
  
  ## Write warnings to log
  latest_warnings <- tibble(state = state_select,
                            date = Sys.Date(),
                            warning = latest$warnings) %>%
    filter(warning != "Missing column names filled in: 'X1' [1]" ) %>%
    add_row(state = state_select,
            date = Sys.Date(),
            warning = check_bindable) %>%
    bind_rows(no_match)
  warnings <- read_csv('logs/log.csv')
  warnings_out <- warnings %>%
    bind_rows(latest_warnings)
  
  # copy the log to a text file
  write_csv(warnings_out, 'logs/log.csv')
}

update_historical_data("NC")
update_historical_data("CA")
update_historical_data("AZ")
update_historical_data("WI")
update_historical_data("MS")
update_historical_data("FL")


