# load data and climate model
source("analysis/climate/climate_linegraphs.R", local = TRUE, chdir = FALSE)

# optimize code, for quicker run time

# load data
#source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# load daily average climate csv
#daily_atmosphere_stats = read.csv('data/processed/daily_atmosphere_stats.csv')

# filter out greenhouse, leave in Mount Diablo
#atmosphere_dailyavg = filter(daily_atmosphere_stats, location=='Mount Diablo')

# redefine data types from character to numeric
# didn't do this. code runs fine for now, it's just slow.

# group petals by date and calculate mean projected area
petal_mean <- petal %>%
  group_by(Date) %>%
  get_summary_stats(p_projectedArea, type = "mean_sd")

# group petals by date and calculate mean absolute water content
Wmass_mean <- petal %>%
  group_by(Date) %>%
  get_summary_stats(p_waterMass, type = "mean_sd")

# calculate average maximum temperature and vpd across the 10 days prior to field site visits
climate_normals10 = climatenorm(atmosphere_dailyavg, 10)

# merge petal means and climate means
petal_climate10 = merge(petal_mean, climate_normals10, all.y = TRUE, by = c("Date"))
Wmass_climate10 = merge(Wmass_mean, climate_normals10, all.y = TRUE, by = c("Date"))

# merging Mount Diablo petal observations with prior 10 day climate means
petal_climate10_model_input = merge(petal_MtDiablo, climate_normals10, all.y = TRUE, by = c("Date"))

# changing data type to numeric
petal_climate10_model_input$vpdmax_10daymean_kPa = as.numeric(petal_climate10_model_input$vpdmax_10daymean_kPa)

# log transforming for 10 day climate normal data 
petal_climate10_model_input$log_vpdmax_10daymean_kPa = log10(petal_climate10_model_input$vpdmax_10daymean_kPa)
petal_climate10_model_input$log_p_projectedArea = log10(petal_climate10_model_input$p_projectedArea)
petal_climate10_model_input$log_p_waterMass = log10(petal_climate10_model_input$p_waterMass)

# linear models
VPD_petal_lm = lm(log_p_projectedArea~log_vpdmax_10daymean_kPa, data=petal_climate10_model_input)
VPD_Wmass_lm = lm(log_p_waterMass~log_vpdmax_10daymean_kPa, data=petal_climate10_model_input)

# VPD and petal area linear regression
summary(VPD_petal_lm)

# extracting coefficients and r-squared
VPD_petal_R2 = round(rsq(VPD_petal_lm), 2)
VPD_petal_coeff = VPD_petal_lm$coefficients
VPD_petal_slope = round(as.numeric(VPD_petal_coeff[2]),2)
VPD_petal_intercept = round(as.numeric(VPD_petal_coeff[1]),2)

# VPD and petal absolute water content linear regression
summary(VPD_Wmass_lm)

# extracting coefficients and r-squared
VPD_Wmass_R2 = round(rsq(VPD_Wmass_lm), 2)
VPD_Wmass_coeff = VPD_Wmass_lm$coefficients
VPD_Wmass_slope = round(as.numeric(VPD_Wmass_coeff[2]),2)
VPD_Wmass_intercept = round(as.numeric(VPD_Wmass_coeff[1]),2)

# call the predict function with the log-log model, and log transformed x values.
VPD_predict_log_p_projectedArea_MtD = predict.lm(VPD_petal_lm, petal_climate10_model_input, interval = 'confidence')
petal_climate10_model_input = cbind(petal_climate10_model_input, VPD_predict_log_p_projectedArea_MtD)
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'fit'] <- 'log_p_projectedArea_fit'
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'lwr'] <- 'log_p_projectedArea_lwr'
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'upr'] <- 'log_p_projectedArea_upr'

# do the same as above for Wmass
VPD_predict_log_p_waterMass_MtD = predict.lm(VPD_Wmass_lm, petal_climate10_model_input, interval = 'confidence')
petal_climate10_model_input = cbind(petal_climate10_model_input, VPD_predict_log_p_waterMass_MtD)
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'fit'] <- 'log_p_waterMass_fit'
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'lwr'] <- 'log_p_waterMass_lwr'
names(petal_climate10_model_input)[names(petal_climate10_model_input) == 'upr'] <- 'log_p_waterMass_upr'

# make a new column that takes the anti log of the predicted values and confidence intervals
petal_climate10_model_input$p_projectedArea_fit = 10^(petal_climate10_model_input$log_p_projectedArea_fit)
petal_climate10_model_input$p_projectedArea_lwr = 10^(petal_climate10_model_input$log_p_projectedArea_lwr)
petal_climate10_model_input$p_projectedArea_upr = 10^(petal_climate10_model_input$log_p_projectedArea_upr)

# do the same as above for Wmass
petal_climate10_model_input$p_waterMass_fit = 10^(petal_climate10_model_input$log_p_waterMass_fit)
petal_climate10_model_input$p_waterMass_lwr = 10^(petal_climate10_model_input$log_p_waterMass_lwr)
petal_climate10_model_input$p_waterMass_upr = 10^(petal_climate10_model_input$log_p_waterMass_upr)

# data frame subsets that contains predicted values
VPD_predict_petal <- petal_climate10_model_input[ , c('Date', 'p_projectedArea_fit', 'p_projectedArea_lwr', 'p_projectedArea_upr')] %>%
  distinct(.keep_all = TRUE)

