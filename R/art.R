#library(tidyverse)
#library(magrittr)
#library(numform)
#library(scales)
#library(rvest)
#library(jsonlite)
#library(httr)
#library(lubridate)

options(readr.show_col_types = FALSE)
options(warn=-1)

## ON VIEW
download.file("https://www.nga.gov/collection-search-result/jcr:content/parmain/facetcomponent/parList/collectionsearchresu.pageSize__3000.pageNumber__1.json?onview=On_View&_=1554781398824",
              paste0("nightlies/onview/",format(Sys.time(), "%Y.%m.%d"),".json"), "curl")