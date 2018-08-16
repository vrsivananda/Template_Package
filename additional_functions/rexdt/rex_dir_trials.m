function [nt] = rex_dir_trials( filename, includeaborted )

% rex_dir_trials( filename, includeaborted )
% 
%  Just like rex_display_trials, but with a button to do a compilation of
%  trials by direction, and assumes the dir.d task generated the data
%  files.  Thus it separates the data into 8 directions, and aligns on
%  saccade time, which is code 701x (0-7).

if nargin == 1
    includeaborted = 1;
end;

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

rdt_includeaborted = includeaborted;
rdt_filename = filename;
rdt_nt = num_rex_trials( rdt_filename );
rdt_badtrial = 0;
rdt_fh = figure();
rdt_trialnumber = rex_first_trial( rdt_filename, rdt_includeaborted );
if rdt_trialnumber == 0
    msgbox( 'There are no good trials (no trials, or all are marked BAD) for this set of Rex data.', 'Loading data', 'modal' );
    close( rdt_fh );
    return;
end;

set( rdt_fh, 'Position', [100 300 900 600] );

prevbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', '<', 'Position', [10 10 20 20] );
set( prevbhandle, 'Callback', 'rdt_prevbutton' );
nextbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', '>', 'Position', [30 10 20 20] );
set( nextbhandle, 'Callback', 'rdt_nextbutton' );
spikebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'spike analysis', 'Position', [50 10 100 20] );
set( spikebhandle, 'Callback', 'rdt_spikebutton' );
codebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'code list', 'Position', [150 10 100 20] );
set( codebhandle, 'Callback', 'rdt_codebutton' );
deletebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'mark as BAD', 'Position', [250 10 100 20] );
set( deletebhandle, 'Callback', 'rdt_deletebutton' );
undeletebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'mark as good', 'Position', [350 10 100 20] );
set( undeletebhandle, 'Callback', 'rdt_undeletebutton' );
saccadebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'saccades', 'Position', [450 10 100 20] );
set( saccadebhandle, 'Callback', 'rdt_saccadebutton' );

histobhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'compile trials', 'Position', [560 10 90 20] );
set( histobhandle, 'Callback', 'rdt_histobutton' );
dirbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'dir', 'Position', [650 10 40 20] );
set( dirbhandle, 'Callback', 'rdt_dirbutton' );
allsacbhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'saccades', 'Position', [690 10 70 20] );
set( allsacbhandle, 'Callback', 'rdt_allsacbutton' );

savebhandle = uicontrol( 'Parent', rdt_fh, 'Style', 'pushbutton', 'String', 'Save changes', 'Position', [770 10 100 20] );
set( savebhandle, 'Callback', 'rdt_savebutton' );


rdt_displaytrial;
