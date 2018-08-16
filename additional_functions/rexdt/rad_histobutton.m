function [] = rad_histobutton

global rad_fh;
global rad_taskcheck1handle;
global rad_taskcheck2handle;
global rad_taskcheck3handle;
global rad_taskcheck4handle;

global rad_aligncombohandle;
global rad_preedithandle;
global rad_postedithandle;
global rad_binedithandle;
global rad_sigmaedithandle;

global rad_rastercheckhandle;
global rad_spikedenscheckhandle;
global rad_probdenscheckhandle;
global rad_eyecheckhandle;
global rad_summarycheckhandle;
global rad_badcheckhandle;

global rdt_filename;

task1 = (get( rad_taskcheck1handle, 'Value' ) == get( rad_taskcheck1handle, 'Max' ));
task2 = (get( rad_taskcheck2handle, 'Value' ) == get( rad_taskcheck2handle, 'Max' ));
task3 = (get( rad_taskcheck3handle, 'Value' ) == get( rad_taskcheck3handle, 'Max' ));
task4 = (get( rad_taskcheck4handle, 'Value' ) == get( rad_taskcheck4handle, 'Max' ));

aligntype = get( rad_aligncombohandle, 'Value' );
pretime = str2num( get( rad_preedithandle, 'String' ) );
posttime = str2num( get( rad_postedithandle, 'String' ) );
bintime = str2num( get( rad_binedithandle, 'String' ) );
sigma = str2num( get( rad_sigmaedithandle, 'String' ) );

doraster = (get( rad_rastercheckhandle, 'Value' ) == get( rad_rastercheckhandle, 'Max' ));
dohisto = 0;
dospikedens = (get( rad_spikedenscheckhandle, 'Value' ) == get( rad_spikedenscheckhandle, 'Max' ));
doprobdens = (get( rad_probdenscheckhandle, 'Value' ) == get( rad_probdenscheckhandle, 'Max' ));
doeyevel = (get( rad_eyecheckhandle, 'Value' ) == get( rad_eyecheckhandle, 'Max' ));
dosummary = (get( rad_summarycheckhandle, 'Value' ) == get( rad_summarycheckhandle, 'Max' ));
includebad = (get( rad_badcheckhandle, 'Value' ) == get( rad_badcheckhandle, 'Max' ));

includeflags = [doraster dohisto dospikedens doprobdens doeyevel dosummary includebad];

fixedcode = 0;
aligncode = 0;
switch( aligntype )
    case 1 
        aligncode = 6000;
    case 2 
        aligncode = 6200;
    case 3 
        aligncode = 6400;
    case 4 
        aligncode = 6600;
    case 5 
        aligncode = 6800;
    case 6 
        aligncode = 7000;
    case 7 
        aligncode = 7200;
    case 8 
        aligncode = 7400;
    case 9 
        aligncode = 7600;
    case 10 
        aligncode = 1035; fixedcode = 1;
    case 11 
        aligncode = 1030; fixedcode = 1;
    case 12 
        aligncode = 5999; fixedcode = 1;
    case 13 
        aligncode = 5998; fixedcode = 1;
end;

bcodes = [];
acodes = [];

acodeadd = [0 10 20 30];
if fixedcode
    acodeadd = [0 0 0 0];
end;

if task1
    bcodes = cat(1, bcodes, 6000);
    acodes = cat(1, acodes, aligncode);
end;
if task2
    bcodes = cat(1, bcodes, 6010);
    acodes = cat(1, acodes, aligncode + 10);
end;
if task3
    bcodes = cat(1, bcodes, 6020);
    acodes = cat(1, acodes, aligncode + 20);
end;
if task4
    bcodes = cat(1, bcodes, 6030);
    acodes = cat(1, acodes, aligncode + 30);
end;

if fixedcode
    acodes = aligncode;
end;

% bcodes = 6010;
% acodes = 7010;
rex_8dir_spike_display( rdt_filename, pretime, posttime, bcodes, [], [], acodes, includeflags, sigma );
