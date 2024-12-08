library("readxl")

if(exists("full_dataset")) {
  cat("Variable `full_dataset` already exists, skipping data script...\n")
} else {
  spreadsheet_dir = paste0(dirname(rstudioapi::getActiveDocumentContext()$path),
                           "/../data/spreadsheets")
  
  sheets = list.files(spreadsheet_dir)
  
  full_dataset = tibble(
    rank = numeric(),
    title = character(),
    origin = character(),
    weekend = character(),
    wknd_gross = numeric(),
    distributor = character(),
    perc_change = numeric(),
    wks_release = numeric(),
    cinemas = numeric(),
    site_avg = numeric(),
    total_gross = numeric(),
  )
  
  for (sheet_i in 1:length(sheets)) {
    sheet = sheets[sheet_i]
    
    # sheets are not well formatted enough to use col names
    temp = read_excel(path = paste0(spreadsheet_dir, "/", sheet),
                      col_names = FALSE,
                      .name_repair = "unique_quiet")
    
    # print(temp)
    
    # weekend placement moves between versions
    if (! is.na(temp$...1[1])) {
      weekend = temp$...1[1]
    } else if (! is.na(temp$...2[1])) {
      weekend = temp$...2[1]
    } else {
      weekend = NA
      
      warn(paste0("date not found in ", sheet))
    }
    
    full_dataset = temp %>%
      filter(row_number() > 2) %>%   # exclude date and table header row
      filter(!is.na(...1)) %>%  # all rows with films have ranks in the first col
      filter(!str_detect(...1, "#")) %>%   # some spreadsheets have a random hash at the bottom
      filter(!str_detect(...1, "N/A")) %>%   # some categories are empty
      rename(rank = ...1,
             title = ...2,
             origin = ...3,
             wknd_gross = ...4,
             distributor = ...5,
             perc_change = ...6,
             wks_release = ...7,
             cinemas = ...8,
             site_avg = ...9,
             total_gross = ...10) %>%
      # no change is sometimes encoded as any of 
      # "-", " ", <nbsp>, "#####", "", or NA
      mutate(perc_change = if_else(str_detect(perc_change, "^(-| |\u00A0|#####)*$") | is.na(perc_change),
                                   "0", 
                                   perc_change)) %>% 
      # in 2-4/11/2018, Hotel Transylvania 3 has a total gross with spaces in it
      mutate(total_gross = str_extract(total_gross, "\\d*")) %>% 
      mutate(rank = as.numeric(rank),
             wknd_gross = as.numeric(wknd_gross),
             perc_change = as.numeric(perc_change),
             wks_release = as.numeric(wks_release),
             cinemas = as.numeric(cinemas),
             site_avg = as.numeric(site_avg),
             total_gross = as.numeric(total_gross)) %>% 
      mutate(weekend = weekend) %>%  # TODO: weekend processing
      select(! starts_with("...")) %>% 
      bind_rows(full_dataset)
  }
  
  cache("full_dataset")
  
  rm(spreadsheet_dir, sheets, sheet_i, sheet, temp, weekend)
}
