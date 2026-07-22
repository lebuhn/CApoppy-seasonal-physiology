library(tidyverse)
library(rstatix)
library(car)
library(dplyr)
library(lubridate)
library(glue)
library(lme4)
library(lmerTest)
library(merTools)
library(emmeans)
library(plotly)
library(patchwork)
library(ggtext)
library(rsq)
library(performance)
library(spaMM)
library(VGAM)
library(glmmTMB)

# a function that accepts a log-log linear model, the data frame associated with the model, and a character string for the predicted variable name. Outputs the dataframe with predicted columns.
log_predict = function(lm, df, y) {
  
  # call the predict function with the log-log model, and log transformed x values.
  log_predicted = predict.lm(lm, df, interval = 'confidence')
  df = cbind(df, log_predicted)
  
  # make a new column that takes the anti log of the predicted values and confidence intervals
  df$fit2 = 10^(df$fit)
  df$lwr2 = 10^(df$lwr)
  df$upr2 = 10^(df$upr)
  
  names(df)[names(df) == 'fit'] <- glue('log_{y}_fit')
  names(df)[names(df) == 'lwr'] <- glue('log_{y}_lwr')
  names(df)[names(df) == 'upr'] <- glue('log_{y}_upr')
  
  names(df)[names(df) == 'fit2'] <- glue('{y}_fit')
  names(df)[names(df) == 'lwr2'] <- glue('{y}_lwr')
  names(df)[names(df) == 'upr2'] <- glue('{y}_upr')
  
  return(df)
}

# defining a VPD function using the Arden Buck equation
vpd = function(RH, Temp) {
  output = (1 - (RH/100)) * (0.61121 * exp((17.502*Temp)/(240.97+Temp)))
  return(output)
}

# defining an evaporation function. Includes unit conversions: VPD as a ratio of 1 standard atmosphere (in kPa), moles per meter squared to millimoles per meter squared, and cm squared to meters squared (conversion factor is 0.01^2).
evaporation = function(gsw, surface_area, VPD) {
  output = (VPD/101.325) * (gsw * 1000) * (surface_area * 0.0001)
  return(output)
}

# defining a function that returns climate averages for a user defined time-window using a dataframe of daily temp and VPD values.
climatenorm = function(df, envelope) {
  
  # initializing an empty data frame
  envelope_avg <- data.frame(matrix(ncol = 13, nrow = 0))
  colnames(envelope_avg) <-   c('Date',glue('vpdmin_{envelope}daymean_kPa'),glue('vpdmin_{envelope}daysd_kPa'),glue('vpd_{envelope}daymean_kPa'),glue('vpd_{envelope}daysd_kPa'),glue('vpdmax_{envelope}daymean_kPa'),glue('vpdmax_{envelope}daysd_kPa'),glue('tmin_{envelope}daymean_C'),glue('tmin_{envelope}daysd_C'),glue('t_{envelope}daymean_C'),glue('t_{envelope}daysd_C'),glue('tmax_{envelope}daymean_C'),glue('tmax_{envelope}daysd_C'))
  
  # initializing a list of datetimes
  datekey = list()
  
  # picking out the dates that match the envelope in the dataframe
  for (i in (seq_len(nrow(df)))) {
    my_date = df$Date[i]
    dateprior = my_date - days(envelope)
    dateprior = c(dateprior)
    if (dateprior %in% df$Date) {
      datepick = list(my_date)
      datekey = c(datekey, datepick)
    }
  }
  
  # calculate envelope climate means and add them to the empty dataframe
  for (date in datekey) {
    my_day = as_date(date)
    my_day_string = as.character(date)
    dayprior = my_day - days(envelope)
    window = df[df$Date >= dayprior & df$Date <= my_day,]
    tpool = c(window$tmin_C, window$tmax_C)
    vpdpool = c(window$vpdmin_kPa, window$vpdmax_kPa)
    envelope_avg[nrow(envelope_avg) + 1,] = c(my_day_string,mean(window$vpdmin_kPa),sd(window$vpdmin_kPa),mean(vpdpool),sd(vpdpool),mean(window$vpdmax_kPa),sd(window$vpdmax_kPa),mean(window$tmin_C),sd(window$tmin_C),mean(tpool),sd(tpool),mean(window$tmax_C),sd(window$tmax_C))
  }
  
  envelope_avg$Date = as_date(envelope_avg$Date)
  output = envelope_avg
  return(output)
}

export_png = function(filepath, plot) {
  print(plot)
  ggsave(filepath, width = 6.8, height = 4.2, units = 'in')
  
}

export_png2 = function(filepath, plot) {
  print(plot)
  ggsave(filepath, height = 6.8, width = 4.2, units = 'in')
}
