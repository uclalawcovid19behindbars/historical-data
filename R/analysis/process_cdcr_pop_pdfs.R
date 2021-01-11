library(pdftools)
library(tidyverse)

# Folder containing downloaded pdfs from `get_cdcr_pop_pdfs.R`
pdf_folder <- here::here("data", "raw")

# All pdf file names
pdf_files <- list.files(pdf_folder, 
                        pattern = ".pdf")

# Function to convert text in pdf to tibble
pdf_to_table <- function(pdf_file){
  got_date <- as.Date(paste0("2020-",
                             substr(pdf_file,9,10),
                             "-",
                             substr(pdf_file,11,12)))
  
  print(got_date)
  
  got_txt <- pdf_text(paste0(pdf_folder, "/", pdf_file)) %>% 
    readr::read_lines()
  
  # Lines where data starts and ends
  start_line1 <- which(grepl("Male Institutions", got_txt)) + 1
  end_line1 <- which(grepl("Male Total", got_txt)) - 1
  
  dat_txt1 <- got_txt[start_line1:end_line1] %>% 
    str_replace_all(",","")

  # Same for female institutions
  start_line2 <- which(grepl("Female Institutions", got_txt)) + 1
  end_line2 <- which(grepl("Female Total", got_txt)) - 1
  
  dat_txt2 <- got_txt[start_line2:end_line2] %>% 
    str_replace_all(",","")

  # Convert text to tibbles
    # Male institutions
    list1 <- str_split(dat_txt1, "  ")
    dat1 <- plyr::ldply(list1, function(l){
      chars <- unlist(l)
      chars2 <- chars[which(nchar(chars) > 0)]
      return(chars2)
    })
    
    colnames(dat1) <- c("Facility", "Capacity", "Design_Capacity", "Percent_Occupied", "Staffed_Capacity")
    dat1 <- dat1 %>% 
      mutate(
        Facility_Type = "Male Institution",
        Report_Date = got_date
      )
 
    #Female institutions
    list2 <- str_split(dat_txt2, "  ")
    dat2 <- plyr::ldply(list2, function(l){
      chars <- unlist(l)
      chars2 <- chars[which(nchar(chars) > 0)]
      return(chars2)
    })
    
    colnames(dat2) <- c("Facility", "Capacity", "Design_Capacity", "Percent_Occupied", "Staffed_Capacity")
    dat2 <- dat1 %>% 
      mutate(
        Facility_Type = "Female Institution",
        Report_Date = got_date
      )
    
    return(bind_rows(dat1, dat2))
       
}

# apply function to all pdfs and return as tibble
fin_pop_dat <- bind_rows(lapply(pdf_files, pdf_to_table))  
                
saveRDS(fin_pop_dat, 
        here::here("data", "derived", "cdcr_population_ts_2020-01-11.rds"))
     