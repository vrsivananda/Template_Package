function [] = rdt_allsacbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

rex_display_saccades( rdt_filename, rdt_includeaborted );