# same as above, but for Wmass
VPD_predict_Wmass <- petal_climate10_model_input[ , c('Date', 'p_waterMass_fit', 'p_waterMass_lwr', 'p_waterMass_upr')] %>%
  distinct(.keep_all = TRUE)

# merge data frames
petal_climate10 = merge(petal_climate10, VPD_predict_petal, all.y = TRUE, by = c("Date"))
Wmass_climate10 = merge(Wmass_climate10, VPD_predict_Wmass, all.y = TRUE, by = c("Date"))

# filter out predicted values outside of the data set range
petal_climate10 = filter(petal_climate10, as.numeric(vpdmax_10daymean_kPa)>1.366 & as.numeric(vpdmax_10daymean_kPa)<=5.492)
Wmass_climate10 = filter(Wmass_climate10, as.numeric(vpdmax_10daymean_kPa)>1.366 & as.numeric(vpdmax_10daymean_kPa)<=5.492)

# ugh. The as.numeric function needs to be called *before* the variables are fed into the ggplot functions.
# but on all the variables?? where the heck did this go wrong.

# projected area and VPD graph
p13 = ggplot(petal_climate10, aes(x = as.numeric(vpdmax_10daymean_kPa), y = as.numeric(mean))) +
  geom_point() +
  #geom_smooth(method="lm",se=TRUE,formula= (y ~ log(x))) +
  #geom_smooth(method="lm",se=TRUE,formula= (y ~ x)) +
  geom_line(
    aes(x = as.numeric(vpdmax_10daymean_kPa), 
        y = as.numeric(p_projectedArea_fit)
    ),
    #method="lm",se=FALSE,formula= (y ~ log(x)),
    linewidth = 1, color = 'blue', show.legend = FALSE) +
  geom_ribbon(
    aes(x = as.numeric(vpdmax_10daymean_kPa), 
        ymin = as.numeric(p_projectedArea_lwr), 
        ymax = as.numeric(p_projectedArea_upr)
    ),
    alpha = 0.2, show.legend = FALSE) +
  geom_errorbar(aes(ymin = as.numeric(mean) - as.numeric(sd),ymax = as.numeric(mean) + as.numeric(sd))) +
  geom_errorbarh(aes(xmin = as.numeric(vpdmax_10daymean_kPa) - as.numeric(vpdmax_10daysd_kPa), xmax = as.numeric(vpdmax_10daymean_kPa) + as.numeric(vpdmax_10daysd_kPa))) +
  scale_y_continuous(n.breaks = 6) +
  scale_x_continuous(breaks = c(1,3,5,7)) +
  #ylim(NA,16) +
  #xlim(NA,8) +
  labs(y = "<i>A<sub>petal</sub></i> (cm<sup>2</sup>)", x = NULL) +
  geom_richtext(aes(x = 5, y = 15), 
                label = glue("<i>r</i><sup>2</sup> = {VPD_petal_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(
    x = 5, y = 13.5, 
    label = glue("<i>A<sub>petal</sub></i> = VPD<sub>max</sub><sup>{VPD_petal_slope}</sup> ∙ 10<sup>{VPD_petal_intercept}</sup>"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown()
  )

# absolute water content and VPD graph
p14 = ggplot(Wmass_climate10, aes(x = as.numeric(vpdmax_10daymean_kPa), y = as.numeric(mean))) +
  geom_point() +
  #geom_smooth(method="lm",se=TRUE,formula= (y ~ log(x))) +
  #geom_smooth(method="lm",se=TRUE,formula= (y ~ x)) +
  geom_line(
    aes(x = as.numeric(vpdmax_10daymean_kPa), 
        y = as.numeric(p_waterMass_fit)
    ),
    #method="lm",se=FALSE,formula= (y ~ log(x)),
    linewidth = 1, color = 'blue', show.legend = FALSE) +
  geom_ribbon(
    aes(x = as.numeric(vpdmax_10daymean_kPa), 
        ymin = as.numeric(p_waterMass_lwr), 
        ymax = as.numeric(p_waterMass_upr)
    ),
    alpha = 0.2, show.legend = FALSE) +
  geom_errorbar(aes(ymin = as.numeric(mean) - as.numeric(sd),ymax = as.numeric(mean) + as.numeric(sd))) +
  geom_errorbarh(aes(xmin = as.numeric(vpdmax_10daymean_kPa) - as.numeric(vpdmax_10daysd_kPa), xmax = as.numeric(vpdmax_10daymean_kPa) + as.numeric(vpdmax_10daysd_kPa))) +
  scale_y_continuous(n.breaks = 6) +
  scale_x_continuous(breaks = c(1,3,5,7)) +
  #ylim(NA,16) +
  #xlim(NA,8) +
  labs(y = "<i>W<sub>absolute</sub></i> (mg)", x = "10-day mean VPD<sub>max</sub> (kPa)") +
  geom_richtext(aes(x = 5, y = 125), 
                label = glue("<i>r</i><sup>2</sup> = {VPD_Wmass_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(
    x = 5, y = 112.5, 
    label = glue("<i>W<sub>absolute</sub></i> = VPD<sub>max</sub><sup>{VPD_Wmass_slope}</sup> ∙ 10<sup>{VPD_Wmass_intercept}</sup>"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown()
  )

# panel
petal_vpd_scatter = (p13 / p14) + plot_annotation(tag_levels = 'A')

export_png2('figures/petal_vpd_scatter.png', petal_vpd_scatter)