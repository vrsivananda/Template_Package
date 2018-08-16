function [] = rex_display_saccades( filename, includeaborted )

% rex_display_saccades( filename, includeaborted )
% 
%  Give a file name. Displays the amplitude and angle of all saccades
%  detected in the file.  Has a button to select some of these and do
%  neural raster / histogram stuff.  (see rex_saccade_spike_histo).

if (nargin < 2 )
    includeaborted = 1;
end;
% if (nargin < 2 )
%     minwidth = 10;
% end;
% if (nargin < 3 )
%     slopethreshold = 0.1;
% end;

global rds_allsacangles;
global rds_allsacamps;
global rds_fh;
global rds_filename;
global rds_includeaborted;
% global rds_minwidth;
% global rds_slopethreshold;

rds_filename = filename;
rds_includeaborted = includeaborted;
% rds_minwidth = minwidth;
% rds_slopethreshold = slopethreshold;

[rds_allsacangles,rds_allsacamps] = rex_all_saccades( filename, includeaborted );
allsacdegrees = rds_allsacangles .* (180/pi);

% figure;
% subplot( 2, 1, 1 );
% bar( rds_allsacamps );
% subplot( 2, 1, 2 );
% bar( allsacdegrees );

rds_fh = figure;
polar( rds_allsacangles, rds_allsacamps, '.' );
sacspikehandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', 'spike analysis', 'Position', [10 10 100 20] );
set( sacspikehandle, 'Callback', 'rds_sacspikebutton' );
acthandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', 'neural activity plot', 'Position', [110 10 150 20] );
set( acthandle, 'Callback', 'rds_actbutton' );
do8wayhandle = uicontrol( 'Parent', rds_fh, 'Style', 'pushbutton', 'String', '8 dir analysis', 'Position', [260 10 100 20] );
set( do8wayhandle, 'Callback', 'rds_8waybutton' );
