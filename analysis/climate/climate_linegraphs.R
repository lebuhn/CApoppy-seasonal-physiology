# load PRISM model
source("analysis/climate/prism_model.R", local = TRUE, chdir = FALSE)

# Recovering Lost Mount Diablo Climate Data

# defining a new dataframe for daily average VPD and renaming columns
atmosphere_dailyavg_vpd = prism_UTC_merge
names(atmosphere_dailyavg_vpd)[names(atmosphere_dailyavg_vpd) == 'mean'] <- 'EZlog_vpdmean'
names(atmosphere_dailyavg_vpd)[names(atmosphere_dailyavg_vpd) == 'sd'] <- 'EZlog_vpd_sd'
names(atmosphere_dailyavg_vpd)[names(atmosphere_dailyavg_vpd) == 'n'] <- 'EZlog_vpd_n'
atmosphere_dailyavg_vpd$variable = NULL
atmosphere_dailyavg_vpd$median = NULL
atmosphere_dailyavg_vpd$q1 = NULL
atmosphere_dailyavg_vpd$q3 = NULL
atmosphere_dailyavg_vpd$iqr = NULL
atmosphere_dailyavg_vpd$mad = NULL
atmosphere_dailyavg_vpd$se = NULL
atmosphere_dailyavg_vpd$ci = NULL

# defining a new dataframe for daily average temperatures and renaming columns
atmosphere_dailyavg_temp = prism_UTC_temp_merge
names(atmosphere_dailyavg_temp)[names(atmosphere_dailyavg_temp) == 'mean'] <- 'EZlog_tmean'
names(atmosphere_dailyavg_temp)[names(atmosphere_dailyavg_temp) == 'sd'] <- 'EZlog_t_sd'
names(atmosphere_dailyavg_temp)[names(atmosphere_dailyavg_temp) == 'n'] <- 'EZlog_t_n'
atmosphere_dailyavg_temp$variable = NULL
atmosphere_dailyavg_temp$median = NULL
atmosphere_dailyavg_temp$q1 = NULL
atmosphere_dailyavg_temp$q3 = NULL
atmosphere_dailyavg_temp$iqr = NULL
atmosphere_dailyavg_temp$mad = NULL
atmosphere_dailyavg_temp$se = NULL
atmosphere_dailyavg_temp$ci = NULL

# merging daily average atmospheric measurements into a new dataframe
atmosphere_dailyavg = merge(atmosphere_dailyavg_vpd, atmosphere_dailyavg_temp, by = c('Date', 'ppt..mm.','tmin..degrees.C.','tmean..degrees.C.','tmax..degrees.C.','tdmean..degrees.C.','vpdmin..hPa.','vpdmax..hPa.','Comments','PRISM_Date'))

# renaming date columns. PST is 20 hours behind PRISM time.
atmosphere_dailyavg$PRISM_Date = NULL
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'Date'] <- 'PRISM_Date'
atmosphere_dailyavg$Date = atmosphere_dailyavg$PRISM_Date - day(1)

# renaming columns to specify PRISM data sources
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'ppt..mm.'] <- 'PRISM_ppt_mm'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'tmin..degrees.C.'] <- 'PRISM_tmin_C'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'tmean..degrees.C.'] <- 'PRISM_tmean_C'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'tmax..degrees.C.'] <- 'PRISM_tmax_C'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'tdmean..degrees.C.'] <- 'PRISM_tdmean_C'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'vpdmin..hPa.'] <- 'PRISM_vpdmin_hPa'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'vpdmax..hPa.'] <- 'PRISM_vpdmax_hPa'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'vpdmin..kPa.'] <- 'PRISM_vpdmin_kPa'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'vpdmean..kPa.'] <- 'PRISM_vpdmean_kPa'
names(atmosphere_dailyavg)[names(atmosphere_dailyavg) == 'vpdmax..kPa.'] <- 'PRISM_vpdmax_kPa'

# defining new columns for concatenating different data sources
atmosphere_dailyavg$vpdmin_kPa = atmosphere_dailyavg$EZlog_vpdmin
atmosphere_dailyavg$vpdmean_kPa = atmosphere_dailyavg$EZlog_vpdmean
atmosphere_dailyavg$vpdmax_kPa = atmosphere_dailyavg$EZlog_vpdmax
atmosphere_dailyavg$tmin_C = atmosphere_dailyavg$EZlog_tmin
atmosphere_dailyavg$tmean_C = atmosphere_dailyavg$EZlog_tmean
atmosphere_dailyavg$tmax_C = atmosphere_dailyavg$EZlog_tmax
atmosphere_dailyavg$data_source = atmosphere_dailyavg$Comments
atmosphere_dailyavg$location = 'Mount Diablo'

