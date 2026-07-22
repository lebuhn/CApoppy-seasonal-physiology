# load data and analysis
source("analysis/petal_boxplots/diablo_petal_area.R", local = TRUE, chdir = FALSE)
print('Return') # canceling out the 'Hit <Return>' prompt.
print('Return')
print('Return') # This was the best workaround I could come up with.
print('Return')
source("analysis/petal_boxplots/diablo_petal_water.R", local = TRUE, chdir = FALSE)
print('Return')
print('Return')
print('Return')
print('Return')
source("analysis/petal_boxplots/greenhouse_petal_area.R", local = TRUE, chdir = FALSE)
source("analysis/petal_boxplots/greenhouse_petal_water.R", local = TRUE, chdir = FALSE)

# petal projected area and week at Mount Diablo
p1 = ggplot(petal_MtDiablo, aes(group = Date, x = week,y = p_projectedArea)) +
  geom_boxplot(fill = 'orange') +
  labs(title = 'Mount Diablo', subtitle = 'ANOVA, n = 269', y = "<i>A<sub>petal</sub></i> (cm<sup>2</sup>)", x = NULL) +
  geom_richtext(
    x = 15, y = 17, 
    label = glue("<i>r</i><sup>2</sup> = {petal_R2}***"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  theme_classic() +
  ylim(0,20) +
  theme(axis.title.y = element_markdown(),
        plot.title = element_text(hjust = 0.5, size = 12),
        plot.subtitle = element_text(hjust = 0.5))

# petal absolute water content and week at Mount Diablo
p2 = ggplot(petal_MtDiablo, aes(group = Date, x = week,y = p_waterMass)) +
  geom_boxplot(fill = 'lightblue') +
  labs(y = "<i>W<sub>absolute</sub></i> (mg)", x = 'Week of field study') +
  geom_richtext(
    x = 15, y = 170, 
    label = glue("<i>r</i><sup>2</sup> = {water_R2}***"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  theme_classic() +
  ylim(NA,200) +
  theme(axis.title.y = element_markdown())

# petal projected area and week of flowering at the SFSU greenhouse
p3 = ggplot(petal_gh, aes(group = week_of_flowering, x = week_of_flowering, y = p_projectedArea)) +
  geom_boxplot(show.legend = FALSE, fill = 'orange') +
  labs(title = 'SFSU Greenhouse', subtitle = 'LMM, n = 125', x = NULL, y = NULL) +
  geom_richtext(
    x = 15, y = 17, 
    label = glue("<i>r</i><sup>2</sup> = {petal_R2_gh}***"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  theme_classic() +
  ylim(0,20) +
  #xlim(NA,20) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size = 12),
        plot.subtitle = element_text(hjust = 0.5))

# petal absolute water content and week of flowering at the SFSU greenhouse
p4 = ggplot(petal_gh, aes(group = week_of_flowering, x = week_of_flowering, y = p_waterMass)) +
  geom_boxplot(show.legend = FALSE, fill = 'lightblue') +
  labs(x = "Week of flowering", y = NULL) +
  geom_richtext(
    x = 15, y = 170, 
    label = glue("<i>r</i><sup>2</sup> = {water_R2_gh}***"), 
    fill = NA, label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt")) +
  ylim(0,200) +
  theme_classic()

# panels
petal_boxplots = ( (p1 + p3 ) / (p2 + p4) ) + plot_annotation(tag_levels = 'A')
export_png('figures/petal_boxplots.png', petal_boxplots)