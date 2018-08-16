function [] = rdt_deletebutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

rex_make_bad_trial( rdt_filename, rdt_trialnumber );

rdt_displaytrial;