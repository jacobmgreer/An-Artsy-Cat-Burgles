library(tidyverse)
library(jsonlite)

Sys.setenv(TZ="America/Los_Angeles")

options(
  readr.num_columns = 0, 
  readr.show_col_types = FALSE,
  warn = -1)

flat_art <- function(data) {
  data %>%
    pull(onViewSettings) %>% 
    purrr::map_df(~ purrr::map_chr(.x, ~ replace(.x, is.null(.x), NA))) %>%
    dplyr::bind_cols(data %>% select(., -onViewSettings), .)
}

dir.create("nightlies", showWarnings = FALSE)
dir.create("nightlies/onview", showWarnings = FALSE)
dir.create(paste("nightly/onview/", format(Sys.time(), "%Y"), showWarnings = FALSE))
dir.create("nightlies/gh-objects", showWarnings = FALSE)
dir.create(paste("nightly/gh-objects/", format(Sys.time(), "%Y"), showWarnings = FALSE))

## ON VIEW
download.file("https://www.nga.gov/collection-search-result/jcr:content/parmain/facetcomponent/parList/collectionsearchresu.pageSize__3000.pageNumber__1.json?onview=On_View&_=1554781398824",
              paste0("nightlies/onview/", format(Sys.time(), "%Y.%m.%d"), ".json"), "curl")

onview <- 
  list.files("nightlies/onview", full.names = TRUE) %>% 
  as.tibble() %>% 
  slice(1) %>% 
  pull(value)

onview <- jsonlite::fromJSON(onview)["results"][[1]]

saveRDS(onview, file = paste0("RData/onview/", format(Sys.time(), "%Y"), "/", format(Sys.time(), "%Y.%m.%d"), ".rds"))

## GH-NGA-Objects
download.file("https://raw.githubusercontent.com/NationalGalleryOfArt/opendata/main/data/objects.csv",
              paste0("nightlies/gh-objects/", format(Sys.time(), "%Y.%m.%d"), ".csv"), "curl")

gh_objects <-
  list.files("nightlies/gh-objects", full.names = TRUE) %>% 
  as.tibble() %>% 
  slice(1) %>% 
  pull(value) %>%
  read_csv(.) %>%
  reframe(
    objectid, accessionnum, locationid, title, displaydate, beginyear, endyear,
    visualbrowsertimespan, medium, dimensions, inscription, markings,
    attributioninverted, attribution, creditline, classification,
    subclassification, parentid, portfolio, series, volume, watermarks,
    lastdetectedmodification, wikidataid
  )

saveRDS(gh_objects, file = paste0("RData/gh-objects/", format(Sys.time(), "%Y"), "/", format(Sys.time(), "%Y.%m.%d"), ".rds"))

unlink("nightlies", recursive = TRUE, force = TRUE)