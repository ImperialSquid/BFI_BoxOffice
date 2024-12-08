library(lubridate)

if(exists("boxoffice")) {
  cat("Variable `boxoffice` already exists, skipping data script...\n")
} else {
  # preprocess dates first to save a lot of repeated regex matching
  weekend_df = full_dataset %>%
    group_by(weekend) %>% 
    slice_head(n = 1) %>%
    ungroup() %>% 
    select(weekend) %>% 
    mutate(form = case_when(str_detect(weekend, "^BFI Weekend Box Office \\d{2}/\\d{2}/\\d{4} - \\d{2}/\\d{2}/\\d{4}$") ~ 1,
                            str_detect(weekend, "^BFI: Weekend \\d{1,2}\\w{2}-\\d{1,2}\\w{2}\\s+\\w+ \\d{4} UK box office report$") ~ 2,
                            str_detect(weekend, "^BFI: Weekend \\d{1,2}\\w{2} \\w+\\s?-\\s?\\d{1,2}\\w{2} \\w+ \\d{4} UK box office report$") ~ 3,
                            str_detect(weekend, "^BFI: Weekend \\d{1,2}\\s?-\\s?\\d{1,2}\\s+\\w+ \\d{4} UK box office report$") ~ 4,
                            str_detect(weekend, "^BFI: Weekend \\d{1,2} \\w+ - \\d{1,2} \\w+ \\d{4} UK box office report$") ~ 5,
                            TRUE ~ 0)) %>%
    rowwise() %>%  # str_match needs to be rowwise or it'll try to return results for everything
    mutate(year = case_when(form == 1 ~ str_match(weekend, "^BFI Weekend Box Office \\d{2}/\\d{2}/(\\d{4}) - \\d{2}/\\d{2}/\\d{4}$")[[2]],
                            form == 2 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\w{2}-\\d{1,2}\\w{2}\\s+\\w+ (\\d{4}) UK box office report$")[[2]],
                            form == 3 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\w{2} \\w+\\s?-\\s?\\d{1,2}\\w{2} \\w+ (\\d{4}) UK box office report$")[[2]],
                            form == 4 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\s?-\\s?\\d{1,2}\\s+\\w+ (\\d{4}) UK box office report$")[[2]],
                            form == 5 ~ str_match(weekend, "^BFI: Weekend \\d{1,2} \\w+ - \\d{1,2} \\w+ (\\d{4}) UK box office report$")[[2]])) %>%
    mutate(year = as.numeric(year)) %>% 
    mutate(month = case_when(form == 1 ~ str_match(weekend, "^BFI Weekend Box Office \\d{2}/(\\d{2})/\\d{4} - \\d{2}/\\d{2}/\\d{4}$")[[2]],
                             form == 2 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\w{2}-\\d{1,2}\\w{2}\\s+(\\w+) \\d{4} UK box office report$")[[2]],
                             form == 3 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\w{2} (\\w+)\\s?-\\s?\\d{1,2}\\w{2} \\w+ \\d{4} UK box office report$")[[2]],
                             form == 4 ~ str_match(weekend, "^BFI: Weekend \\d{1,2}\\s?-\\s?\\d{1,2}\\s+(\\w+) \\d{4} UK box office report$")[[2]],
                             form == 5 ~ str_match(weekend, "^BFI: Weekend \\d{1,2} (\\w+) - \\d{1,2} \\w+ \\d{4} UK box office report$")[[2]])) %>%
    mutate(month = case_when(form > 1 ~ match(month, month.name, nomatch = 0)[1] + match(month, month.abb, nomatch = 0)[1],
                               .default = suppressWarnings(as.numeric(month)))) %>%
    mutate(day = case_when(form == 1 ~ str_match(weekend, "^BFI Weekend Box Office (\\d{2})/\\d{2}/\\d{4} - \\d{2}/\\d{2}/\\d{4}$")[[2]],
                           form == 2 ~ str_match(weekend, "^BFI: Weekend (\\d{1,2})\\w{2}-\\d{1,2}\\w{2}\\s+\\w+ \\d{4} UK box office report$")[[2]],
                           form == 3 ~ str_match(weekend, "^BFI: Weekend (\\d{1,2})\\w{2} \\w+\\s?-\\s?\\d{1,2}\\w{2} \\w+ \\d{4} UK box office report$")[[2]],
                           form == 4 ~ str_match(weekend, "^BFI: Weekend (\\d{1,2})\\s?-\\s?\\d{1,2}\\s+\\w+ \\d{4} UK box office report$")[[2]],
                           form == 5 ~ str_match(weekend, "^BFI: Weekend (\\d{1,2}) \\w+ - \\d{1,2} \\w+ \\d{4} UK box office report$")[[2]])) %>% 
    mutate(day = as.numeric(day)) %>% 
    mutate(weekend_clean = make_date(year = year,
                                     month = month,
                                     day = day)) %>% 
    select(! c(form, year, month, day))
  
  boxoffice = full_dataset %>% 
    full_join(weekend_df, by = "weekend") %>% 
    mutate(weekend = weekend_clean) %>% 
    select(! weekend_clean)
  
  cache("boxoffice")
  cache("weekend_df")
  
  rm(weekend_df, full_dataset)
}

# Dates in the spreadsheets are written in a few "forms": (note there's a lot of edge cases for extra spaces not written here)
#   BFI Weekend Box Office DD/MM/YYYY - DD/MM/YYYY                  - 1
#   BFI: Weekend DDth-DDth mmmmm YYYY UK box office report          - 2
#   BFI: Weekend DDth mmmmm-DDth mmmmm YYYY UK box office report    - 3
#   BFI: Weekend DD-DD mmmmm YYYY UK box office report              - 4
#   BFI: Weekend DD mmmmm - DD mmmmm YYYY UK box office report      - 5