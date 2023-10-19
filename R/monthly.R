options(warn=-1)

## GH-NGA-Constituents
download.file("https://github.com/NationalGalleryOfArt/opendata/raw/main/data/objects.csv",
              paste0("monthly/gh-constituents/",format(Sys.time(), "%Y.%m"),".csv"), "curl")
