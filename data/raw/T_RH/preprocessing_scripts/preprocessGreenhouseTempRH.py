import pandas as pd
import numpy as np
import datetime as dt
import chardet
import subprocess
import os

# Arguments to be passed to the called script
week1 = "../EZ_log/greenhouse_wk1.csv"
week2 = "../EZ_log/greenhouse_wk2.csv"
week3 = "../EZ_log/greenhouse_wk3.csv"
week4 = "../EZ_log/greenhouse_wk4.csv"
week5 = "../EZ_log/greenhouse_wk5.csv"
week6 = "../EZ_log/greenhouse_wk6.csv"
week7 = "../EZ_log/greenhouse_wk7.csv"
week8 = "../EZ_log/greenhouse_wk8.csv"
week9 = "../EZ_log/greenhouse_wk9.csv"
week10 = "../EZ_log/greenhouse_wk10.csv"
week11 = "../EZ_log/greenhouse_wk11.csv"
week12 = "../EZ_log/greenhouse_wk12.csv"
week13 = "../EZ_log/greenhouse_wk13.csv"
week14_15_16 = "../EZ_log/greenhouse_wk14_15_16.csv"
week17 = "../EZ_log/greenhouse_wk17.csv"
week18 = "../EZ_log/greenhouse_wk18.csv"
week19 = "../EZ_log/greenhouse_wk19.csv"

# making a list of all the filepaths
EZ_log = [week1, week2, week3, week4, week5, week6, week7, week8, week9, week10, week11, week12, week13, week14_15_16, week17, week18, week19]

# deleting the output csv to prevent data duplication
if os.path.exists('../atmosphere_greenhouse.csv'):
  os.remove('../atmosphere_greenhouse.csv')

# Run the called script with arguments
for filepath in EZ_log:
	subprocess.run(['python', 'combineGreenhouseTempRH.py', filepath])

# loading the data files
csv = pd.read_csv('../atmosphere_greenhouse.csv')

# inserting an empty daynight column.
csv.insert(1, 'daynight', '')

# I also converted the time column values to datetimes.
csv['Time'] = pd.to_datetime(csv['Time'])

# rename time to datetime_PDT
csv = csv.rename(columns={'Time': 'Datetime_PDT'})

# time_PDT = time from the datetime_PDT
csv['Time_PDT'] = csv['Datetime_PDT'].dt.time

# adding columns for when temperature threshholds changed
# In 2025, daylight savings ended on November 2nd at 2am. 
# The sensor data matched with the clock on my laptop, so the time change to pacific standard time was delayed in my data to after 12:42pm on 11/6/2025.
# The greenhouse was aware of the time shift however, so the daytime/nighttime threshhold adjusted with the clock change.
# As such, I do not adjust for daylight savings when defining day and night thresholds

# defining the day and night thresholds
sunrise = dt.time(hour=6, minute=30)
sunset = dt.time(hour=21, minute=0)

# binning each observation into day and night
for i in range(0, len(csv)):
	time = csv.loc[i, 'Time_PDT']
	if time < sunrise:
		csv.loc[i, 'daynight'] = 'night'
	if time >= sunrise and time < sunset:
		csv.loc[i, 'daynight'] = 'day'
	if time >= sunset:
		csv.loc[i, 'daynight'] = 'night'

# make a PST datetime column
csv['Datetime_PST'] = csv['Datetime_PDT']

# Whats weird about 'falling back' from DST is that it looks like time is repeating itself--somewhat like Groundhog Day with Tom Hanks.
# Because of the timeshift, between 11:42am and 11:45am an extra hour of 12pm magically appears in my data.
# delayed DST should be defined as 11:42am

# initialize a counter
# if time is greater than or equal to nov 6 at 12pm and less then 1pm
# 	then counter plus equal 1
# 	if counter is less than 3
# 		convert to PST 

# define the delayed DST date
delayed_DST = dt.datetime(2025, 11, 6, hour=11, minute=42)
twelve_o_clock_Nov6 = dt.datetime(2025, 11, 6, hour=12, minute=00)
one_o_clock_Nov6 = dt.datetime(2025, 11, 6, hour=13, minute=00)

# initializing the counter
counter = 0

# converting PDT to PST
for i in range(0, len(csv)):
	if csv.loc[i, 'Datetime_PST'] <= delayed_DST:
		csv.loc[i, 'Datetime_PST'] = csv.loc[i, 'Datetime_PST'] - dt.timedelta(hours=1)
	if csv.loc[i, 'Datetime_PST'] >= twelve_o_clock_Nov6 and csv.loc[i, 'Datetime_PST'] < one_o_clock_Nov6:
		counter += 1
		if counter < 3:
			csv.loc[i, 'Datetime_PST'] = csv.loc[i, 'Datetime_PST'] - dt.timedelta(hours=1)

print(csv.head())

# output csv
csv.to_csv('../atmosphere_greenhouse.csv',index=False)