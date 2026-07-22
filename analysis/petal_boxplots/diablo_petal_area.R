# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# ANOVA
petal_aov <- aov(p_projectedArea~week,data=petal_MtDiablo)

# extracting petal aov summary
petal_aov_summary = summary(petal_aov)
print(petal_aov_summary)
petal_aov_df = petal_aov_summary[[1]]

# defining the sum of squares
sumSq_groups = petal_aov_df$`Sum Sq`[1]
sumSq_error = petal_aov_df$`Sum Sq`[2]

# defining R squared
petal_R2 = round((sumSq_groups / (sumSq_groups + sumSq_error)),2)
print('% of projected area variation explained by time')
petal_R2

# extracting model residuals
petal_aov_res <- residuals(petal_aov)

# testing normality assumptions
plot(petal_aov)

# shapiro test
shapiro.test(petal_aov_res)

# bartlett test
bartlett.test(p_projectedArea~week, data=petal_MtDiablo)

# log 10 transformation does not pass bartlett test
bartlett.test(log10(p_projectedArea)~log10(week), data=petal_MtDiablo)

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
petal_aov = aov(p_projectedArea~season,data=petal_MtDiablo)
summary(petal_aov)

# Tukey test to see which dates are significantly different
t_petal <- TukeyHSD(petal_aov)
t_petal

# calculating mean and standard deviation for each group
petal_area_MtDiablo_averages = petal_MtDiablo %>% 
  group_by(season) %>%
  get_summary_stats(p_projectedArea, type = "mean_sd")
print(petal_area_MtDiablo_averages)

# Visualization of the Tukey test
plot(t_petal)