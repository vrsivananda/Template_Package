function [] = rds_closebutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global rds_fh;

close( rds_fh );
figure( rdt_fh );
rdt_displaytrial;