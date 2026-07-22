# load data
source("analysis/waterloss/clean_porometer.R", local = TRUE, chdir = FALSE)

# load mean midday climate
source("analysis/waterloss/mean_midday_climate.R", local = TRUE, chdir = FALSE)

# defining data type to date
porometer_gsw_total$Date = as_date(porometer_gsw_total$Date)

# merge surface conductance data and mean midday climate data
porometer_VPD = merge(porometer_gsw_total, midday_climate, by = c("Date"))

# defining data type to numeric
porometer_VPD$mean_midday_VPD = as.numeric(porometer_VPD$mean_midday_VPD)
porometer_VPD$mean_midday_temp = as.numeric(porometer_VPD$mean_midday_temp)

# filtering repeated and non-repeated measurements into deparate data frames
porometer_VPD_norepeat = filter(porometer_VPD, repeatMeasurement == 'no')
porometer_VPD_repeat = filter(porometer_VPD, repeatMeasurement == 'yes')

# Total surface conductance and VPD linear regression
summary(lm(gswTotal~mean_midday_VPD, data=porometer_VPD))

# Total surface conductance and air temperature linear regression
summary(lm(gswTotal~mean_midday_temp, data=porometer_VPD))

# Linear mixed effects model for repeated measurements
gs_repeat_lme = lmer(gswTotal_mmol ~ mean_midday_temp + (1 | plant), data = porometer_VPD_repeat)
summary(gs_repeat_lme)

# Linear model for non-repeated measurements
gs_norepeat_lm = lm(gswTotal_mmol~mean_midday_temp, data = porometer_VPD_norepeat)
summary(gs_norepeat_lm)

# Graphs

# looking at the data range for VPD
range(porometer_VPD$mean_midday_VPD)

# defining variables to contain the min and max for the mean midday VPD data column
md_vpd_min = min(porometer_VPD$mean_midday_VPD)
md_vpd_max = max(porometer_VPD$mean_midday_VPD)

# using the min and max to define the limits for the x axis in the graph
vpd_lim1 = md_vpd_min - (md_vpd_max - md_vpd_min)*0.05
vpd_lim2 = md_vpd_max + (md_vpd_max - md_vpd_min)*0.05

# defining variables to contain the min and max for the mean midday temperature data column
md_t_min = min(porometer_VPD$mean_midday_temp)
md_t_max = max(porometer_VPD$mean_midday_temp)

# using the min and max to define the limits for the x axis in the graph
t_lim1 = md_t_min - (md_t_max - md_t_min)*0.05
t_lim2 = md_t_max + (md_t_max - md_t_min)*0.05

# total surface conductance and mean midday vapor pressure deficit
p9 = ggplot(porometer_VPD, aes(x = mean_midday_VPD, y = gswTotal*1000)) +
  geom_point() +
  #geom_smooth(method="lm",se=TRUE) +
  labs(y = "<i>g<sub>s, total</sub></i> (mmol m<sup>-2</sup> s<sup>-1</sup>)", x = "Mean midday VPD (kPa)") +
  annotate("text", x = 5.62, y = 25, label = "n.s.") +
  geom_hline(yintercept = gs_mean_MtD, color = 'blue', linetype = 5) +
  annotate('rect', xmin = -Inf, xmax = Inf, ymin = gs_mean_MtD - gs_sd_MtD, ymax = gs_mean_MtD + gs_sd_MtD, alpha = .1) +
  scale_x_continuous(limits = c(vpd_lim1, vpd_lim2), expand = expansion(mult = 0), breaks = c(1,2,3,4,5)) +
  theme_classic() +
  theme(axis.title.y = element_markdown())

# total surface conductance and mean midday air temperature
p10 = ggplot(porometer_VPD, aes(x = mean_midday_temp, y = gswTotal*1000)) +
  geom_point() +
  #geom_smooth(method="lm",se=TRUE) +
  labs(y = NULL, x = "Mean midday air temperature (°C)") +
  annotate("text", x = 38.5, y = 25, label = "n.s.") +
  geom_hline(yintercept = gs_mean_MtD, color = 'blue', linetype = 5) +
  annotate('rect', xmin = -Inf, xmax = Inf, ymin = gs_mean_MtD - gs_sd_MtD, ymax = gs_mean_MtD + gs_sd_MtD, alpha = .1) +
  scale_x_continuous(limits = c(t_lim1, t_lim2), expand = expansion(mult = 0), breaks = c(20,25,30,35)) +
  theme_classic() +
  theme(axis.title.y = element_markdown())

# panels
gs_climate = p9 + p10 + plot_annotation(tag_levels = 'A')

# export figure
export_png('figures/gs_climate.png', gs_climate)