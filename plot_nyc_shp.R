setwd('~/Documents/personal/zip_shapes')

library(rgdal)
library(rgeos)
library(ggplot2)

# load shapefiles (download from census.gov and unzip if necessary)
source('load_usa_zip_shp.R') 

# scrape/load list of nyc zips
source('scrape_nyc_zips.R')

# subset of nyc zip shapefiles
nyc_shp <- zip_shp[zip_shp@data$zip %in% zip_df$zip, ]

# # alternative subset method: crop inside lat/lon boundary
#  poly_bounds <- 
#   sapply(zip_shp@polygons,
#          function(x) {
#            coords <- x@Polygons[[1]]@coords
#            return(c(max_lon=max(coords[,1]), min_lon=min(coords[,1]), 
#                     max_lat=max(coords[,2]), min_lat=min(coords[,2])))
#        })
# poly_bounds <- as.data.frame(t(poly_bounds))
# 
# # subset to nyc area
# nyc_select_idx <- with(poly_bounds, 
#                        min_lon >= -74.3 & max_lon <= -73.5 &
#                          min_lat >= 40.4 & max_lat <= 50)
# 
# nyc_shp <- zip_shp[nyc_select_idx,]

# create gg-friendly data.frame
nyc_plot <- fortify(nyc_shp, region='GEOID10')
nyc_plot <- merge(nyc_plot, nyc_shp@data, by.x='id', by.y='GEOID10')
nyc_plot <- merge(nyc_plot, zip_df, by='zip')

# blank theme for map
theme_nada <- function() {
  theme_classic() + 
    theme(axis.text = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank())
}

# make a plot (colored by borough, for now)
ggplot(nyc_plot, aes(x=long, y=lat, order=order, group=group)) +
  geom_polygon(aes(fill=borough)) +
  coord_map() +
  theme_nada()
