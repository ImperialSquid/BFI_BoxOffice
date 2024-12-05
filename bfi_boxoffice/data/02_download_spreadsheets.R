library("tidyverse")
library("polite")

host = files$href[1]
session = bow(host)

# file URLs from previous step
files_list = files %>% pull(href)

# download to /data dir (where this script is)
download_dir = paste0(dirname(rstudioapi::getActiveDocumentContext()$path),
                      "/../data")  # force go up to project root and down to data again

# iter and download each file (can take a _while_)
for (index in 1:length(files_list)) {
  print(paste0("Downloading spreadsheet ", index, " of ", length(files_list)))
  
  session %>% 
    nod(files_list[index]) %>% 
    rip(path = paste0(download_dir,
                      "/spreadsheets"),
        destfile = paste0("spreadsheet_", 
                          str_pad(index, 3, pad = "0")))  
  # don't specify file type, some are xls, some are xlsx _sigh_
}

# clean up
rm(host, session, files_list, download_dir, index)
