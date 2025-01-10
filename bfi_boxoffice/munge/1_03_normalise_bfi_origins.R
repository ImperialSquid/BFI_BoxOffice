if (! updated) {
  cat("Files list did not change from remote, skipping...\n")
} else {
  library(countrycode)
  
   bfi_origins = box_office %>% 
     select(title, origin) %>% 
     group_by(title) %>% 
     slice(1) %>% 
     ungroup() %>% 
     # note as of 2025/01/09 - lifecycle experimental, 
     # may break in the future without notice
     tidyr::separate_longer_delim(origin, "/")
   
   fixed_countries = bfi_origins %>% 
     select(origin) %>% 
     group_by(origin) %>% 
     slice(1) %>% 
     ungroup()
   
   
   # attempt to use country codes to convert to a name
   
   # compare against upper and title case form
   conv_funcs = c(u = ~str_to_upper(.x),
                  t = ~str_to_title(.x))
   
   # compare against multiple country code forms
   # TODO - find a way to do this dynamically with a list/for loop/etc
   code_funcs = c(iso3c = ~ countrycode(.x,
                                        origin = "iso3c",
                                        destination = "country.name",
                                        warn = F),
                  iso2c = ~ countrycode(.x,
                                        origin = "iso2c",
                                        destination = "country.name",
                                        warn = F),
                  wb = ~ countrycode(.x,
                                     origin = "wb",
                                     destination = "country.name",
                                     warn = F),
                  country.name = ~ countrycode(.x,
                                               origin = "country.name",
                                               destination = "country.name",
                                               warn = F),
                  cowc = ~ countrycode(.x,
                                       origin = "cowc",
                                       destination = "country.name",
                                       warn = F),
                  unhcr = ~ countrycode(.x,
                                        origin = "unhcr",
                                        destination = "country.name",
                                        warn = F),
                  ioc = ~ countrycode(.x,
                                        origin = "ioc",
                                        destination = "country.name",
                                        warn = F))
   
   fixed_countries = fixed_countries %>% 
     mutate(across(origin,
                   .fns = conv_funcs,
                   .names = "{.fn}")) %>% 
     mutate(across(! origin,
                   .fns = code_funcs,
                   .names = "{.col}_{.fn}")) %>% 
     select(- c(u, t)) %>% 
     # take the first non NA value among methods tried
     mutate(fixed = coalesce(!!! select(., contains("_")))) %>% 
     select(origin, fixed)
   
   # manual fixes where the above method doesn't work
   manual_map = c("Cnd" = "Canada",
                  "Dom Rep" = "Dominican Republic",
                  "Egp" = "Egypt",
                  "Ghn" = "Ghana",
                  "Hrt" = "Croatia", # looks odd but confirmed against the movie it came from
                  "Ira" = "Iran",
                  "Mgr" = "Hungary",
                  "Mrc" = NA, # source: Damascus Cover (2018), no good matches
                  "S Kor" = "South Korea",
                  "S. Kor" = "South Korea",
                  "S.Kor" = "South Korea",
                  "Sga" = NA, # source: Drift (2023), no good matches
                  "Sgn" = "Singapore",
                  "Skor" = "South Korea",
                  "UISA" = "United States",
                  "Urg" = "Uruguay",
                  "Viet" = "Vietnam",
                  # previous method incorrectly guesses other counties for the below
                  "Ngr" = "Nigeria",
                  "Chi" = "China")
   
   fixed_countries = fixed_countries %>% 
     mutate(fixed = ifelse(origin %in% names(manual_map),
                           manual_map[origin],
                           fixed))
   
   bfi_origins = bfi_origins %>% 
     full_join(fixed_countries, by = c("origin")) %>% 
     select(! origin)
   
   box_office = box_office %>% 
     select(! origin)
   
   # cleanup
   rm(code_funcs, conv_funcs, fixed_countries, manual_map)
   detach("package:countrycode")
}
