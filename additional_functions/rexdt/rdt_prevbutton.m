function [] = rdt_prevbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_includeaborted;


rdt_trialnumber = rex_prev_trial( rdt_filename, rdt_trialnumber, rdt_includeaborted );

rdt_displaytrial;