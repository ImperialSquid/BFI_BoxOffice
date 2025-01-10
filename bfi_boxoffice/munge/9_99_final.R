# cache datasets for future project loads in case remote hasn't changed
# (ie if preprocessing wouldn't be triggered) 
cache("box_office")
cache("bfi_origins")

# remove helper files from data loading munging
suppressWarnings(rm(files, updated))

# not neccesary, just for neatness
clear.cache(updated)
