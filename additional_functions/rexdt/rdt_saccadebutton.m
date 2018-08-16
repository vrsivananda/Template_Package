function [] = rdt_saccadebutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

global rds_fh;

rds_fh = figure();

erasesacbhandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', 'erase a saccade', 'Position', [10 10 100 20] );
set( erasesacbhandle, 'Callback', 'rds_erasesacbutton' );
addsacbhandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', 'add a saccade', 'Position', [110 10 100 20] );
set( addsacbhandle, 'Callback', 'rds_addsacbutton' );
closebhandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', 'Close', 'Position', [210 10 100 20] );
set( closebhandle, 'Callback', 'rds_closebutton' );

rds_displaytrialsaccade();



