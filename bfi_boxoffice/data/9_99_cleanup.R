# remove update flag from environment and cache
rm(updated)
clear.cache("updated")

# remove helper datasets from cache
clear.cache("weekend_df", "full_dataset")