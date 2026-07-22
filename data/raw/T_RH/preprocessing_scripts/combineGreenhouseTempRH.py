import pandas as pd
import numpy as np
import os
import sys
import chardet

# loading the data files
file = sys.argv[1]
print(f"Arguments received: {file}")
csv = pd.read_csv(file, encoding = 'ISO-8859-1')

# defining the master copy, the data frame where the csv will be added to.
if os.path.exists('../atmosphere_greenhouse.csv'): #(or os.path.isfile())
	master = pd.read_csv('../atmosphere_greenhouse.csv')

# dropping first column, a duplicate index.
csv = csv.iloc[0:, 1:]

# renaming dew point column to remove the degrees symbol... otherwise the Â symbol gets added in for some reason
csv.rename(columns={'Dew Point(°C)': 'Dew Point(C)'}, inplace=True)

# merge csv and master
if os.path.exists('../atmosphere_greenhouse.csv'):
	master = pd.concat([master, csv])
else:
	master = csv

print(master.tail())

# output master as a csv
master.to_csv('../atmosphere_greenhouse.csv',index=False)