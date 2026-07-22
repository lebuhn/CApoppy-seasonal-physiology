# load data and the DST correction
source("analysis/climate/load_dst_correction.R", local = TRUE, chdir = FALSE)

# Time Zone Management

# removing handheld sensor data from atmosphere_noDST
atmosphere_UTC = filter(atmosphere_noDST, Comments != 'Vaisala hand-held')

# adding UTC timestamp column
atmosphere_UTC$UTC = atmosphere_UTC$Time + hours(8)

# adding a UTC date column
atmosphere_UTC$UTC_Date = as_date(atmosphere_UTC$UTC)

# adding a PRISM timestamp column
atmosphere_UTC$PRISM_timestamp = atmosphere_UTC$UTC + hours(12)

# adding a PRISM date column
atmosphere_UTC$PRISM_Date = as_date(atmosphere_UTC$PRISM_timestamp)

# converting to character
atmosphere_UTC$UTC_Date = as.character(atmosphere_UTC$UTC_Date)
atmosphere_UTC$PRISM_Date = as.character(atmosphere_UTC$PRISM_Date)

# filtering out incomplete PRISM days
atmosphere_UTC = subset(atmosphere_UTC, !(PRISM_Date %in% c('2025-03-05','2025-03-26','2025-04-09','2025-04-16','2025-04-23','2025-07-03')))

# VPD Regression

# calculating VPD daily mean and standard deviation from the EZlog data
UTC_VPD_mean <- atmosphere_UTC %>%
  group_by(PRISM_Date) %>%
  get_summary_stats(VPD, type = c("full"))

# merging by date
UTC_VPD_mean$Date = UTC_VPD_mean$PRISM_Date
prism_UTC_merge = merge(prism, UTC_VPD_mean, by = c("Date"), all.x = TRUE)

# converting units
prism_UTC_merge$vpdmax..kPa. = 0.1 * prism_UTC_merge$vpdmax..hPa.
prism_UTC_merge$vpdmin..kPa. = 0.1 * prism_UTC_merge$vpdmin..hPa.

# defining PRISM VPD mean
prism_UTC_merge$vpdmean..kPa. = (prism_UTC_merge$vpdmax..kPa. + prism_UTC_merge$vpdmin..kPa)/2

# defining the columns to statistical min and max
names(prism_UTC_merge)[names(prism_UTC_merge) == 'min'] <- 'EZlog_vpdmin'
names(prism_UTC_merge)[names(prism_UTC_merge) == 'max'] <- 'EZlog_vpdmax'

# used a shorter timespan for the model, where PRISM data is more accurate
prism_vpd_model_data = filter(prism_UTC_merge, Date < mdy('4/24/2025'))

# mean VPD linear model and r-squared
vpdmean_lm = (lm(mean~vpdmean..kPa., data=prism_vpd_model_data))
vpdmean_R2 = round(rsq(vpdmean_lm), 2)

# max VPD linear model and r-squared
vpdmax_lm = (lm(EZlog_vpdmax~vpdmax..kPa., data=prism_vpd_model_data))
vpdmax_R2 = round(rsq(vpdmax_lm), 2)

# min VPD linear model and r-squared
vpd_min_lm = (lm(EZlog_vpdmin~vpdmin..kPa., data=prism_UTC_merge))
vpdmin_R2 = round(rsq(vpd_min_lm), 2)

# calculating values using the linear models. Used mean and max values before April 24.
# Used model 2 for vpdmin, restricting data to before April 24 makes R square too low.
prism_UTC_merge$model2_vpdmin = (0.65510 * prism_UTC_merge$vpdmin..kPa.) + 0.05115
prism_UTC_merge$model_vpdmean = (1.34005 * prism_UTC_merge$vpdmean..kPa.) - 0.07902
prism_UTC_merge$model_vpdmax = (2.1405 * prism_UTC_merge$vpdmax..kPa.) - 0.2163

# Temperature Regression

# calculating temperature daily mean and standard deviation from the EZlog data
UTC_temp_mean <- atmosphere_UTC %>%
  group_by(PRISM_Date) %>%
  get_summary_stats(Celsius.C., type = "full")

# merging by date
UTC_temp_mean$Date = UTC_temp_mean$PRISM_Date
prism_UTC_temp_merge = merge(prism, UTC_temp_mean, by = c("Date"), all.x = TRUE)

# defining the columns to statistical min and max
names(prism_UTC_temp_merge)[names(prism_UTC_temp_merge) == 'min'] <- 'EZlog_tmin'
names(prism_UTC_temp_merge)[names(prism_UTC_temp_merge) == 'max'] <- 'EZlog_tmax'

# used a shorter timespan for the model, where PRISM data is more accurate
prism_temp_model_data = filter(prism_UTC_temp_merge, Date < mdy('4/24/2025'))

# mean temperature linear model and r-squared
tmean_lm = (lm(mean~tmean..degrees.C., data=prism_temp_model_data))
tmean_R2 = round(rsq(tmean_lm), 2)

# max temperature linear model and r-squared
tmax_lm = (lm(EZlog_tmax~tmax..degrees.C., data=prism_temp_model_data))
tmax_R2 = round(rsq(tmax_lm), 2)

