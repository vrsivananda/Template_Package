# Template Package


### data_files
This folder contains ALL the data files. 
.nev files will be placed here for analysis. 
All other data files that are generated downstream (e.g. .mat files) will also be saved here.

### convert_NEV_to_mat
This folder contains the files that read in the .nev files and outputs a corresponding .mat file to the data_analysis folder.
The file that should be run here is `convert_NEV_to_mat.m`.