TODO:
- [x] Finish processing weekends into standardised dates
- [ ] Implement getting additional data about films from OMDb (https://www.omdbapi.com/)


Files:
- 01_get_spreadsheet_links - BFI spreadsheets have links in various places, this script grabs them all into a data frame for the nect script
- 02_download_spreadsheets - This script downloads the needed spreadsheets, skipping any that already exist
- 03_compile_spreadsheets - This script compiles them all into one data frame, handling quirks and edge cases


Notes: 
- 01_get_spreadsheet_links will pick up some duplicates, specifically 2 (as of 06/12/2024)
    - file id 510 (7-19 Feb 2020) is listed twice on 2020's page
    - file id 16091 (31 Dec 2021 - 2 Jan 2022) is is listed in two locations (2021 and 2022's page)
    - Already downloaded files are skipped so this doesn't matter
- 03_compile_spreadsheets handles lots of edge cases
    - Most notably, inconsistent encoding of no %age change in gross revenue
    - Hotel Transylvania 3 also had a gross revenue with spaces one year
    - From 2021, spreadsheets started having the message "Hello to Jason Isaacs" hidden in cell R5 in white text
    - Etc etc, various small things
