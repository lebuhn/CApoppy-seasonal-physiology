# load DST correction
source("analysis/climate/load_dst_correction.R", local = TRUE, chdir = FALSE)

# Calculating Mean Midday Temp and VPD

# initializing an empty data frame to contain midday climate means
midday_climate <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(midday_climate) <- c('Date', 'mean_midday_temp', 'mean_midday_rh', 'mean_midday_dew', 'mean_midday_VPD')

#initializing an empty list of datetimes
midday_datekey = list()

# picking out the sampling dates with midday data
for (i in (seq_len(nrow(atmosphere_noDST)))) {
  my_datetime = atmosphere_noDST[i,1]
  time = atmosphere_noDST[i,9]
  if (time < hms::as_hms(41400) & time >= hms::as_hms(39600)) {
    datepick = list(my_datetime)
    midday_datekey = c(midday_datekey, datepick)
  }
}

# calculate mean midday midday climate between 11am and 1pm and add it to the empty dataframe
for (datetime in midday_datekey) {
  my_day = as_date(datetime)
  my_day_string = as.character(my_day)
  datetime_plus1.5hr = datetime + hours(1) + minutes(30)
  midday_window = atmosphere_noDST[atmosphere_noDST$Time >= datetime & atmosphere_noDST$Time <= datetime_plus1.5hr,]
  midday_climate[nrow(midday_climate) + 1,] = c(my_day_string,mean(midday_window$Celsius.C.),mean(midday_window$Humidity..rh.),mean(midday_window$Dew.Point.C.),mean(midday_window$VPD))
}

# define data type for the date column
midday_climate$Date = as_date(midday_climate$Date)

# recover 3/25 and 4/15 data by modeling prior day midday VPD
midday_climate_March24 = filter(midday_climate, Date == "2025-03-24")
midday_climate_April14 = filter(midday_climate, Date == "2025-04-14")
midday_climate_priorDay = rbind(midday_climate_March24, midday_climate_April14)
midday_climate_priorDay$priorDay = 'yes'
midday_climate_priorDay$Date = midday_climate_priorDay$Date + day(1)
midday_climate$priorDay = 'no'
midday_climate = rbind(midday_climate, midday_climate_priorDay)