# filling in null EZ log values with values from the climate models developed with PRISM data.
for (i in (seq_len(nrow(atmosphere_dailyavg)))) {
  compiled = atmosphere_dailyavg[i,c("vpdmin_kPa","vpdmean_kPa","vpdmax_kPa","tmin_C","tmean_C","tmax_C")]
  model = atmosphere_dailyavg[i,c("model2_vpdmin","model_vpdmean","model_vpdmax","model_tmin","model_tmean","model_tmax")]
  if (is.na(compiled[1,1]) == TRUE) {
    atmosphere_dailyavg[i,c("vpdmin_kPa","vpdmean_kPa","vpdmax_kPa","tmin_C","tmean_C","tmax_C")] = model
    atmosphere_dailyavg$data_source[i] = 'PRISM climate model'
  } else {
    atmosphere_dailyavg$data_source[i] = 'On-site sensor'
  }
}

# Greenhouse Daily Average Temperature and VPD

# Field data was represented as daily mean, max, and min in order to recover lost data. 
# For consistency, I believe it would be best to represent greenhouse data the same way.

# mean daily temperature
atmosphere_gh_dailyavg_temp <- atmosphere_gh %>%
  group_by(Date) %>%
  get_summary_stats(Celsius.C., type = "full")

# mean daily VPD
atmosphere_gh_dailyavg_vpd <- atmosphere_gh %>%
  group_by(Date) %>%
  get_summary_stats(VPD, type = "full")

# renaming columns
names(atmosphere_gh_dailyavg_vpd)[names(atmosphere_gh_dailyavg_vpd) == 'mean'] <- 'EZlog_vpdmean'
names(atmosphere_gh_dailyavg_vpd)[names(atmosphere_gh_dailyavg_vpd) == 'sd'] <- 'EZlog_vpd_sd'
names(atmosphere_gh_dailyavg_vpd)[names(atmosphere_gh_dailyavg_vpd) == 'n'] <- 'EZlog_vpd_n'
names(atmosphere_gh_dailyavg_vpd)[names(atmosphere_gh_dailyavg_vpd) == 'min'] <- 'EZlog_vpdmin'
names(atmosphere_gh_dailyavg_vpd)[names(atmosphere_gh_dailyavg_vpd) == 'max'] <- 'EZlog_vpdmax'
atmosphere_gh_dailyavg_vpd$variable = NULL
atmosphere_gh_dailyavg_vpd$median = NULL
atmosphere_gh_dailyavg_vpd$q1 = NULL
atmosphere_gh_dailyavg_vpd$q3 = NULL
atmosphere_gh_dailyavg_vpd$iqr = NULL
atmosphere_gh_dailyavg_vpd$mad = NULL
atmosphere_gh_dailyavg_vpd$se = NULL
atmosphere_gh_dailyavg_vpd$ci = NULL

# renaming columns
names(atmosphere_gh_dailyavg_temp)[names(atmosphere_gh_dailyavg_temp) == 'mean'] <- 'EZlog_tmean'
names(atmosphere_gh_dailyavg_temp)[names(atmosphere_gh_dailyavg_temp) == 'sd'] <- 'EZlog_t_sd'
names(atmosphere_gh_dailyavg_temp)[names(atmosphere_gh_dailyavg_temp) == 'n'] <- 'EZlog_t_n'
names(atmosphere_gh_dailyavg_temp)[names(atmosphere_gh_dailyavg_temp) == 'min'] <- 'EZlog_tmin'
names(atmosphere_gh_dailyavg_temp)[names(atmosphere_gh_dailyavg_temp) == 'max'] <- 'EZlog_tmax'
atmosphere_gh_dailyavg_temp$variable = NULL
atmosphere_gh_dailyavg_temp$median = NULL
atmosphere_gh_dailyavg_temp$q1 = NULL
atmosphere_gh_dailyavg_temp$q3 = NULL
atmosphere_gh_dailyavg_temp$iqr = NULL
atmosphere_gh_dailyavg_temp$mad = NULL
atmosphere_gh_dailyavg_temp$se = NULL
atmosphere_gh_dailyavg_temp$ci = NULL

# merging temperature and VPD data frames
atmosphere_gh_dailyavg = merge(atmosphere_gh_dailyavg_vpd, atmosphere_gh_dailyavg_temp, by = 'Date')

# defining new columns for concatenating different data sources
atmosphere_gh_dailyavg$vpdmin_kPa = atmosphere_gh_dailyavg$EZlog_vpdmin
atmosphere_gh_dailyavg$vpdmean_kPa = atmosphere_gh_dailyavg$EZlog_vpdmean
atmosphere_gh_dailyavg$vpdmax_kPa = atmosphere_gh_dailyavg$EZlog_vpdmax
atmosphere_gh_dailyavg$tmin_C = atmosphere_gh_dailyavg$EZlog_tmin
atmosphere_gh_dailyavg$tmean_C = atmosphere_gh_dailyavg$EZlog_tmean
atmosphere_gh_dailyavg$tmax_C = atmosphere_gh_dailyavg$EZlog_tmax
atmosphere_gh_dailyavg$data_source = 'On-site sensor'
atmosphere_gh_dailyavg$location = 'SFSU Greenhouse'

