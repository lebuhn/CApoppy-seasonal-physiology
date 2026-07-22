# load data
source("analysis/load_data.R", local = TRUE, chdir = FALSE)

# flower count column graph
flowercount_columns = ggplot(flowercount, aes(x = date, y = flower_count, fill = rep)) +
  geom_col(show.legend = FALSE) + 
  xlab("Date") +
  ylab("Number of flowers") +
  scale_fill_distiller(palette = 'Oranges') + 
  theme_classic()

# export png to file
export_png('figures/flowercount_columns.png', flowercount_columns)

# initializing an empty data frame
reproductive_output <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(reproductive_output) <- c('rep', 'flowerTotal')

# filtering out counts past April 22
flowercount_April22 = filter(flowercount, date<as.Date('2025-04-29'))

# adding the reproductive output of each plant to the data frame
for (n in seq(1,20)) {
  f_total = sum(flowercount_April22[which(flowercount_April22$rep==n), 6])
  reproductive_output[nrow(reproductive_output) + 1,] = c(n,f_total)
}

# merge flower production and plant radius data
reproductive_output = merge(reproductive_output, plantsize)

# convert meters to cm
reproductive_output$radius_cm = reproductive_output$radius_m*100

# creating a range of plant radius values to model
radius_cm = seq(5, 30, 0.5)
radius_df = data.frame(radius_cm)
reproductive_output = merge(reproductive_output, radius_df, by = c('radius_cm'), all = TRUE)

# linear regression
reproductive_output_lm = lm(log10(flowerTotal)~log10(radius_cm), data = reproductive_output)
summary(reproductive_output_lm)

# glm with a zero-truncated Poisson distribution
reproductive_output_glm = glm(flowerTotal~radius_cm, family = Tpoisson(), data = reproductive_output)
check_overdispersion(reproductive_output_glm)

# negative binomial with glm.nb
reproductive_output_glm.nb = glm.nb(flowerTotal~radius_cm, data = reproductive_output)
AIC(reproductive_output_glm.nb,reproductive_output_lm)

# zero-truncated negative binomial with vglm
reproductive_output_vglm = vglm(flowerTotal~radius_cm, family = posnegbinomial(), data = reproductive_output)
AIC(reproductive_output_vglm)

# truncated negative binomial with glmmTMB
reproductive_output_glmmTMB = glmmTMB(flowerTotal~radius_cm, family = truncated_nbinom1, data = reproductive_output)
AIC(reproductive_output_glmmTMB, reproductive_output_lm)

# extracting coefficients and r-squared
repro_output_coeff = reproductive_output_lm$coefficients
repro_output_slope = round(as.numeric(repro_output_coeff[2]),2)
repro_output_intercept = round(as.numeric(repro_output_coeff[1]),2)
repro_output_R2 = round(rsq(reproductive_output_lm),2)

# predicting total flowers from plant size
reproductive_output = log_predict(reproductive_output_lm, reproductive_output, 'flowerTotal')

# log scale scatterplot of plant radius vs total number of flowers
flowercount_scatter = ggplot(reproductive_output, aes(x=radius_cm,y=flowerTotal)) + 
  geom_point() +
  xlab("Plant radius (cm)") +
  ylab("Total number of flowers")+
  geom_richtext(aes(x = 17, y = 1.5), 
                label = glue("log<sub>10</sub><i>y</i> = {repro_output_slope} ∙ log<sub>10</sub><i>x</i> - {-1*repro_output_intercept}"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  geom_richtext(aes(x = 7, y = 50), 
                label = glue("<i>r</i><sup>2</sup> = {repro_output_R2}***"),
                fill = NA, label.color = NA,
                label.padding = grid::unit(rep(0, 4), "pt")
  ) +
  scale_y_log10() +
  scale_x_log10() +
  geom_smooth(method="lm",se=TRUE) +
  theme_classic()

export_png('figures/flowercount_scatter.png', flowercount_scatter)