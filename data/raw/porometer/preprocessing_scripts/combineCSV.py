import pandas as pd
import numpy as np
import os
import sys

# loading the data files
file = sys.argv[1]
print(f"Arguments received: {file}")
csv = pd.read_csv(file, header = 1)

if os.path.exists('../porometer_preprocess.csv'): #(or os.path.isfile())
	master = pd.read_csv('../porometer_preprocess.csv')

# defining lists of all columns, desired columns, and undesired columns
headers = list(csv.columns.values)
#desiredColumns = ['Time','Date','Sample','Study plot','Petal side','gsw','leak_pct']
#undesiredColumns = []

# adding undesired columns to the empty list.
#for header in headers:
#	if header not in desiredColumns:
#		undesiredColumns += [header]
#print(undesiredColumns)

# dropping extraneous data
csv = csv.drop([0])
#csv = csv.drop(columns = undesiredColumns)
csv['leak_pct'] = pd.to_numeric(csv['leak_pct'])
csv = csv[csv['leak_pct'] < 5]

# testing whether the csv is from Mount Diablo or from the SFSU greenhouse
testMtDiablo = csv[csv['Study plot'] != 'C']

# dropping erroneous duplicates from Mount Diablo data, but keeping intentional replicates in greenhouse data
if len(testMtDiablo) != 0:
	csv = csv.drop_duplicates(subset = ['Sample','Petal side'], keep = 'last', ignore_index = True)

# adding the plant ID codes as a new column
csv['plant'] = csv['Sample'].astype(str)
csv['plant'] = csv['plant'].str.rjust(5, fillchar='#')
csv['plant'] = csv['plant'].str.slice(stop = 3)
csv['plant'] = csv['plant'].str.replace('##','#')

# merge csv and master
if os.path.exists('../porometer_preprocess.csv'):
	master = pd.concat([master, csv])
else:
	master = csv

# debug
#print(csv.head())
print(master.tail())
#print(type(csv.at[0, 'leak_pct']))
#csv.to_csv('porometer.csv',index=False)

# output master as a csv
master.to_csv('../porometer_preprocess.csv',index=False)