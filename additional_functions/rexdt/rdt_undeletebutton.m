function [] = rdt_undeletebutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

rex_make_good_trial( rdt_filename, rdt_trialnumber );

rdt_displaytrial;