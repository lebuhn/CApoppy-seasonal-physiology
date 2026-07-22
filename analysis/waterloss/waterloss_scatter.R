# load data
source("analysis/waterloss/clean_porometer.R", local = TRUE, chdir = FALSE)

# load mean midday climate
source("analysis/waterloss/mean_midday_climate.R", local = TRUE, chdir = FALSE)

# Modeling Midday Water Loss

# Merging Mount Diablo gs Observations with their Petals
petal_complete = merge(petal_MtDiablo, porometer_gsw_total, by = c("Date", "week", "plant", "location"), all.x = TRUE)

# define data type for the date column
petal_complete$Date = as_date(petal_complete$Date)

# merging the petal data with the midday climate data
petal_complete_midday_climate = merge(petal_complete, midday_climate, by = c("Date"), all.x = TRUE)

# define data type for the date column
petal_complete_midday_climate$mean_midday_VPD = as.numeric(petal_complete_midday_climate$mean_midday_VPD)
petal_complete_midday_climate$mean_midday_temp = as.numeric(petal_complete_midday_climate$mean_midday_temp)

# calling the evaporation function. Multiplying projected area by 4 for whole flower waterloss.
# function converts moles per meter squared to mmoles per meter squared and cm squared to meters squared
petal_complete_midday_climate$evaporation = evaporation(petal_complete_midday_climate$gswTotal, (petal_complete_midday_climate$p_projectedArea*4), petal_complete_midday_climate$mean_midday_VPD)

# calculating water loss in millimoles by multiplying evaporation by 2 hours (in seconds).
petal_complete_midday_climate$total_midday_waterloss = petal_complete_midday_climate$evaporation * 2 * 60 * 60

# converting millimoles to moles and then to grams
petal_complete_midday_climate$total_midday_waterloss_g = ((petal_complete_midday_climate$evaporation * 2 * 60 * 60) / 1000) * 18

# converting grams to milligrams
petal_complete_midday_climate$total_midday_waterloss_mg = (petal_complete_midday_climate$total_midday_waterloss_g)*1000

# Waterloss and Time Linear Regression
waterloss_week_lm = lm(evaporation~week, data = petal_complete_midday_climate)
summary(waterloss_week_lm)
waterloss_week_R2 = round(rsq(waterloss_week_lm),2)

# Waterloss and VPD Linear Regression
waterloss_vpd_lm = lm(evaporation~mean_midday_VPD, data = petal_complete_midday_climate)
summary(waterloss_vpd_lm)
waterloss_vpd_R2 = round(rsq(waterloss_vpd_lm),2)

# Waterloss and Petal Area Linear Regression
waterloss_area_lm = lm(evaporation~p_projectedArea, data = petal_complete_midday_climate)
summary(waterloss_area_lm)
waterloss_area_R2 = round(rsq(waterloss_area_lm),2)

# Waterloss relates to Petal Area and VPD Multiple Linear Regression
waterloss_area_vpd_lm = lm(evaporation~p_projectedArea + mean_midday_VPD, data = petal_complete_midday_climate)
summary(waterloss_area_vpd_lm)
waterloss_area_vpd_R2 = round(rsq(waterloss_area_vpd_lm),2)

# check model assumptions
plot(waterloss_area_vpd_lm)

print('Return') # workaround for the 'Hit <Return> to see next plot' prompt
print('Return')
print('Return')
print('Return')

# define the data frame for the graph, drop the NA values in the midday water loss column
waterloss_df = drop_na(petal_complete_midday_climate,total_midday_waterloss_mg)

# sort by VPD values, descending
waterloss_df = waterloss_df %>%
  arrange(desc(mean_midday_VPD))

# water loss and petal area
p17 = ggplot(waterloss_df, aes(x = p_projectedArea, y = evaporation
)) +
  geom_point(aes(
    color = mean_midday_VPD
  )) +
  geom_smooth(
    formula = y~x,
    color = 'black',
    method="lm",se=TRUE) +
  labs(y = "<i>E<sub>flower</sub></i> (mmol s<sup>-1</sup>)",
       x = "<i>A<sub>petal</sub></i> (cm<sup>2</sup>)") +
  guides(
    colour = guide_legend("VPD<sub>midday</sub>", order = 1),
    size = guide_legend("VPD<sub>midday</sub>", order =1),
    linetype = guide_legend("", order = 2)
  ) +
  geom_richtext(aes(x = 3.5, y = 0.002), 
                label = glue("<i>r</i><sup>2</sup> = {waterloss_area_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  theme_classic() +
  theme(axis.title.x = element_markdown(),legend.title = element_markdown(),
        axis.title.y = element_markdown()
  )

# water loss and date
p11 = ggplot(petal_complete_midday_climate, aes(x = Date, y = evaporation)) +
  geom_point(aes(
    color = p_projectedArea,
  ), 
  show.legend = FALSE) +
  geom_smooth(method="lm",se=TRUE, color = 'black') +
  labs(y = "<i>E<sub>flower</sub></i> (mmol s<sup>-1</sup>)") +
  geom_richtext(aes(x = as.Date('2025-06-14'), y = 0.002), 
                label = glue("<i>r</i><sup>2</sup> = {waterloss_week_R2}*"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  scale_color_continuous(palette =
                           c("#fed976","#feb24c","#fd8d3c","#e54726","#e31a1c","#bd0026","#800026"),
                         limits = c(1,17)) +
  theme_classic() +
  theme(axis.title.y = element_markdown(),
        axis.title.x = element_markdown())

# water loss and mean midday VPD
p12 = ggplot(petal_complete_midday_climate, aes(x = mean_midday_VPD, y = evaporation)) +
  geom_point(aes(
    color = p_projectedArea,
  )) +
  geom_smooth(method="lm",se=TRUE, color = 'black') +
  labs(y = NULL,
       x = "Mean midday VPD (kPa)") +
  geom_richtext(aes(x = 4.75, y = 0.002), 
                label = glue("<i>r</i><sup>2</sup> = {waterloss_vpd_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  scale_color_continuous(palette =
                           c("#fed976","#feb24c","#fd8d3c","#e54726","#e31a1c","#bd0026","#800026"),
                         limits = c(1,17)) +
  guides(
    colour = guide_legend("<i>A<sub>petal</sub></i>"),
    size = guide_legend("<i>A<sub>petal</sub></i>")
  ) +
  theme_classic() +
  theme(legend.title = element_markdown())

# panels and legend
waterloss_scatter = p11 + p12 + p17 +
  guide_area() +
  plot_annotation(tag_levels = "A") +
  plot_layout(ncol = 2, guides = "collect") & 
  theme(legend.direction = 'horizontal', 
        legend.text.position = 'bottom',
        legend.box.just = 'right'
  )

# export
export_png('figures/waterloss_scatter.png', waterloss_scatter)