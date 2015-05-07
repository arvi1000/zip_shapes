library(rvest)
library(zoo)
library(stringr)

# local paths
zip_dir <- 'data/'
zip_df_fl <- 'nyc_zips.csv'
full_path <- paste0(zip_dir, zip_df_fl)

# great from file if avail, otherwise scrape
if(file.exists(full_path)) {
  zip_df <- read.csv(full_path, stringsAsFactors=FALSE)
} else {
  dir.create(zip_dir)

  # extract list of nyc zip codes to data.frame
  zip_df <- 
    html('https://www.health.ny.gov/statistics/cancer/registry/appendix/neighborhoods.htm') %>%
    html_node('table') %>% html_table(header=T, fill=T)
  
  # because of weird column layout, we have to do some rearranging
  three_cols <- zip_df[!is.na(zip_df[,3]), ] # rows with borough/neighb/zips
  two_cols <-  cbind(rep(NA, sum(is.na(zip_df[,3]))),  # rows with na/neighb/zips
                     zip_df[is.na(zip_df[,3]), 1:2])
  
  # bind together, sort, fill forward borough names
  zip_df <- rbind(three_cols, setNames(two_cols, names(three_cols)))
  zip_df <- zip_df[order(as.numeric(row.names(zip_df))),]
  zip_df[, 1] <- na.locf(zip_df[, 1])
  rm(three_cols, two_cols)
  
  # break comma delim string to single zips
  zip_list <- 
    strsplit(zip_df[,3], ',') %>%
    lapply(str_trim)
  
  # repeated indicies of zip_df, matching to zip_list
  idx_rep <-
    mapply(rep, seq(1:nrow(zip_df)), each=sapply(zip_list, length))
  
  # flatten
  zip_df <- data.frame(zip_df[unlist(idx_rep), 1:2], 
                       zip=unlist(zip_list),
                       stringsAsFactors=F)
  names(zip_df) <- tolower(names(zip_df))
  row.names(zip_df) <- 1:nrow(zip_df)
  
  # write to file
  write.csv(zip_df, full_path, row.names=F)
  
  # clean up
  rm(zip_list, idx_rep)
}

rm(zip_dir, full_path, zip_df_fl)
