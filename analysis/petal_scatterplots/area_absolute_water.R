# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# separating out subset of Mount Diablo data to be modeled
petal_MtDiablo_subset = petal_MtDiablo[ , c('Date', 'plant', 'p_projectedArea', 'p_dryMass', 'p_waterMass')]

# renaming columns
names(petal_MtDiablo_subset)[names(petal_MtDiablo_subset) == 'p_projectedArea'] <- 'p_projectedArea_MtD'
names(petal_MtDiablo_subset)[names(petal_MtDiablo_subset) == 'p_dryMass'] <- 'p_dryMass_MtD'
names(petal_MtDiablo_subset)[names(petal_MtDiablo_subset) == 'p_waterMass'] <- 'p_waterMass_MtD'

# recombine with the larger data frame
petal = merge(petal, petal_MtDiablo_subset, by = c('Date', 'plant'), all.x = TRUE)

# making new columns with log transformed data
petal = petal %>% mutate(log_p_waterMass_MtD = log10(p_waterMass_MtD))
petal = petal %>% mutate(log_p_projectedArea_MtD = log10(p_projectedArea_MtD))
petal = petal %>% mutate(log_p_waterContentPerDryMass_MtD = log10(p_waterMass_MtD / p_dryMass_MtD))

# Area and Absolute Water Content Regression
lm_Apetal_Mh2o = lm(log_p_projectedArea_MtD~log_p_waterMass_MtD, data=petal)
summary(lm_Apetal_Mh2o)

# extracting coefficients and r-squared
Apetal_Mh2o_coeff = lm_Apetal_Mh2o$coefficients
Apetal_Mh2o_slope = round(as.numeric(Apetal_Mh2o_coeff[2]),2)
Apetal_Mh2o_intercept = round(as.numeric(Apetal_Mh2o_coeff[1]),2)
Apetal_Mh2o_R2 = round(rsq(lm_Apetal_Mh2o),2)

# call the predict function with the log-log model, and log transformed x values.
log_p_projectedArea_MtD_predicted = predict.lm(lm_Apetal_Mh2o, petal, interval = 'confidence')
petal = cbind(petal, log_p_projectedArea_MtD_predicted)
names(petal)[names(petal) == 'fit'] <- 'log_p_projectedArea_MtD_fit'
names(petal)[names(petal) == 'lwr'] <- 'log_p_projectedArea_MtD_lwr'
names(petal)[names(petal) == 'upr'] <- 'log_p_projectedArea_MtD_upr'

# make a new column that takes the anti log of the predicted values and confidence intervals
petal$p_projectedArea_MtD_fit = 10^(petal$log_p_projectedArea_MtD_fit)
petal$p_projectedArea_MtD_lwr = 10^(petal$log_p_projectedArea_MtD_lwr)
petal$p_projectedArea_MtD_upr = 10^(petal$log_p_projectedArea_MtD_upr)

# scatterplot
area_absolute_water = ggplot(petal, aes(y = p_projectedArea, x = p_waterMass)) +
  geom_point(aes(colour = location, shape = location), size = 3, show.legend = FALSE) +
  geom_line(
    aes(x = p_waterMass_MtD, y = p_projectedArea_MtD_fit), 
    linewidth = 1, show.legend = FALSE) +
  geom_ribbon(
    aes(x = p_waterMass_MtD, ymin = p_projectedArea_MtD_lwr, ymax = p_projectedArea_MtD_upr),
    alpha = 0.2, show.legend = FALSE) +
  labs(x = "<i>W<sub>absolute</sub></i> (mg)", 
       y = "<i>A<sub>petal</sub></i> (cm<sup>2</sup>)"
  ) +
  geom_richtext(
    x = 150, y = 6, 
    label = glue("<i>A<sub>petal</sub></i> = <i>W<sub>absolute</sub></i><sup>{Apetal_Mh2o_slope}</sup> ∙ 10<sup>{Apetal_Mh2o_intercept}</sup>"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  geom_richtext(
    x = 50, y = 17, 
    label = glue("<i>r</i><sup>2</sup> = {Apetal_Mh2o_R2}***"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt") ) +
  scale_colour_brewer(palette = 'Paired') +
  ylim(NA,20) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown())

export_png('figures/area_absolute_water.png', area_absolute_water)