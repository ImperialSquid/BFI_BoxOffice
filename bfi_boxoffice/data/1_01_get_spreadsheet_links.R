library("tidyverse")  # require rvest for scraping, magnittr for pipes, dplyr for other verbs
library("rvest")
library("polite")  # it's good to be civil :)

host = "https://www.bfi.org.uk"
session = bow(host)

first_page = "/industry-data-insights/weekend-box-office-figures"

# get all links from BFI spreadsheets landing page
links = bow(host) %>% 
  nod(first_page) %>% 
  scrape() %>% 
  html_elements("a") %>% 
  html_attrs_dfr() %>% 
  data.frame()

# some weekends have direct links here
files = links %>% 
  filter(grepl("download", href)) %>% 
  select(href)

# older weekends are split into pages for previous years
pages = links %>% 
  filter(grepl("industry-data-insights/weekend-box-office-figures", href)) %>% 
  # select(href) %>% 
  pull(href)

# print(pages)

# iter through previous years to get those spreadsheet links
for (p in pages) {
  files = session %>% 
    nod(p) %>% 
    scrape() %>% 
    html_elements("a") %>% 
    html_attrs_dfr() %>% 
    data.frame() %>% 
    filter(grepl("download", href)) %>% 
    select(href) %>% 
    bind_rows(files)
}

# there are duplicates links, see /data README
files = files %>% 
  group_by(href) %>% 
  slice_head(n = 1) %>% 
  ungroup()

# cache file URLs and set update flag for later files
updated = TRUE
withCallingHandlers(
  message = function(cnd) {
    if (grepl("Skipping", conditionMessage(cnd))){
      assign("updated", FALSE, envir = .GlobalEnv)
    }
  },
  cache("files")
)

# clean up
rm(links, session, first_page, host, p, pages)
