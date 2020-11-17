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


#' A re-coding of the coalesce function to include warnings when multiple
#' values are given which are not NA and are different
#' 
#' @param ... vectors of equal length and type to coalesce
#' @return vector of coalesced values
#' 
#' @examples 
#' coalesce_with_warnings(1:3, 4:6)
#' coalesce_with_warnings(1:3, c(1:2, NA))

coalesce_with_warnings <- function(...){
  d <- cbind(...)
  
  sapply(1:nrow(d), function(i){
    x <- d[i,]
    if(all(is.na(x))){
      out <- NA
    }
    else{
      xbar <- unique(as.vector(na.omit(x)))
      if(length(xbar) != 1){
        warning(paste0(
          "Row ", i, " has multiple values that do not match."))
      }
      # only grab the first one
      out <- xbar[1]
    }
    out
  })
}

# https://stackoverflow.com/questions/45515218/combine-rows-in-data-frame-containing-na-to-make-complete-row
# Consider summing by column when using this function
coalesce_by_column <- function(df) {
  return(coalesce_with_warnings(!!! as.list(df)))
}

coalesce_by_column <- function(df) {
  return(coalesce(!!! as.list(df)))
}

flag_noncumulative_cases <- function(dat) {
  dat <- dat %>% 
    group_by(facility_name_clean) %>%
    mutate(previous_date_value_cases = lag(Residents.Confirmed, order_by = date)) %>%
    mutate(lag_change_cases = Residents.Confirmed - previous_date_value_cases,
           cumulative_cases = ifelse(lag_change_cases >= 0, TRUE, FALSE)) %>%
    ungroup() 
  return(dat)
}

flag_noncumulative_deaths <- function(dat) {
  dat <- dat %>% 
    group_by(facility_name_clean) %>%
    mutate(previous_date_value_deaths = lag(Resident.Deaths, order_by = date)) %>%
    mutate(lag_change_deaths = Resident.Deaths - previous_date_value_deaths,
           cumulative_deaths = ifelse(lag_change_deaths >= 0, TRUE, FALSE)) %>%
    ungroup() 
  return(dat)
}

plot_lag_cases <- function(dat) {
  plots <- dat %>% 
    group_by(facility_name_clean) %>% 
    do(plots=ggplot(data=.) +
         aes(x = date, y = lag_change_cases) + 
         geom_line(alpha=0.6 , size=.5, color = "black") + 
         labs(x = "Date",
              y = "Lag change (cases)") + 
         ggtitle(unique(.$facility_name_clean))) 
  return(plots$plots)
}

plot_lag_deaths <- function(dat) {
  plots <- dat %>% 
    group_by(facility_name_clean) %>% 
    do(plots=ggplot(data=.) +
         aes(x = date, y = lag_change_deaths) + 
         geom_line(alpha=0.6 , size=.5, color = "black") + 
         labs(x = "Date",
              y = "Lag change (deaths)") + 
         ggtitle(unique(.$facility_name_clean)))
  return(plots)
  # plots_tib <- tibble(data = list(df.1, df.2)) %>% 
  #   mutate(plots = plots$plots)
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

# Merge helpers -----------------------------------------------------------

merge_population <- function() {
  
}


