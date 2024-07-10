options(warn=-1)

## GH-NGA-Constituents
download.file("https://raw.githubusercontent.com/NationalGalleryOfArt/opendata/main/data/objects.csv",
              paste0("monthly/gh-constituents/",format(Sys.time(), "%Y.%m"),".csv"), "curl")
