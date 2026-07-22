import pandas as pd
import numpy as np
import datetime as dt
import astral
from astral import LocationInfo
from astral.sun import sun
import subprocess
import os

# Arguments to be passed to the called script
week3 = "../EZ_log/PlotA_week3.csv"
week4 = "../EZ_log/PlotA_week4.csv"
week5 = "../EZ_log/PlotA_week5.csv"
week8 = "../EZ_log/PlotA_week8.csv"
week10 = "../EZ_log/PlotA_week10.csv"
week11 = "../EZ_log/PlotA_week11.csv"
week12 = "../EZ_log/PlotA_week12.csv"
week13 = "../EZ_log/PlotA_week13.csv"
week14 = "../EZ_log/PlotA_week14.csv"
week15 = "../EZ_log/PlotA_week15.csv"
week16 = "../EZ_log/PlotA_week16.csv"
week17 = "../EZ_log/PlotA_week17.csv"
week18 = "../EZ_log/PlotA_week18.csv"
week19 = "../EZ_log/PlotA_week19.csv"
single_datapoints = "../EZ_log/single_datapoints.csv"

# making a list of all the filepaths
EZ_log = [week3, week4, week5, week8, week10, week11, week12, week13, week14, week15, week16, week17, week18, week19, single_datapoints]

# deleting the output csv to prevent data duplication
if os.path.exists('../atmosphere_MtDiablo.csv'):
  os.remove('../atmosphere_MtDiablo.csv')

# Run the called script with arguments
for filepath in EZ_log:
	subprocess.run(['python', 'combineMountDiabloTempRH.py', filepath])

#defining the site
site = LocationInfo("Mount Diablo, Site A", "USA", "US/Pacific", 37.882242, -121.970762)
print((
    f"Information for {site.name}/{site.region}\n"
    f"Timezone: {site.timezone}\n"
    f"Latitude: {site.latitude:.02f}; Longitude: {site.longitude:.02f}\n"
))

#defining the timezone
timezone = astral.zoneinfo.ZoneInfo("US/Pacific")

# reading in the atmosphere csv file and inserting an empty column.
# I also converted the Time column values to datetimes.
csv = pd.read_csv('../atmosphere_MtDiablo.csv')
csv.insert(1, 'daynight', '')
csv['Time'] = pd.to_datetime(csv['Time'])

# defining a new data column binning observations into day and night. Correcting for delayed daylight savings error (EZ log timestamp updated by laptop on March 11) in the dataframe.
for i in range(0, len(csv)):
	if csv.iat[i,0] >= dt.datetime(2025, 3, 9, hour=2, minute=0) and csv.iat[i,0] <= dt.datetime(2025, 3, 11, hour=9, minute=38):
		awaredt = csv.iat[i,0].replace(tzinfo=timezone)
		date = dt.datetime.date(csv.iat[i,0])
		sunrise = astral.sun.sunrise(site.observer, date=date, tzinfo=timezone)
		sunrise = sunrise - dt.timedelta(hours=1)
		sunset = astral.sun.sunset(site.observer, date=date, tzinfo=timezone)
		sunset = sunset - dt.timedelta(hours=1)
		if awaredt < sunrise:
			csv.iat[i,1] = 'night'
		if awaredt >= sunrise and awaredt <= sunset:
			csv.iat[i,1] = 'day'
		if awaredt > sunset:
			csv.iat[i,1] = 'night'
	else:
		awaredt = csv.iat[i,0].replace(tzinfo=timezone)
		date = dt.datetime.date(csv.iat[i,0])
		sunrise = astral.sun.sunrise(site.observer, date=date, tzinfo=timezone)
		sunset = astral.sun.sunset(site.observer, date=date, tzinfo=timezone)
		if awaredt < sunrise:
			csv.iat[i,1] = 'night'
		if awaredt >= sunrise and awaredt <= sunset:
			csv.iat[i,1] = 'day'
		if awaredt > sunset:
			csv.iat[i,1] = 'night'		

# output
print(csv.head())
csv.to_csv('../atmosphere_MtDiablo.csv',index=False)