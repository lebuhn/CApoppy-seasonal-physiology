# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# ANOVA
water_aov <- aov(p_waterMass~week,data=petal_MtDiablo)

# extracting water aov summary
water_aov_summary = summary(water_aov)
print(water_aov_summary)
water_aov_df = water_aov_summary[[1]]

# defining the sum of squares
sumSq_groups_water = water_aov_df$`Sum Sq`[1]
sumSq_error_water = water_aov_df$`Sum Sq`[2]

# defining R squared
water_R2 = round((sumSq_groups_water / (sumSq_groups_water + sumSq_error_water)),2)
print('% of absolute water content variation explained by time')
water_R2

# extracting model residuals
water_aov_res <- residuals(water_aov)

# testing normality assumptions
plot(water_aov)

# shapiro test
shapiro.test(water_aov_res)

# bartlett test
bartlett.test(p_waterMass~week, data=petal_MtDiablo)

# log 10 transformation does not pass bartlett test
bartlett.test(log10(p_waterMass)~log10(week), data=petal_MtDiablo)

# grouping weeks by petal similarity. 
# These groups were chosen based on Tukey HSD comparisons between weeks. 
# The naming convention reflects the implicit assumption that petal size is a 
# function of seasonal water availability, as the study period covered the 
# seasonal transition from 'wet-winter' to 'dry-summer.'
endWet = 8
startDry = 10

petal_MtDiablo = petal_MtDiablo %>%
  mutate(season = case_when(week < endWet ~ 'wet',
                            week == endWet ~ 'transition',
                            week == startDry ~ 'transition',
                            week > startDry ~ 'dry')
  )

# ANOVA for seasonal groups
water_aov = aov(p_waterMass~season,data=petal_MtDiablo)
summary(water_aov)

# Tukey test to see which dates are significantly different
t_water <- TukeyHSD(water_aov)
t_water

# calculating mean and standard deviation for each group
petal_water_MtDiablo_averages = petal_MtDiablo %>% 
  group_by(season) %>%
  get_summary_stats(p_waterMass, type = "mean_sd")
print(petal_water_MtDiablo_averages)

# Visualization of the Tukey test
plot(t_water)