wide_origins = bfi_origins %>%
  mutate(fixed = gsub(" ", "_", fixed)) %>% 
  group_by(fixed) %>% 
  mutate(row = row_number()) %>% 
  mutate(temp = 1:n()) %>% 
  pivot_wider(names_from = fixed,
              values_from = temp,
              names_prefix = "origin_") %>% 
  mutate(across(starts_with("origin_"),
                .fns = ~ ifelse(is.na(.x),
                                F, T))) %>% 
  select(! row) %>% 
  group_by(title) %>% 
  summarise(across(starts_with("origin_"),
                   .fns = any))
