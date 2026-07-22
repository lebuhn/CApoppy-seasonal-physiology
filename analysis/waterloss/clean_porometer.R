# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# filtering out empty chamber measurements
porometer = filter(porometer_noise,location!='B')

# identifying number of measurements less than 0.
# this is unpaired data, so the number of rows should be greater than the final output.
nrow(porometer)
porometer_less_than_zero = filter(porometer, gsw < 0)
nrow(porometer_less_than_zero)
nrow(filter(porometer_less_than_zero, Petal.side == 'bottom'))
nrow(filter(porometer_less_than_zero, Petal.side == 'top'))

# zeroing out adaxial and abaxial measurements that were less than 0
porometer$gsw = replace(porometer$gsw, porometer$gsw < 0, 0)

# formatting the dates consistently
porometer <- porometer %>% 
  mutate(Date = parse_date_time(Date, 
                                orders = c("mdy", "Ymd")))

# filter porometer by petal side
gsw_ab = filter(porometer,Petal.side=="bottom")
colnames(gsw_ab)[7] <- 'gsw_bottom'
nrow(gsw_ab)
gsw_ad = filter(porometer,Petal.side=="top")
colnames(gsw_ad)[7] <- 'gsw_top'
nrow(gsw_ad)

# merging the top and bottom petal gsw to get total surface conductance
# used the time stamp for the abaxial measurement, since it was usually taken first.
# this removes 26 unpaired measurements
gsw_ab_select = gsw_ab %>% select('Time', 'Date', 'remark', 'Sample', 'location', 'gsw_bottom', 'Tref', 'plant')
gsw_ad_select = gsw_ad %>% select('Date', 'remark', 'Sample', 'gsw_top', 'plant')
porometer_gsw_total = NULL
porometer_gsw_total = merge(gsw_ab_select, gsw_ad_select, by = c("Date","remark","Sample","plant"))
porometer_gsw_total = porometer_gsw_total %>% mutate(gswTotal = gsw_bottom + gsw_top)

# comment out line 16 to report the number of less than zero measurements.
# this should equal 0, but will equal 442 if line 16 is removed.
nrow(filter(porometer_gsw_total, gsw_bottom < 0)) + nrow(filter(porometer_gsw_total, gsw_top < 0))

# total valid adaxial and abaxial measurements is the number of rows multiplied by 2
2*nrow(porometer_gsw_total)

# porometer timestamp is in pacific standard time, never updated to daylight savings. 
# Other than that consideration, porometer measurements were only a few minutes ahead from my phone clock. No further adjustments are necessary.

# converting date and time columns into a datetime column
porometer_gsw_total$Datetime = ymd_hms(paste(porometer_gsw_total$Date, porometer_gsw_total$Time))

# filtering out zero values and values greater than 0.025 mol per meter squared per second.
nrow(porometer_gsw_total)
porometer_gsw_total = filter(porometer_gsw_total,gswTotal<0.025)
nrow(porometer_gsw_total)
porometer_gsw_total = filter(porometer_gsw_total,gswTotal!=0)
nrow(porometer_gsw_total)

# changing units to mmol
porometer_gsw_total$gswTotal_mmol = porometer_gsw_total$gswTotal*1000

# renaming 'remark' to 'flower_replicate'
names(porometer_gsw_total)[names(porometer_gsw_total) == 'remark'] <- 'flower_replicate'

# exporting out porometer_gsw_total as a csv file
write.csv(porometer_gsw_total, "data/processed/porometer_gsw_total.csv", row.names=FALSE)

# separating greenhouse measurements from field measurments
porometer_gsw_total_gh = filter(porometer_gsw_total,location=='SFSU greenhouse')
porometer_gsw_total = filter(porometer_gsw_total,location=='Mount Diablo')

# defining the mean for all surface conductance measurements in the greenhouse
gs_mean_gh = round(mean(porometer_gsw_total_gh$gswTotal_mmol),2)

# defining the standard deviation for all surface conductance measurements in the greenhouse
gs_sd_gh = round(sd(porometer_gsw_total_gh$gswTotal_mmol),2)

# Mean total gs at Mount Diablo
gs_mean_MtD = round(mean(porometer_gsw_total$gswTotal_mmol),2)

# Total gs standard deviation at Mount Diablo
gs_sd_MtD = round(sd(porometer_gsw_total$gswTotal_mmol),2)

# Defining Repeated and Non-repeated Measurements

# defining the flagged plants
flaggedPlants = c("#1","#2","#3","#4","#5","#6","#7","#8","#9","#10","#11","#12","#13","#14","#15","#16","#17","#18","#19","#20","#42","#43","#44","#45","#46","#47","#48","#49","#50","#51","#52","#53")

# making an empty column in the Mount Diablo gsw data frame
porometer_gsw_total$repeatMeasurement = c('')

# marking repeat measurements into the empty column
for (i in (seq_len(nrow(porometer_gsw_total)))) {
  if (porometer_gsw_total$plant[i] %in% flaggedPlants) {
    porometer_gsw_total$repeatMeasurement[i] = 'yes'
  } else {
    porometer_gsw_total$repeatMeasurement[i] = 'no'
  }
}

# Making the Mount Diablo Week Column

# extracting petal sampling weeks
weeks_MtDiablo = petal_MtDiablo[ , c('Date', 'week')] %>%
  distinct(.keep_all = TRUE)

# defining sampling weeks missing from the petal collection data frame
missing_Dates <- c('4/8/2025', '4/22/2025', '6/17/2025')
missing_Dates = as.Date(missing_Dates, "%m/%d/%Y")
class(missing_Dates)
missing_weeks <- c(7, 9, 17)
missing_weeks_MtDiablo <- data.frame(Date = missing_Dates, week = missing_weeks)

# combining to get a data frame that contains every week I visited Mount Diablo
weeks_MtDiablo = rbind(weeks_MtDiablo, missing_weeks_MtDiablo) %>% 
  arrange(week)

# defining the data type for the Date column
porometer_gsw_total$Date = as.Date(porometer_gsw_total$Date, "%m/%d/%Y")

# merging the week data frame with the porometer data frame by the Date key
porometer_gsw_total = merge(porometer_gsw_total, weeks_MtDiablo, by = c('Date'))

# mean, standard deviation, and median of Mount Diablo measurements.
mean(porometer_gsw_total$gswTotal)
sd(porometer_gsw_total$gswTotal)
median(porometer_gsw_total$gswTotal)