import pandas as pd
import numpy as np
import subprocess
import os

# Arguments to be passed to the called script
md_week1 = "../2025-02-25/Petals barcode_Shea Nolan_2025_03_10_13_08_07_1.csv"
md_week2 = "../2025-03-04/Petals barcode_Shea Nolan_2025_03_10_13_08_07_1.csv"
md_week3 = "../2025-03-11/Petals barcode_Shea Nolan_2025_03_18_17_10_44_1.csv"
md_week4 = "../2025-03-18/Petals barcode_Shea Nolan_2025_03_18_17_10_44_1.csv"
md_week5 = "../2025-03-25/Petals MtDiablo_Shea Nolan_2025_03_25_16_27_22_1.csv"
md_week6 = "../2025-04-03/Petals MtDiablo_Shea Nolan_2025_04_03_16_35_58_1.csv"
md_week7 = "../2025-04-08/Petals MtDiablo_Shea Nolan_2025_04_08_15_42_16_1.csv"
md_week8 = "../2025-04-15/Petals MtDiablo_Shea Nolan_2025_04_15_16_22_17_1.csv"
md_week9 = "../2025-04-22/Petals low flow_Shea Nolan_2025_04_22_20_29_29_1.csv"
md_week11 = "../2025-05-06/Petals low flow_Shea Nolan_2025_05_06_17_32_09_1.csv"
md_week12 = "../2025-05-13/Petals low flow_Shea Nolan_2025_05_13_17_41_17_1.csv"
md_week13 = "../2025-05-20/Petals low flow_Shea Nolan_2025_05_22_18_28_20_1.csv"
md_week14 = "../2025-05-28/Petals low flow_Shea Nolan_2025_05_28_17_19_50_1.csv"
md_week15 = "../2025-06-04/Petals low flow_Shea Nolan_2025_06_06_14_47_42_1.csv"
md_week16 = "../2025-06-10/Petals low flow_Shea Nolan_2025_06_12_16_05_01_1.csv"
md_week17 = "../2025-06-17/Petals low flow_Shea Nolan_2025_06_17_14_48_21_1.csv"
md_week18 = "../2025-06-25/Petals low flow_Shea Nolan_2025_06_25_14_59_25_1.csv"

gh_week1 = "../2025-09-25/Petals low flow_Shea Nolan_2025_09_25_16_18_59_1.csv"
gh_week2 = "../2025-10-02/Petals low flow_Shea Nolan_2025_10_02_15_03_34_1.csv"
gh_week3 = "../2025-10-09/Petals low flow_Shea Nolan_2025_10_09_11_07_20_1.csv"
gh_week4 = "../2025-10-17/Petals low flow_Shea Nolan_2025_10_17_14_08_54_1.csv"
gh_week5 = "../2025-10-23/Petals low flow_Shea Nolan_2025_10_23_11_47_14_1.csv"
gh_week6 = "../2025-10-30/Petals low flow_Shea Nolan_2025_10_30_15_01_05_1.csv"
gh_week7 = "../2025-11-06/Petals low flow_Shea Nolan_2025_11_06_14_08_31_1.csv"
gh_week8 = "../2025-11-14/Petals low flow_Shea Nolan_2025_11_14_15_32_20_1.csv"
gh_week9 = "../2025-11-20/Petals low flow_Shea Nolan_2025_11_20_13_48_50_1.csv"
gh_week10 = "../2025-11-26/Petals low flow_Shea Nolan_2025_11_26_16_33_17_1.csv"
gh_week11 = "../2025-12-04/Petals low flow_Shea Nolan_2025_12_04_15_05_56_1.csv"
gh_week12 = "../2025-12-11/Petals low flow_Shea Nolan_2025_12_11_15_09_50_1.csv"
gh_week13 = "../2025-12-18/Petals low flow_Shea Nolan_2025_12_18_15_19_45_1.csv"
gh_week16 = "../2026-01-09/Petals low flow_Shea Nolan_2026_01_09_15_40_36_1.csv"
gh_week17 = "../2026-01-16/Petals low flow_Shea Nolan_2026_01_16_15_28_55_1.csv"
gh_week18 = "../2026-01-23/Petals low flow_Shea Nolan_2026_01_23_15_46_59_1.csv"

# making a list of all the filepaths
porometer = [md_week1, md_week2, md_week3, md_week4, md_week5, md_week6, md_week7, md_week8, md_week9, md_week11, md_week12, md_week13, md_week14, md_week15, md_week16, md_week17, md_week18, 
	gh_week1, gh_week2, gh_week3, gh_week4, gh_week5, gh_week6, gh_week7, gh_week8, gh_week9, gh_week10, gh_week11, gh_week12, gh_week13, gh_week16, gh_week17, gh_week18]

# deleting the output csv to prevent data duplication
if os.path.exists('../porometer_preprocess.csv'):
  os.remove('../porometer_preprocess.csv')

# Run the called script with arguments
for filepath in porometer:
	subprocess.run(['python', 'combineCSV.py', filepath])