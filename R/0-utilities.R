library(readxl)
library(tidyverse)
library(lubridate)

# State cleaning helpers --------------------------------------------------
read_sheets <- function(xlsx_file){
  xlsx_file %>%
    excel_sheets() %>%
    rlang::set_names() %>%
    map_df(~ read_excel(path = xlsx_file, sheet = .x, col_types = "text"), .id = 'sheet_name') %>%
    select(sheet_name, everything())
}

## Date format must be two date: c("2020-03-05", "2020-06-28")
load_data <- function(data_path, 
                      last_date_collected, 
                      filter_state=NULL, 
                      filter_facility=NULL,
                      filter_date=NULL) {
  
  file_name <- str_c("Covid Custody Project_", last_date_collected, ".xlsx")
  historical_datafile <- file.path(data_path, file_name)
  all_dat <- read_sheets(xlsx_file = historical_datafile)
  
  ##No use case for filtering multi-subset of states
  if(!is.null(filter_state)) {
    filter1_df <- all_dat %>% 
      dplyr::filter(State == filter_state)
  } else {
    filter1_df <- all_dat
  }
  ##Filter facility, if argument exists
  if(!is.null(filter_facility)) {
    filter2_df <- filter1_df %>% 
      dplyr::filter(Facility == filter_facility)
  } else {
    filter2_df <- filter1_df
  }
  ##Filter date, if argument exists
  if(!is.null(filter_date)) {
    filter3_df <- filter2_df %>% 
      filter(between(FL_DATE, as.Date(filter_date[1]), as.Date(filter_date[2])))
  } else {
    filter3_df <- filter2_df
  }
  return(filter3_df)
}

flag_noncumulative_cases <- function(dat, grp_var) {
  dat <- dat %>% 
    group_by({{grp_var}}) %>%
    mutate(previous_date_value_cases = lag(Residents.Confirmed, order_by = Date)) %>%
    mutate(lag_change_cases = Residents.Confirmed - previous_date_value_cases,
           cumulative_cases = ifelse(lag_change_cases >= 0, TRUE, FALSE)) %>%
    ungroup() 
  return(dat)
}

flag_noncumulative_deaths <- function(dat, grp_var, death_var) {
  dat <- dat %>% 
    group_by({{grp_var}}) %>%
    mutate(previous_date_value_deaths = lag({{death_var}}, order_by = Date)) %>%
    mutate(lag_change_deaths = {{death_var}} - previous_date_value_deaths,
           cumulative_deaths = ifelse(lag_change_deaths >= 0, TRUE, FALSE)) %>%
    ungroup() 
  return(dat)
}

plot_lags <- function(dat, date, y_var, grp_var, y_lab = NULL) {
  if(is.null(y_lab)){ y_label <- y_var }
  else { y_label <- y_lab }
  # y_label = ifelse(is.null(y_lab), y_var, y_lab)
  plots <- dat %>% 
    group_by({{grp_var}}) %>% 
    do(plot=ggplot(data=.) +
         aes_string(x = date, y = y_var) +
         geom_line(alpha=0.6 , size=.5, color = "black") + 
         labs(x = "Date",
              y = y_label) + 
         scale_x_date(date_minor_breaks = "1 month", date_labels = "%m/%y", 
                      date_breaks = "1 month") + 
         ggtitle(unique(.$Name))) # NB: might need to change this if change grouping var
  return(plots)
}

reorder_historical_cols <- function(data, add_missing_cols=TRUE, rm_extra_cols=FALSE) {
  historical_cols <- c("ID", "jurisdiction", "State", "Name", "Date", "source", "Residents.Confirmed",
                    "Staff.Confirmed", "Residents.Deaths", "Staff.Deaths", "Residents.Recovered",
                    "Staff.Recovered", "Residents.Tadmin", "Staff.Tested", "Residents.Negative",
                    "Staff.Negative", "Residents.Pending", "Staff.Pending", "Residents.Quarantine",
                    "Staff.Quarantine", "Residents.Active", "Residents.Tested",
                    "Residents.Population", 
                    "Address", "Zipcode", "City", "County", "Latitude", "Longitude", "County.FIPS",
                    "hifld_id", "TYPE", "SECURELVL", "CAPACITY", "federal_prison_type", "HIFLD.Population",
                    "Website","Notes")
  these_cols <- names(data)
  missing_cols <- if(all(historical_cols %in% these_cols)) { NULL } else(base::setdiff(historical_cols, these_cols))
  additional_cols <- if(all(these_cols %in% historical_cols)) { NULL } else(base::setdiff(these_cols, historical_cols))
  
  data <- data %>%
    relocate(any_of(historical_cols))
  
  if(rm_extra_cols & (length(additional_cols) > 0 )){
    add_out = data %>%
      select(-all_of(additional_cols))
  }
  else{
    if(length(additional_cols) > 0) {
      warning(paste0("Input data has ", length(additional_cols),
                     " additional columns: ", paste0(additional_cols, collapse = ", "),
                     ". Moving these to the end of the data set."))
      add_out <- data %>%
        relocate(additional_cols, .after = last_col())
    }
    if(length(additional_cols) == 0) {
      add_out = data
    }
  }
  if(!add_missing_cols & (length(missing_cols) > 0 )) {
    warning(paste0("Input data has ", length(missing_cols),
                   " missing columns: ", paste0(missing_cols, collapse = ", "),
                   ". Do you need to rename a column?"))
    missing_out <- add_out
  }
  else{
    if(length(missing_cols) > 0) {
      warning(paste0("Input data has ", length(missing_cols),
                     " missing columns: ", paste0(missing_cols, collapse = ", "),
                     ". Adding these columns in as NA rows."))
      add_out[,missing_cols] <- NA
      missing_out <- add_out
    }
    if(length(missing_cols) == 0) {
      missing_out <- add_out
    }
  }
  out <- missing_out %>%
    relocate(any_of(historical_cols))
  return(out)
}

# State monitoring helpers --------------------------------------------------

filter_statewide_NA <- function(dat, var) {
  out <- dat %>% 
    filter(
      !(str_detect(Name, "(?i)state") & str_detect(Name, "(?i)wide"))) %>%
    filter(!is.na({{var}})) 
  return(out)
}

## function that eliminates state-wide and NA observations, 
## groups by facility name, and returns the most recent value of an input variable
## chronologically. should be used for cumulative variables!
get_last_value <- function(dat, var, labeller) {
  label_ = as_label(expr(labeller)) # not working
  last_values <- dat %>% 
    filter_statewide_NA({{var}}) %>%
    group_by(Name) %>%
    summarise(label_ = last({{var}}, order_by = Date))
  return(last_values)
}

## function that eliminates state-wide and NA observations, 
## and returns the unique value on non-NA facilities present for a given input variable
get_fac_n <- function(dat, var) {
  fac_n <- dat %>%
    filter_statewide_NA({{var}}) %>%
    pull(Name) %>%
    unique() %>%
    length()
  return(fac_n)
}


