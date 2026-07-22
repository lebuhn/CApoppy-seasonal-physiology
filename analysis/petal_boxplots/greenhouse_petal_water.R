# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# Linear mixed effect model
greenhouse_Wmass_lme <- lmer(p_waterMass ~ week_of_flowering + (1 | plant), data = petal_gh)
anova(greenhouse_Wmass_lme)

# calculating r-squared
print("% variation in greenhouse water content:")
water_R2_gh = rsq.lmm(greenhouse_Wmass_lme)
water_R2_gh = round(water_R2_gh$model,2)
water_R2_gh

# extracting model residuals
greenhouse_Wmass_lme_residuals = residuals(greenhouse_Wmass_lme)

# shapiro test
shapiro.test(greenhouse_Wmass_lme_residuals)

# plot fitted vs. model residuals
plot(greenhouse_Wmass_lme)

# q-q plot
qqnorm(greenhouse_Wmass_lme_residuals)
qqline(greenhouse_Wmass_lme_residuals)

# grouping similar weeks together.
petal_gh = petal_gh %>%
  mutate(floral_development_period = case_when(
    week_of_flowering < 4 & week_of_flowering > 0 ~ 'week 1 - 3',
    week_of_flowering < 6 & week_of_flowering > 3 ~ 'week 4 - 5',
    week_of_flowering >= 6 ~ 'week 6 - 18'
  )
  )

#LMM for developmental periods
mass_gh_lme_model <- lmer(p_waterMass ~ floral_development_period + (1 | plant), data = petal_gh)
anova(mass_gh_lme_model)

# estimated marginal means
t_mass_gh = emmeans(mass_gh_lme_model, list(pairwise ~ floral_development_period), adjust = "tukey")
t_mass_gh
plot(t_mass_gh)

# calculating group means and standard deviations.
petal_water_gh_averages = petal_gh %>% 
  group_by(floral_development_period) %>%
  get_summary_stats(p_waterMass, type = "mean_sd")
print(petal_water_gh_averages)