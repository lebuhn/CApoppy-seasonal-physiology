import pandas as pd
import numpy as np
import os
import sys

# loading the data files
file = sys.argv[1]
print(f"Arguments received: {file}")
csv = pd.read_csv(file)

# defining the master copy, the data frame where the csv will be added to. 
if os.path.exists('../atmosphere_MtDiablo.csv'):
	master = pd.read_csv('../atmosphere_MtDiablo.csv')

# dropping first column, a duplicate index.
csv = csv.iloc[0:, 1:]

# merge csv and master
if os.path.exists('../atmosphere_MtDiablo.csv'):
	master = pd.concat([master, csv])
else:
	master = csv

print(master.tail())

# output master as a csv
master.to_csv('../atmosphere_MtDiablo.csv',index=False)