# min temperature linear model and r-squared
tmin_lm = (lm(EZlog_tmin~tmin..degrees.C., data=prism_temp_model_data))
tmin_R2 = round(rsq(tmin_lm), 2)

# calculating values using the linear models. The first model only used data before April 24.
# the second model used all data, including after April 24.
prism_UTC_temp_merge$model_tmin = (0.6780 * prism_UTC_temp_merge$tmin..degrees.C.) + 0.4402
prism_UTC_temp_merge$model_tmean = (1.10437 * prism_UTC_temp_merge$tmean..degrees.C.) + 0.08957
prism_UTC_temp_merge$model_tmax = (1.4160 * prism_UTC_temp_merge$tmax..degrees.C.) + 0.3717

# Graph

# define vectors that contain VPD data for the graph
PRISM = prism_UTC_merge$vpdmin..kPa.
EZ_log = prism_UTC_merge$EZlog_vpdmin
Date = prism_UTC_merge$Date

# combine vectors into a data frame, define variable in 'statistic' column
vpdmin = data.frame(Date, PRISM, EZ_log)
vpdmin$statistic = 'min'

# repeat above, but for other stats
PRISM = prism_vpd_model_data$vpdmean..kPa.
EZ_log = prism_vpd_model_data$mean
Date = prism_vpd_model_data$Date
vpdmean = data.frame(Date, PRISM, EZ_log)
vpdmean$statistic = 'mean'

# repeat for other stats
PRISM = prism_vpd_model_data$vpdmax..kPa.
EZ_log = prism_vpd_model_data$EZlog_vpdmax
Date = prism_vpd_model_data$Date
vpdmax = data.frame(Date, PRISM, EZ_log)
vpdmax$statistic = 'max'

# merge data frames
vpd_df = merge(vpdmean, vpdmax, by = c('Date', 'PRISM', 'EZ_log', 'statistic'), all = TRUE)
vpd_df = merge(vpd_df, vpdmin, by = c('Date', 'PRISM', 'EZ_log', 'statistic'), all = TRUE)

# define vectors and data frame that contain temperature data for the graph
PRISM = prism_temp_model_data$tmin..degrees.C.
EZ_log = prism_temp_model_data$EZlog_tmin
Date = prism_temp_model_data$Date
tmin = data.frame(Date, PRISM, EZ_log)
tmin$statistic = 'min'

# repeat above, but for other stats
PRISM = prism_temp_model_data$tmean..degrees.C.
EZ_log = prism_temp_model_data$mean
Date = prism_temp_model_data$Date
tmean = data.frame(Date, PRISM, EZ_log)
tmean$statistic = 'mean'

# repeat for other stats
PRISM = prism_temp_model_data$tmax..degrees.C.
EZ_log = prism_temp_model_data$EZlog_tmax
Date = prism_temp_model_data$Date
tmax = data.frame(Date, PRISM, EZ_log)
tmax$statistic = 'max'

# merge data frames
t_df = merge(tmean, tmax, by = c('Date', 'PRISM', 'EZ_log', 'statistic'), all = TRUE)
t_df = merge(t_df, tmin, by = c('Date', 'PRISM', 'EZ_log', 'statistic'), all = TRUE)

# sort data alphabetically (not sure if this works)
vpd_df = vpd_df %>% 
  arrange(statistic)
t_df = t_df %>% 
  arrange(statistic)

# plot
p15 = ggplot(vpd_df, aes(PRISM, EZ_log)) +
  geom_point(aes(shape = statistic, color = statistic)) +
  geom_smooth(aes(color = statistic), method="lm",se=TRUE) +
  geom_richtext(aes(x = 2.2, y = 3), 
                label = glue("<i>r</i><sup>2</sup> = {vpdmax_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(aes(x = 2, y = 2), 
                label = glue("<i>r</i><sup>2</sup> = {vpdmean_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(aes(x = 1.5, y = 1), 
                label = glue("<i>r</i><sup>2</sup> = {vpdmin_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  scale_color_discrete(palette = c('darkblue','blue','cyan3')) +
  labs(x = "PRISM VPD (kPa)", 
       y = "Sensor VPD (kPa)",
       color = NULL,
       shape = NULL) +
  scale_y_continuous(n.breaks = 6) +
  theme_classic() +
  theme(legend.position = 'bottom')

p16 = ggplot(t_df, aes(PRISM, EZ_log)) +
  geom_point(aes(shape = statistic, color = statistic)) +
  geom_smooth(aes(color = statistic),method="lm",se=TRUE) +
  geom_richtext(aes(x = 24, y = 25), 
                label = glue("<i>r</i><sup>2</sup> = {tmax_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(aes(x = 23, y = 20), 
                label = glue("<i>r</i><sup>2</sup> = {tmean_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(aes(x = 16, y = 10), 
                label = glue("<i>r</i><sup>2</sup> = {tmin_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +  
  scale_color_discrete(palette = c('darkred','red','orange')) +
  labs(x = "PRISM air temperature (°C)", 
       y = "Sensor air temperature (°C)",
       color = NULL,
       shape = NULL) +
  scale_x_continuous(n.breaks = 7) +
  theme_classic() +
  theme(legend.position = 'bottom')

# panels
prism_model = p15 + p16 + plot_annotation(tag_levels = 'A')

export_png('figures/prism_model.png', prism_model)