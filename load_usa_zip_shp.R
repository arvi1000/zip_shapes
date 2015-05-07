## load shape files (download /unzip if not available locally)

# local paths
zip_dir <- 'download/'
zip_file <- 'cb_2013_us_zcta510_500k.zip'
shp_dir <- 'shapefiles/'

# if no shapefiles found, download and unzip them
if (!any(grepl('shp', list.files(shp_dir)))) {
  # web target
  web_dir <- 'http://www2.census.gov/geo/tiger/GENZ2013/'
  url <- paste0(web_dir, web_file)
  
  # download
  dir.create(zip_dir)
  local_zip_file <- paste0(zip_dir, web_file)
  download.file(url, destfile=local_zip_file)
  
  # unzip
  dir.create(shp_dir)
  unzip(local_zip_file, exdir=shp_dir)
  
  # clean up
  rm(web_dir, url, local_zip_file)
}

# load shapefiles
shp_layer <- 'cb_2013_us_zcta510_500k'
zip_shp <- readOGR(dsn=shp_dir, layer=shp_layer, stringsAsFactors=FALSE)
names(zip_shp@data)[1] <- 'zip' # rename 'ZCTA5CE10' to 'zip'

# clean up stray objects
rm(zip_dir, zip_file, shp_dir, shp_layer)
