library(readxl)
library(tidyverse)
library(lubridate)

# State cleaning helpers --------------------------------------------------
read_sheets <- function(xlsx_file){
  xlsx_file %>%
    excel_sheets() %>%
    set_names() %>%
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
  
  ##Convert date-type 
  all_dat$Date <- as.Date(all_dat$Date, format = "%Y-%m-%d")
  
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

## if Staff.Death is missing, fill it with Staff.Deaths
# table(is.na(df_out$Staff.Death) & !is.na(df_out$Staff.Deaths))
# table(!is.na(df_out$Staff.Death) & is.na(df_out$Staff.Deaths))

# https://stackoverflow.com/questions/45515218/combine-rows-in-data-frame-containing-na-to-make-complete-row
# CAN ALSO SUM BY COLUMN 
coalesce_by_column <- function(df) {
  return(dplyr::coalesce(!!! as.list(df)))
}


assign_prev_data <- function(x) {
  
}


flag_outlier <- function() {
  
}

flag_noncumulative <- function(dat) {
  dat <- dat %>% 
    group_by(facility_name_clean) %>%
    mutate(previous_date_value = lag(Residents.Confirmed, order_by = date)) %>%
    mutate(lag_change = Residents.Confirmed - previous_date_value,
           cumulative = ifelse(lag_change >= 0, TRUE, FALSE)) %>%
    ungroup() 
  return(dat)
}

plot_lag_counts <- function(dat) {
  plots <- dat %>% 
    group_by(facility_name_clean) %>% 
    do(plots=ggplot(data=.) +
         aes(x = date, y = lag_change) + 
         geom_area(alpha=0.6 , size=.5, color = "white") + 
         labs(x = "Date",
              y = "lag_change") + 
         ggtitle(unique(.$facility_name_clean))) 
  return(plots$plots)
}


create_cumulative_count <- function(dat, facility, non_cumulative_var) {
  facility <- enquo(facility)
  non_cumulative_var <- enquo(non_cumulative_var)
  
  out <- dat %>% 
    group_by(facility_name_clean) %>% 
    arrange(date) %>%
    mutate(cumsum = cumsum(!!non_cumulative_var)) %>%
    ungroup 
  # out[[non_cumulative_var]] <- ifelse(out$facility_name_clean == facility, 
  #                                     out$cumsum,
  #                                     out[[non_cumulative_var]])
  # out$cumsum <- NULL
  # 
    # ask someone about this! 
    # tried to do the above in base R but it also didn't work 
  
    # mutate(!!non_cumulative_var = ifelse(facility_name_clean == !!facility,
    #                                     cumsum, 
    #                                     !!non_cumulative_var)) %>%
    # mutate(Residents.Confirmed = ifelse(facility_name_clean == !!facility,
    #                                     cumsum, 
    #                                     Residents.Confirmed)) %>%
  
  return(out)
}


t1 %>% 
  rename( !! quo_name(new_var) := old_name) %>% 
  select(Year, !!new_var) %>% 
  mutate(testvar = !! rlang::sym(rlang::quo_name(new_var)))

new_var = quo(new_name)
t1 %>% 
  rename(!! new_var := old_name) %>% 
  select(Year, !!new_var) %>% 
  mutate(testvar = !! new_var)

# Merge helpers -----------------------------------------------------------

merge_population <- function() {
  
}


