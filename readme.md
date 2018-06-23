# Template Package


### data_files
This folder contains ALL the data files. 
<br>-`.nev` files will be placed here for analysis. 
<br>-All other data files that are generated downstream (e.g. `.mat` files) will also be saved here.

### convert_NEV_to_mat
This folder contains the files that read in the .nev files and outputs a corresponding `.mat` raw data file to the data_analysis folder.
<br>-The file that should be run here is `convert_NEV_to_mat.m`.

### generate_raster_data
This folder contains the file that generates the raster data from the `.mat` raw data file.
<br> Notes:
<br> * For the `TGinRF` field in raster data, `1` means  that TG was in RF, `-1` means that TG was not in RF, and `0` means that the trial was aborted.