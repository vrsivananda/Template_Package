# Documentation
This package created as a template to extract and plot monkey electrophysiology data.

## How to use this package

The way to use this package is, for any new project:
(1) Download the template
(2) Key in the parameters in master_script
(3) Run master_script
(4) Use this folder for one experiment ONLY. Use a fresh template for another experiment.

Each experiment should have its own folder. Any tweaks that are specific to the experiment itself should be done locally on a copy of the template. 
Avoid passing your own tweaked package and giving it to someone else for another experiment because errors and experiment-specific tweaks will accumulate and code will be very hard to debug.
Extensions to the template should be generalizable to other experiments.

## Folder Structure
There are 4 folders in this package:
1. `core_functions`
   - This is where the 4 main functions of this package are located.
2. `additional_functions`
   - This is where any extra functions that are called in `core_functions` is located.
3. `data_files`
   - This is where the original .nev file should be placed.
   - All intermediate data files (e.g. rasterData, alignedData, etc.) are also saved here.
4. `figures`
   - This is where the figures that are generated are saved.



## Parameters

The master_script where all other scripts are called. Ideally, the user will only need to interface with this script.

|Parameter|Data Type| Descripton|
|---------|---------|-----------|
|run_x1_nev_to_mat|boolean|Determines if we want to convert the `.nev` to a `.mat` file. Once we have done this once, we don't have to do it again. The output is a `.mat` file saved in the `data_files` folder.|
|run_x2_mat_to_rasterData|boolean|Determines if we want to convert the `.mat` file to rasterData. The output is a `rasterData.mat` file saved in the `data_files` folder.|
|run_x3_rasterData_to_alignedData|boolean|Determines if we want to convert the `rasterData` to `alignedData`. The output is a `alignedData.mat` file saved in the `data_files` folder.|
|run_x4_alignedData_to_plot|boolean|Determines if we want to plot the aligned data. The output are `.jpg` files saved in the `figures` folder.|
|filename|character array|The name of the file without the extension (e.g. `'SP170126B'`). This is the file that we will be processing and plotting the entire time.|
|eCodes_fields_entries|cell array|n-by-3 cell array where n is the number of eCodes.
-Each row is a seperate eCode.
-First column corresponds to the eCode 
-Second column corresponds to the fieldname in the rasterData that corresponds to that eCode
-Third column corresponds to the value for that fieldname.
Use `'time'` in the third column if you want the column to contain the time that the eCode was dropped.|
|toRF_parameters|cell array|n-by-2 cell array where n is the number of fields in rasterData used to determine if the saccade in each trial was towards or away from the receptive field
- First column is the fieldname
- Second column is the value in the fieldname
All the values in both columns match within a trial, then it is determined that the saccade was towards the receptive field.|
|alignmentBuffer|double|This is a buffer (in milliseconds) that is placed during smoothing to ensure that artifacts during smoothing do not enter the relevant time frames. This can typically be left as `100`.|
|alignment_parameters|cell array|n-by-3 cell array where n is the number of events that we want to plot.
- First column corresponds to the fieldname that is aligned in the plot (i.e. timing for the fieldname is set as 0ms in the plot). Each trial is aligned to this time for plotting.
- Second column corresponds to the start of the plot in ms (i.e. the time before 0ms that we want to see)
- Third column corresponds to the end of the plot in ms (i.e. the time after 0ms that we want to see)|
|error_fields|cell array|n-by-1 cell array where n is the number of error types.
- Column is the fieldname of the error field
If a trial has a value in any of these fieldnames, then it is discarded and not processed.|
|sigma|double|The smoothing parameter to be used in the kernel. Default is `0.01`.|
|RF_fields_to_plot|cell array|n-length cell array.
Each entry is a fieldName to plot. Default is `{'toRF', 'awayRF'}`. |
|yMax|double|The height of the plots, in spikes/second.|
|saveFigure|boolean|Whether or not to save the figure as a jpg file. The output is saved in the folder `figures`.|