options(readr.num_columns = 0, readr.show_types = FALSE)

required <- c("purrr","plyr","tidyverse","jsonlite","textutils","tools","lubridate","magrittr","readr")
lapply(required, require, character.only = TRUE)

flat_art <- function(data) {
  data %>%
    pull(onViewSettings) %>% 
    map_df(~ map_chr(.x, ~ replace(.x, is.null(.x), NA))) %>%
    bind_cols(data %>% select(., -onViewSettings), .) %>%
    dplyr::rename(url = `url...2`)}

art_difference <- function(last, current) {
  check <- 
    anti_join(
      select(eval(as.name(last)), c(id,title,attribution,roomTitle,url,imagepath)),
      select(eval(as.name(current)), c(id,title,attribution,roomTitle,url,imagepath)),
      by = c("id", "roomTitle")) %>%
    mutate(Status = "Removed") %>%
    bind_rows(.,
              anti_join(
                select(eval(as.name(current)), c(id,title,attribution,roomTitle,url,imagepath)),
                select(eval(as.name(last)), c(id,title,attribution,roomTitle,url,imagepath)),
                by = c("id", "roomTitle")) %>%
                mutate(Status = "Added")) %>%
    mutate(
      attribution = HTMLdecode(attribution),
      title = HTMLdecode(title),
      month = format(ymd(current), "%B"),
      year = format(ymd(current), "%Y"),
      monthyear = format(ymd(current), "%B %Y"),
      datechange = format(ymd(current), "%B %d")) %>%
    arrange(Status, roomTitle, attribution, title) %>%
    select(-id)
  if(!empty(check)) {
    write.csv(check, file = paste0("output/changes/changes.",current,".csv"), row.names=FALSE)}
}

for (i in file_path_sans_ext(list.files("nightlies/onview", pattern="*.json", include.dirs = FALSE))) {
  if(!exists(i)) {
    assign(i, flat_art(do.call("rbind.fill", lapply(fromJSON(paste0("nightlies/onview/",i,".json"))["results"], as.data.frame))))}
}

input_list <- file_path_sans_ext(list.files("nightlies/onview", pattern="*.json", include.dirs = FALSE))
for (i in seq_along(input_list)) {
  if(i>1) {
    art_difference(input_list[i-1], input_list[i])}}

art_change <- list.files("output/changes", pattern="*.csv") %>%
  map(~ read_csv(file.path("output/changes", .))) %>%
  reduce(suppressMessages(bind_rows)) %>%
  arrange(desc(year),desc(match(month, month.name)),desc(datechange),Status,roomTitle,attribution,title) %T>%
  write_json(., "output/art_change.json")

rm(i, flat_art, required, art_difference)
#rm(list=ls(pattern="change"))