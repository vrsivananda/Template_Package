function [] = rds_erasesacbutton()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global rds_fh;

[x,y] = ginput(1);
x = floor( x );

f=[];
[sstarts, sends] = rex_trial_saccade_times( rdt_filename, rdt_trialnumber );
for i = 1:length( sstarts );
    if sstarts(i) < x && sends(i) > x
        f = i;
    end;
end;

%f = find( sstarts < x && sends > x );
if isempty( f )
    msgbox( 'Click inside a saccade on the graph to erase it.' );
    return;
end;

rex_erasesaccades( rdt_filename, rdt_trialnumber, f(1) );
% 
% rez = questdlg( 'Erase all saccades for this trial?', 'Erase saccades' );
% 
% if strcmp( rez, 'Yes' )
%     rex_erasesaccades( rdt_filename, rdt_trialnumber );
% end;

rds_displaytrialsaccade;