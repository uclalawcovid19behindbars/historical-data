## General Dataset Cleaning - Running State Reports
## Data Fellow: Michael Everett
## Status: Unfinished Working Draft

## General Load -----------------------------------------------------------

##Define package list
Packages <- c("readxl","tidyverse","ggthemes","pdftools", "plyr")
.packages = Packages
##Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
##Load packages into session 
lapply(.packages, require, character.only=TRUE)

##Load in historical data
base_path <- file.path("~", "UCLA", "code", "historical", "historical-data")
data_folder <- file.path("data", "xlsx")
historical_data <- file.path(base_path, data_folder, "Covid Custody Project_100720.xlsx")

tab_Names <- excel_sheets(path = historical_data)
list_all <- lapply(tab_Names, function(x)
  read_excel(path = historical_data, sheet = x))
#! why not looking at 15-19?
data <- plyr::rbind.fill(list_all) %>%
  subset(., select = -c(...15,...16,...17,...18,...19)) 
ucla <- data

f <- read_xlsx(file.path(base_path, data_folder,"facility_spellings_091820.xlsx"))

id_xwalk <- f %>%
  select(Count.ID, State, City, facility_name_raw, facility_name_clean) %>%
  dplyr::rename("Name" = "facility_name_raw") %>%
  unique()
print(n_distinct(id_xwalk$facility_name_clean))

# fac_info <- read_xlsx(file.path(base_path, data_folder,"facility_information_091820.xlsx")) %>%
#   # we don't want this information as of now since we don't know how accurate it is
#   select(-TYPE, -POPULATION, -CAPACITY, -SECURELVL, -federal_prison_type) %>%
#   # we don't need this information since it's already on the file
#   select(-Name)

select <- read_xlsx(file.path(base_path, data_folder,"20.10.8_Columns_Selected.xlsx")) %>%
          select(ColName)


## Write Functions ---------------------------------------------------------

# graph_state <- function(x, y, k) {
#   x$y <- as.numeric(x[, y])
#   x$Date <- as.Date(x$Date, format = "%Y-%m-%d")
#   z <- x %>%
#        group_by(Date) %>%
#        dplyr::summarise(n = sum(y, na.rm = TRUE))
#     ggplot(data = z, aes(x = Date, y = n)) +
#     geom_line() +
#     geom_point() +
#     labs(x = "Date",
#          y = "Inmate Deaths",
#          title = paste0("Test Graph for ", k)) +
#     theme_economist()
#   ggsave(filename = paste0(k, ".pdf"), 
#          plot = last_plot(),
#          width = 8,
#          device = "pdf")
# }

# state_report_og <- function(x) {
#   # merge on ID
#   
#   x <- x %>%
#     subset(., select = -c(Count.ID)) %>%
#     merge(., id_xwalk, by = c("State", "Name")) %>%
#     select(-Name) %>%
#     rename("Name" = "facility_name_clean") 
#   
#   colnames(select) <- "x"
#   present <- as.data.frame(colnames(x))
#   colnames(present) <- "x"
#   final <- merge(present, select, by = "x")
#   df <- x %>%
#     select(final$x)
#   state_name <- df[1, "State"]
#   df$Date <- as.Date(x$Date, format = "%Y-%m-%d")
#   match <- c("Count.ID", "Date", "Name", "Facility", "State")
#   hold <- as.character(colnames(df)) %in% match
#   df <- cbind(df[, hold], df[, !hold])
#   
#   for (i in 6:length(colnames(df))) {
#     var <- colnames(df)[i]
#     df[, i] <- as.numeric(df[, i])
#     
#     df_sum <- df %>%
#       group_by(Date) %>%
#       dplyr::summarise(n = sum(eval(parse(text = var)), na.rm = TRUE))
#     ggplot(data = df_sum, aes(x = Date, y = n)) +
#       geom_line() +
#       geom_point() +
#       labs(x = "Date",
#            y = var,
#            title = paste0("Case Graph for ", state_name, " | ", var)) +
#       theme_economist()
#     ggsave(filename = paste0("page_", i, ".pdf"), 
#            plot = last_plot(),
#            width = 8,
#            device = "pdf")
#   
#     
#   }
#   
#   
#   
#   eval(parse(text = paste("pdf_combine(c(", paste("'page_",
#                                                   6:length(colnames(df)), ".pdf'", sep = "",
#                                                   collapse = ","), "), output = ", paste0("'", state_name, "_report.pdf'"),
#                           ")")))
#   
#   
#   
# }

## NB: should make target out file for all of these

