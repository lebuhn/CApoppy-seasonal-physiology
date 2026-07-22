# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# initializing the 'no DST' data frame and defining delayed DST
atmosphere_noDST = atmosphere

# DST starts after March 11 9:38am in the atmosphere dataframe due to 
# a delayed timestamp update.
delayed_DST = ymd_hms("2025-3-11T9:38:00") 

# daylight savings correction.
for (i in (seq_len(nrow(atmosphere_noDST)))) {
  my_datetime = atmosphere_noDST[i,1]
  if (my_datetime > delayed_DST) {
    atmosphere_noDST[i,1] = my_datetime - hours(1)
    atmosphere_noDST[i,9] = hms::as_hms(my_datetime - hours(1))
  }
}

# push this further back in the control flow to the python preprocess?

# combine atmosphere_noDST with atmosphere_gh

# write processed atmosphere data frame to csv in data/processed filepath