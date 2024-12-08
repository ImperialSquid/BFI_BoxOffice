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

already_exist = 0
downloaded = c()
errors = c()

# iter and download each file (can take a _while_)
for (index in 1:length(files_list)) {
  if (file.exists(paste0(download_dir,
                         "/spreadsheets/",
                         files_ids[index]))) { 
    already_exist = already_exist + 1
  } else {
    tryCatch(
      {
        session %>% 
          nod(files_list[index]) %>% 
          rip(path = paste0(download_dir,
                            "/spreadsheets"),
              destfile = files_ids[index])
        # don't specify file type, some are xls, some are xlsx _sigh_
        
        downloaded = append(downloaded, files_ids[i])
      },
      error = function(cond) {
        errors = append(errors, files_ids[i])
      }
    )
  }
}

cat(paste0("Found ", already_exist, " files already exist.\n",
           "Downloaded ", length(downloaded)," new files: ",
           paste(downloaded,sep = ", "), "\n",
           "Encountered ", length(errors)," errors: ",
           paste(errors,sep = ", "), "\n"))

# clean up
rm(host, session, files, files_list, files_ids, download_dir, index, downloaded, errors, already_exist)
