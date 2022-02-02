"""
file:                   2. combineAllExcelFilesIntoOne.py
author:                 Alex Tchung

info:                   Combine the rawData (Excel files) from 1. tracing.ijm into a master file Excel for easier data manipulation and simpler analysis.

instructions:           Open terminal. Type "python " (with the space) and drag and drop 2. combineAllExcelFilesIntoOne.py in the terminal. Press enter. The Excel file should be created

Changelog v1.02 :       2022-01-27 - Add rolling average, derivative to calculate speed every x slices, export plot as jpeg, enable timelaps cropping (start & end) and automatically calculate arborisation growth speed.

Changelog v1.01:        2022-01-25 - Apply operations on the variables. Combine all ROI in each slice and sort the slices. Fix the problem with erasing the rawdata when an error occured.
"""

from ast import Or
import os, glob
import pandas as pd
import csv
import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import interp1d
from scipy.misc import derivative
import math

masterDir = os.path.dirname(__file__)
dataInput = masterDir + "/rawData/"
dataOutput = masterDir + "/combinedData/"
if os.path.exists(dataInput) == 0:
	os.mkdir(dataInput)
if os.path.exists(dataOutput) == 0:
	os.mkdir(dataOutput)

all_files = glob.glob(os.path.join(dataInput, "*.csv"))
all_df = []

# Run once to get the plot and check irregularities
# Run again with start and end x value. Those are for the minutes (time) to remove at the start and end of the timelaps. Use 0 for the first run and check plot.jpg to know if you need to remove anything
x_start = int(input('Minutes to remove from the start of the timelaps (use 0 for the first run): '))
x_end = int(input('Minutes to remove at the end of the timelaps (use 0 for the first run): '))
TimeBetweenSlice = int(input('Time between each slice (in minutes): ')) # Ask for user input for time between each slice

for f in all_files: # For all Excel files in /rawData/
    # Check if file as headers
    with open(f, 'r') as csvfile:
        try:
            df = pd.read_csv(f, sep=',') # Read the CSV file and seperate values by ","
            df['Slice'] = f.split('/')[-1].split('_')[-1].split('.')[-2] # Cleanup the Slice number
            df['Slice'] = pd.to_numeric(df['Slice'], errors='coerce') # Convert data type from strings to numbers
            del df[df.columns[0]] # Remove the first index column for the ROI number 
            df['# Branches'] = df['# Branches'].sum() # Sum values for those parameters
            df['# End-point voxels'] = df['# End-point voxels'].sum()
            df['# Junction voxels'] = df['# Junction voxels'].sum()
            df['# Junctions'] = df['# Junctions'].sum()
            df['# Quadruple points'] = df['# Quadruple points'].sum()
            df['# Slab voxels'] = df['# Slab voxels'].sum()
            df['# Triple points'] = df['# Triple points'].sum()
            df['Average Branch Length'] = df['Average Branch Length'].mean() # Get the mean
            df['Maximum Branch Length'] = df['Maximum Branch Length'].max() # Get the max
            df = df.drop_duplicates(subset=['Slice']) # Delete duplicates rows (old ROIs)
            df['Time elapsed'] = (df['Slice'] * TimeBetweenSlice) - 2 # Get the time elapsed in minutes
            df['Total length'] = df['# Branches'] * df['Average Branch Length'] # Get the total arborisation length
            all_df.append(df) # Append the new slice to the array with all the slices
    
        except: # If an error occurs, run this. This is required for try.
            print('Error.')

df_merged = pd.concat(all_df, ignore_index=True, sort=True) # Concatenate the dataframe
df_merged = df_merged.sort_values(by='Slice') # Sort
df_merged['Rolling Average'] = df_merged['Total length'].rolling(15).mean() # Calculate the rolling average on the final dataframe

if x_end != 0 : # If user has input for cropping the timelaps, crop here.
    x_end = math.trunc(x_end/TimeBetweenSlice)
    df_merged = df_merged.iloc[:-x_end] # Remove slices at the end of the timelaps
if x_start != 0 : # If user has input for cropping the timelaps, crop here.
    x_start = math.trunc(x_start/TimeBetweenSlice)
    df_merged = df_merged.iloc[x_start:] # Remove slices at the start

#df_merged.loc[df_merged.index[0], 'Max overall speed (microns/min)'] = (df_merged['Total length'].max() - df_merged['Total length'].min()) / (df_merged.index[df_merged['Total length'].max() == df_merged['Total length'].max()]) # Add a column for maximum overall speed (biggest arborisation - smallest).

###
# Old plot code
###
# fig = plt.figure(figsize=(10,5)) # Setting the figure size

# plt.plot(df_merged['Time elapsed'], df_merged['Total length'], label = "Total length") # Plot the first plot 
# plt.plot(df_merged['Time elapsed'], df_merged['Rolling Average'], label = "Rolling average of the total length") # Plot the second plot 
  
# plt.xlabel('Time elapsed (minute)') # Name for the X axis 
# plt.ylabel('Arborisation length (px)') # Name for the Y axis 
# plt.title('Total arborisation length with and without rolling average') # Graph's title
# plt.legend() # Show a legend on the plot
###
# End of old plot code
###

# Simple interpolation of x and y    
f = interp1d(df_merged['Time elapsed'], df_merged['Rolling Average'])
x_fake = np.arange(df_merged['Time elapsed'].min() + 0.1, df_merged['Time elapsed'].max(), 30) # I can change the step (25) so it takes the derivative every x slice

df_dx = derivative(f, x_fake, dx=1e-6) # derivative of y with respect to x

# Plot
fig = plt.figure()
ax1 = fig.add_subplot(211)
ax2 = fig.add_subplot(212)

ax1.errorbar(df_merged['Time elapsed'], df_merged['Rolling Average'], fmt="o", color="blue")
ax1.errorbar(x_fake, f(x_fake), lw=2)
ax1.set_xlabel("Elapsed time (min)")
ax1.set_ylabel("Arborisation length (px)")

ax2.errorbar(x_fake, df_dx, lw=2)
ax2.errorbar(x_fake, np.array([0 for i in x_fake]), lw=2)
ax2.set_xlabel("Elapsed time (min)")
ax2.set_ylabel("Arborisation growth speed (px/min)")

leg = ax1.legend(loc=2, numpoints=1, scatterpoints=1)
leg.draw_frame(False) # Draw frame around the legend
fig.tight_layout() # Set the spacing between the subplots
fig.savefig(dataOutput + 'plot.jpg', bbox_inches = 'tight', dpi = 150) # Save the plot as an image
# End of plot

# Export fastest growth and degeneration
df_dx = df_dx[np.logical_not(np.isnan(df_dx))]
df_merged.loc[df_merged.index[0], 'Fastest growth (microns/min)'] = np.max(df_dx)
df_merged.loc[df_merged.index[0], 'Fastest degeneration (microns/min)'] = np.min(df_dx)
df_merged.loc[df_merged.index[0], 'Mean growth (microns/min)'] = np.mean(df_dx)

df_merged.to_csv(dataOutput + "combinedData.csv") # Export the dataframe as an Excel
print("Raw data successfully combined! Thank you for using me and have a nice day.")