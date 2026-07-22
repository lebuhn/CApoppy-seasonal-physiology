# load data
source("analysis/waterloss/clean_porometer.R", local = TRUE, chdir = FALSE)

# Calculating Mean Greenhouse gs Values

# grouping by plant and date and calculating mean and standard deviation
porometer_gsw_total_gh_means <- porometer_gsw_total_gh %>%
  group_by(plant, Date) %>%
  get_summary_stats(gswTotal_mmol, type = "mean_sd")

# renaming columns
names(porometer_gsw_total_gh_means)[names(porometer_gsw_total_gh_means) == 'n'] <- 'gswTotal_n'
names(porometer_gsw_total_gh_means)[names(porometer_gsw_total_gh_means) == 'mean'] <- 'gswTotal_mean'
names(porometer_gsw_total_gh_means)[names(porometer_gsw_total_gh_means) == 'sd'] <- 'gswTotal_sd'

# removing extra column
porometer_gsw_total_gh_means$variable = NULL

# merge greenhouse petals and surface conductance
petal_gsw_gh = merge(petal_gh, porometer_gsw_total_gh_means, by = c("Date", "plant"))

# Linear mixed effects model
gsw_gh_lme_model <- lmer(gswTotal_mean ~ week_of_flowering + (1 | plant), data = petal_gsw_gh)

# Summary of the model
print("Greenhouse surface conductance linear mixed effects model")
summary(gsw_gh_lme_model)
print("Analysis of variance")
anova(gsw_gh_lme_model)

# extracting residuals
gsw_gh_lme_residuals = residuals(gsw_gh_lme_model)
gsw_gh_lme_residuals_df = as.data.frame(gsw_gh_lme_residuals)

# fitted vs. residuals
plot(gsw_gh_lme_model)

# q-q plot
qqnorm(petal_gsw_gh$gswTotal_mean)
qqline(petal_gsw_gh$gswTotal_mean)

# shapiro test
shapiro.test(gsw_gh_lme_residuals)

# Mean total gs at SFSU greenhouse
mean(porometer_gsw_total_gh$gswTotal)

# Total gs standard deviation at SFSU greenhouse
sd(porometer_gsw_total_gh$gswTotal)

# Mount Diablo Surface Conductance over Time

# Mount Diablo surface conductance linear regression
summary(lm(gswTotal_mmol~week, data = porometer_gsw_total))

# filtering by repeat measurements
porometer_gsw_total_repeat = filter(porometer_gsw_total, repeatMeasurement == 'yes')
porometer_gsw_total_norepeat = filter(porometer_gsw_total, repeatMeasurement == 'no')

# LMM and LM for repeat and non-repeat measurements
gs_repeat_lme = lmer(gswTotal_mmol ~ week + (1 | plant), data = porometer_gsw_total_repeat)
gs_norepeat_lm = lm(gswTotal_mmol~week, data = porometer_gsw_total_norepeat)

# model summaries
summary(gs_repeat_lme)
summary(gs_norepeat_lm)

# mean and standard deviation for repeat measurements
gs_repeat_mean = round(mean(porometer_gsw_total_repeat$gswTotal_mmol),2)
gs_repeat_sd = round(sd(porometer_gsw_total_repeat$gswTotal_mmol),2)

# mean and standard deviation for non-repeat measurements
gs_norepeat_mean = round(mean(porometer_gsw_total_norepeat$gswTotal_mmol),2)
gs_norepeat_sd = round(sd(porometer_gsw_total_norepeat$gswTotal_mmol),2)

# Graphs

# ontogeny in the greenhouse
p7 = ggplot(petal_gsw_gh, aes(x = week_of_flowering, y = gswTotal_mean)) +
  geom_point() +
  labs(x = "Week of flowering", y = NULL) +
  annotate("text", x = 18, y = 25, label = "n.s.") +
  geom_hline(yintercept = gs_mean_gh, color = 'blue', linetype = 5) +
  annotate('rect', xmin = -Inf, xmax = Inf, ymin = gs_mean_gh - gs_sd_gh, ymax = gs_mean_gh + gs_sd_gh, alpha = .1) +
  theme_classic() +
  ylim(0,25) +
  scale_x_continuous(limits = c(0.15,18.85), expand = expansion(mult = 0), breaks = c(5,10,15)) +
  theme(axis.title.y = element_markdown())

# Mount Diablo over time
p8 = ggplot(porometer_gsw_total, aes(x = week, y = gswTotal*1000)) + 
  geom_point() + 
  labs(x = 'Week of field study', y = "<i>g<sub>s, total</sub></i> (mmol m<sup>-2</sup> s<sup>-1</sup>)") +
  annotate("text", x = 18, y = 25, label = "n.s.") +
  geom_hline(yintercept = gs_mean_MtD, color = 'blue', linetype = 5) +
  annotate('rect', xmin = -Inf, xmax = Inf, ymin = gs_mean_MtD - gs_sd_MtD, ymax = gs_mean_MtD + gs_sd_MtD, alpha = .1) +
  scale_x_continuous(limits = c(0.15,18.85), expand = expansion(mult = 0), breaks = c(5,10,15)) +
  theme_classic() +
  theme(axis.title.y = element_markdown())

# panels
gs_ontogeny = p8 + p7 + plot_annotation(tag_levels = 'A')

# export figure
export_png('figures/gs_ontogeny.png', gs_ontogeny)