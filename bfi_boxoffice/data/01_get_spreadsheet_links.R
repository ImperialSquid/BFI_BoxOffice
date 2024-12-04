library("tidyverse")  # require rvest for scraping, magnittr for pipes, dplyr for other verbs
library("polite")  # it's good to be civil :)


host = "https://www.bfi.org.uk"
session = bow(host)

first_page = "/industry-data-insights/weekend-box-office-figures"

# get all links from BFI spreadsheets landing page
links = bow(host) %>% 
  nod(first_page) %>% 
  scrape() %>% 
  rvest::html_elements("a") %>% 
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
    rvest::html_elements("a") %>% 
    html_attrs_dfr() %>% 
    data.frame() %>% 
    filter(grepl("download", href)) %>% 
    select(href) %>% 
    bind_rows(files)
}

# cache file URLs
cache("files")

# clean up
rm(links, session, first_page, host, p, pages)
