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

# Water Content per Dry Mass and Area Regression
lm_Wmass_Apetal = lm(log_p_waterContentPerDryMass_MtD~log_p_projectedArea_MtD, data=petal)
summary(lm_Wmass_Apetal)

# extracting coefficients and r-squared
Wmass_Apetal_coeff = lm_Wmass_Apetal$coefficients
Wmass_Apetal_slope = round(as.numeric(Wmass_Apetal_coeff[2]),2)
Wmass_Apetal_intercept = round(as.numeric(Wmass_Apetal_coeff[1]),2)
Wmass_Apetal_R2 = round(rsq(lm_Wmass_Apetal),2)

# call the predict function with the log-log model, and log transformed x values.
log_p_Wmass_MtD_predicted = predict.lm(lm_Wmass_Apetal, petal, interval = 'confidence')
petal = cbind(petal, log_p_Wmass_MtD_predicted)
names(petal)[names(petal) == 'fit'] <- 'log_p_Wmass_MtD_fit'
names(petal)[names(petal) == 'lwr'] <- 'log_p_Wmass_MtD_lwr'
names(petal)[names(petal) == 'upr'] <- 'log_p_Wmass_MtD_upr'

# make a new column that takes the anti log of the predicted values and confidence intervals
petal$p_Wmass_MtD_fit = 10^(petal$log_p_Wmass_MtD_fit)
petal$p_Wmass_MtD_lwr = 10^(petal$log_p_Wmass_MtD_lwr)
petal$p_Wmass_MtD_upr = 10^(petal$log_p_Wmass_MtD_upr)

# scatterplot
water_mass_area = ggplot(petal, aes(x = p_projectedArea, y = ((p_waterMass) / p_dryMass))) +
  geom_point(aes(colour = location, shape = location), size = 4, show.legend = FALSE) +
  geom_smooth(
    aes(
      x = p_projectedArea_MtD, 
      y = (p_waterMass_MtD / p_dryMass_MtD)
    ), 
    method="lm",
    se=TRUE,
    formula= y ~ I(x^(22/100)),
    colour = 'black') +
  labs(x = "<i>A<sub>petal</sub></i> (cm<sup>2</sup>)", 
       y = "<i>W<sub>mass</sub></i> (g g<sup>-1</sup>)") +
  geom_richtext(x = 15, y = 4.5, 
                label = glue("<i>W<sub>mass</sub></i> = <i>A<sub>petal</sub></i><sup>{Wmass_Apetal_slope}</sup> ∙ 10<sup>{Wmass_Apetal_intercept}</sup>"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(x = 15, y = 5.5, label = glue("<i>r</i><sup>2</sup> = {Wmass_Apetal_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  scale_colour_brewer(palette = 'Paired') +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown()
  )

export_png('figures/water_mass_area.png', water_mass_area)