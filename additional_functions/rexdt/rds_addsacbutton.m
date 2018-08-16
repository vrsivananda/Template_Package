function [] = rds_addsacbutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global rds_fh;

[x,y] = ginput(2);
x = floor( x );

if length(x) == 2 
    rex_addsaccade( rdt_filename, rdt_trialnumber, x(1), x(2) );
end;

rds_displaytrialsaccade;