# Plotted Data

# pulling out the relevant data columns
atmosphere_MtDiablo_dailyavg = atmosphere_dailyavg[ , c('Date','EZlog_vpd_n','EZlog_vpdmin','EZlog_vpdmean','EZlog_vpdmax','EZlog_vpd_sd','EZlog_t_n','EZlog_tmin','EZlog_tmean','EZlog_tmax','EZlog_t_sd','vpdmin_kPa','vpdmean_kPa','vpdmax_kPa','tmin_C','tmean_C','tmax_C','data_source','location')]

# combining Mount Diablo and greenhouse data frames
atmosphere_dailyavg_output = rbind(atmosphere_MtDiablo_dailyavg, atmosphere_gh_dailyavg)

# exporting out daily climate data as a csv file
write.csv(atmosphere_dailyavg_output, "data/processed/daily_atmosphere_stats.csv", row.names=FALSE)

# Monthly Climate Averages

# making the month column
atmosphere_dailyavg_output$month = month(atmosphere_dailyavg_output$Date, label = TRUE)
monthly_climate_averages = atmosphere_dailyavg_output %>% 
  group_by(month) %>%
  get_summary_stats(tmax_C, tmean_C, tmin_C, vpdmax_kPa, vpdmean_kPa, vpdmin_kPa, type = "mean_sd")

# outputs
print(monthly_climate_averages, n = 66)

print('Greenhouse mean air temperature')
mean(atmosphere_gh_dailyavg$tmean_C)
print('Greenhouse air temperature standard deviation')
sd(atmosphere_gh_dailyavg$tmean_C)

print('Greenhouse average VPD')
mean(atmosphere_gh_dailyavg$vpdmean_kPa)
print('Greenhouse VPD standard deviation')
sd(atmosphere_gh_dailyavg$vpdmean_kPa)

# Climate Line Graphs

# figure labels
AB_annotations <- data.frame(label = c("A", "B"),  # Create data for text
                             location = c("Mount Diablo", "SFSU Greenhouse"),
                             x = c('2025-02-14', '2025-09-12'),
                             y = c(8, 8))

AB_annotations$x = as.Date(AB_annotations$x, "%Y-%m-%d")

# VPD line graphs
p5 = ggplot(atmosphere_dailyavg_output, aes(x=Date, y=EZlog_vpdmean)) + 
  geom_ribbon(aes(ymin = vpdmin_kPa, ymax = vpdmax_kPa), fill = "lightblue") +
  geom_line() +
  geom_line(aes(x=Date,y=vpdmean_kPa), linetype = '11', color = 'darkblue'
  ) +
  labs(y = 'VPD (kPa)', x = NULL) +
  facet_wrap(~location, scales = 'free_x', axes = 'all') +
  geom_text(data = AB_annotations,
            mapping = aes(x = -Inf,
                          y = Inf,
                          hjust   = -0.5,
                          vjust   = 1,
                          label = label)) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown(),
        strip.background = element_blank(),
        strip.text = element_text(size = 12)
  ) +
  scale_x_date(expand = expansion(mult = 0))

# figure labels
CD_annotations <- data.frame(label = c("C", "D"),  # Create data for text
                             location = c("Mount Diablo", "SFSU Greenhouse"),
                             x = c('2025-02-14', '2025-09-12'),
                             y = c(45, 45))

CD_annotations$x = as.Date(AB_annotations$x, "%Y-%m-%d")

# temperature line graphs
p6 = ggplot(atmosphere_dailyavg_output, aes(x=Date, y=EZlog_tmean)) + 
  geom_ribbon(aes(ymin = tmin_C, ymax = tmax_C), fill = "orange") +
  geom_line() +
  geom_line(aes(x=Date,y=tmean_C), linetype = '11', color = 'darkred'
  ) +
  labs(y = 'Air temperature (°C)') +
  facet_wrap(~location, scales = 'free_x', axes = 'all') +
  geom_text(data = CD_annotations,
            mapping = aes(x = -Inf,
                          y = Inf,
                          hjust   = -0.5,
                          vjust   = 1,
                          label = label)) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown(),
        strip.background = element_blank(),
        strip.text = element_blank()
  ) +
  scale_x_date(expand = expansion(mult = 0))

# panels
climate_linegraphs = p5 / p6 #+ plot_annotation(tag_levels = "a")

export_png('figures/climate_linegraphs.png', climate_linegraphs)