# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# Linear mixed effect model
greenhouse_Apetal_lme <- lmer(p_projectedArea ~ week_of_flowering + (1 | plant), data = petal_gh)
anova(greenhouse_Apetal_lme)

# calculating r-squared
print("% variation in greenhouse projected area:")
petal_R2_gh = rsq.lmm(greenhouse_Apetal_lme)
petal_R2_gh = round(petal_R2_gh$model,2)
petal_R2_gh

# extracting model residuals
greenhouse_Apetal_lme_residuals = residuals(greenhouse_Apetal_lme)

# shapiro test
shapiro.test(greenhouse_Apetal_lme_residuals)

# plotting fitted vs. residuals
plot(greenhouse_Apetal_lme)

# q-q plot
qqnorm(greenhouse_Apetal_lme_residuals)
qqline(greenhouse_Apetal_lme_residuals)

# grouping similar weeks together.
petal_gh = petal_gh %>%
  mutate(floral_development_period = case_when(
    week_of_flowering < 4 & week_of_flowering > 0 ~ 'week 1 - 3',
    week_of_flowering < 6 & week_of_flowering > 3 ~ 'week 4 - 5',
    week_of_flowering >= 6 ~ 'week 6 - 18'
  )
  )

#LMM for developmental periods
petal_gh_lme_model <- lmer(p_projectedArea ~ floral_development_period + (1 | plant), data = petal_gh)
anova(petal_gh_lme_model)

# estimated marginal means
t_gh = emmeans(petal_gh_lme_model, list(pairwise ~ floral_development_period), adjust = "tukey")
t_gh
plot(t_gh)

# calculating group means and standard deviations.
petal_area_gh_averages = petal_gh %>% 
  group_by(floral_development_period) %>%
  get_summary_stats(p_projectedArea, type = "mean_sd")
print(petal_area_gh_averages)