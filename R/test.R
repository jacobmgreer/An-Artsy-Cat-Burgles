options(readr.num_columns = 0, readr.show_types = FALSE)

required <- c("purrr","plyr","tidyverse","jsonlite","textutils","tools","lubridate","magrittr","readr")
lapply(required, require, character.only = TRUE)

flat_art <- function(data) {
  data %>%
    pull(onViewSettings) %>% 
    map_df(~ map_chr(.x, ~ replace(.x, is.null(.x), NA))) %>%
    bind_cols(data %>% select(., -onViewSettings), .) %>%
    dplyr::rename(url = url...2)}

for (i in file_path_sans_ext(list.files("nightlies/onview", pattern="*.json", include.dirs = FALSE))) {
  if(!exists(i)) {
    assign(paste0("art.",i), flat_art(do.call("rbind.fill", lapply(fromJSON(paste0("nightlies/onview/",i,".json"))["results"], as.data.frame))))}
}