state_report <- function(x) {
  # merge on ID
  
  x <- x %>%
    subset(., select = -c(Count.ID)) %>%
    merge(., id_xwalk, by = c("State", "Name")) %>%
    ##! this seems potentially risky. what if we want to keep both instances of `Name`?
    select(-Name) %>%
    dplyr::rename("Name" = "facility_name_clean")
  
  browser()
  colnames(select) <- "x"
  present <- as.data.frame(colnames(x))
  colnames(present) <- "x" 
  ## only keeps variables from `select`
  ## needs to be re-coded for clarity
  final <- merge(present, select, by = "x")
  ## subsets data to columns in `select`
  df <- x %>%
        select(final$x)
  state_name <- df[1, "State"]
  df$Date <- as.Date(x$Date, format = "%Y-%m-%d")
  match <- c("Count.ID", "Date", "Name", "Facility", "State")
  hold <- as.character(colnames(df)) %in% match
  ## re-order columns to put `match` ones in front
  df <- cbind(df[, hold], df[, !hold])

  
  ## Facility per day graph
  df_fac <- df %>%
    group_by(Date) %>%
    dplyr::summarise(n = n())
  ggplot(data = df_fac, aes(x = Date, y = n)) +
    geom_line(color = "blue") +
    geom_point(color = "orange") +
    labs(x = "Date",
         y = "Number of Facilities",
         title = paste0("Fac Count Graph for ", state_name)) +
    theme_economist()
  ggsave(filename = paste0("fac_count.pdf"), 
         plot = last_plot(),
         width = 8,
         device = "pdf")
  
  df_dup <- df %>%
    group_by(Date, Name) %>%
    filter(n() > 1) %>%
    dplyr::summarise(n = n())
  ggplot(data = df_dup, aes(x = Date, y = n)) +
    geom_line(color = "blue") +
    geom_point(color = "orange") +
    labs(x = "Date",
         y = "Number of Duplicates",
         title = paste0("Dup Count Graph for ", state_name)) +
    theme_economist()
  ggsave(filename = paste0("dup_count.pdf"), 
         plot = last_plot(),
         width = 8,
         device = "pdf")
  
  ## loop through numeric vars of interest and make plots
  for (i in 6:length(colnames(df))) {
    var <- colnames(df)[i]
    df[, i] <- as.numeric(df[, i])

    df_sum <- df %>%
          group_by(Date) %>%
          dplyr::summarise(n = sum(eval(parse(text = var)), na.rm = TRUE))
    ggplot(data = df_sum, aes(x = Date, y = n)) +
      geom_line(color = "red") +
      geom_point(color = "orange") +
      labs(x = "Date",
           y = var,
           title = paste0("Total Case Graph for ", state_name, " | ", var)) +
      theme_economist()
    ggsave(filename = paste0("case.pdf"), 
           plot = last_plot(),
           width = 8,
           device = "pdf")
    
    df_fac_d <- df %>%
      group_by(Date, Name) %>%
      dplyr::summarise(n = sum(eval(parse(text = var)), na.rm = TRUE))
    ggplot(data = df_fac_d, aes(x = Date, y = n, group = Name, color = Name)) +
      geom_line() +
      geom_point() +
      labs(x = "Date",
           y = var,
           title = paste0("By Facility Graph for ", state_name, " | ", var)) +
      theme_economist()
    ggsave(filename = paste0("count.pdf"), 
           plot = last_plot(),
           width = 16,
           device = "pdf")
    
    pdf_combine(c("case.pdf", "count.pdf"), output = paste0("page_", i, ".pdf"))
  }
  
  
  
  eval(parse(text = paste("pdf_combine(c(", paste("'page_",
                                          6:length(colnames(df)), ".pdf'", sep = "",
                                          collapse = ","), "), output = ", paste0("'report.pdf'"),
                          ")")))
  
  pdf_combine(c("fac_count.pdf", "dup_count.pdf", paste0("report.pdf")), output = paste0(state_name, "_report.pdf"))
  
  
  
}


## General Notes -----------------------------------------------------------

## Los Angeles ------------------------------------------------------------

la_jail <- subset(ucla, Name == "LA Jail" | Name == "LOS ANGELES JAILS")

la_jail <- la_jail %>%
           arrange(Date)

la_jail$Name <- "LOS ANGELES JAILS"
write.csv(la_jail, "20.10.5_LA_Jails_COVID.csv")

state_report_og(la_jail)

## Alabama -----------------------------------------------------------------

al <- subset(ucla, State == "Alabama")

state_report(al)

## Alaska ------------------------------------------------------------------

ak <- subset(ucla, State == "Alaska")

state_report(ak)

## Arkansas ------------------------------------------------------------------

ar <- subset(ucla, State == "Arkansas")

state_report(ar)

## Arizona -------------------------------------------------------------------

az <- subset(ucla, State == "Arizona")

state_report(az)

## California (Broken) ----------------------------------------------------------

ca <- subset(ucla, State == "California" & Facility != "Jail")

state_report(ca)

## Colorado -------------------------------------

co <- subset(ucla, State == "Colorado")

state_report(co)

## Connecticut ----------------------------------

ct <- subset(ucla, State == "Connecticut")

state_report(ct)

## Delaware -------------------------------------

de <- subset(ucla, State == "Delaware")

state_report(de)

## Florida --------------------------------------

fl <- subset(ucla, State == "Florida")

state_report(fl)

## Pennsylvania ----------------------------------

pa <- subset(ucla, State == "Pennsylvania")

state_report(pa)




