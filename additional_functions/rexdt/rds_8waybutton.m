function [] = rds_8waybutton

global rds_allsacangles;
global rds_allsacamps;
global rds_fh;
global rds_filename;
global rds_includeaborted;

rex_8direction_saccade_analysis( rds_filename, 200, 200, 5, rds_includeaborted );