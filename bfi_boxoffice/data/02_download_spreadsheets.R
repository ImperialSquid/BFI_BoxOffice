library("tidyverse")
library("polite")

host = files$href[1]
session = bow(host)

# file URLs from previous step
files_list = files %>% 
  pull(href)
files_ids = files %>% 
  mutate(id_ = gsub(".*?(\\d+).*", "\\1", href, perl = TRUE)) %>%
  pull(id_)

# download to /data dir (where this script is)
download_dir = paste0(dirname(rstudioapi::getActiveDocumentContext()$path),
                      "/../data")  # force go up to project root and down to data again

# iter and download each file (can take a _while_)
for (index in 1:length(files_list)) {
  print(paste0("Downloading spreadsheet ", index, " of ", length(files_list)))
  
  if (file.exists(paste0(download_dir,
                         "/spreadsheets/",
                         files_ids[index]))) { 
    print("Spreadsheet already exists")
  } else {
    session %>% 
      nod(files_list[index]) %>% 
      rip(path = paste0(download_dir,
                        "/spreadsheets"),
          destfile = files_ids[index])
    print("Success!")
    # don't specify file type, some are xls, some are xlsx _sigh_
  }
}

# clean up
rm(host, session, files, files_list, files_ids, download_dir, index)
