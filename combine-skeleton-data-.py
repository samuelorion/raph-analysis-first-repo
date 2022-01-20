"""
file:           was called 2. combineAllExcelFilesIntoOne.py
author:         Alex Tchung (modified by Sam Burke 2022-01-20)
info:           Combine the raw data coming from analyze skeleton (csvs) (from what was 1. tracing.ijm)
                into one csv file, and adding multiple rows in sigle csv when there are more than one object segmented (ie background in iamges).
instructions:   Open terminal. Type "python " (with the space) and drag and drop 2. combineAllExcelFilesIntoOne.py in the terminal. Press enter. The Excel file should be created
"""

import os, glob
import pandas as pd

#masterDir = os.path.dirname(__file__)  # get the directory of this file and allows you to use relative paths # if you want to use relative paths, modify code. For now, use absolute paths
dataInput = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis/skeleton-output" # directory of raw data — note you will need to change this to your own directory
dataOutput = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis/cleaned-data" # directory of combined data — note you will need to change this to your own directory

all_files = glob.glob(os.path.join(dataInput, "*.csv")) # get all the csv files in the directory

all_df = [] # create an empty list
for f in all_files: # loop through all the files
    df = pd.read_csv(f, sep=',') # Read the CSV file and seperate values by ","
    df['Slice'] = f.split('/')[-1].split('_')[-1].split('.')[-2] # Cleanup the Slice number
    del df[df.columns[0]] # Remove the first columns
    all_df.append(df) 
    
df_merged = pd.concat(all_df, ignore_index=True, sort=True)

df_merged.to_csv(dataOutput + "combinedData.csv")