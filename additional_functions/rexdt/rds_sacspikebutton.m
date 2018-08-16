function [] = rds_sacspikebutton

global rds_allsacangles;
global rds_allsacamps;
global rds_fh;
global rds_filename;
global rds_includeaborted;
global rds_spikeraster;
global rds_spikehisto;
% global rds_minwidth;
% global rds_slopethreshold;

prompt = {'Minimum amplitude value for saccades to analyze (leave blank for no min):',...
    'Maximum amplitude value for saccades to analyze (leave blank for no max):',...
    'Minimum angle (counter-clockwise, in degrees) (leave blank for no min):',...
    'Maximum angle (counter-clockwise, in degrees) (leave blank for no max):',...
    'Minimum duration in miliseconds (leave blank for no min)',...
    'Maximum duration in miliseconds (leave blank for no max)'...
    'miliseconds before saccade start to gather spike data:',...
    'miliseconds after saccade start to gather spike data:',...
    'Type a 1 to include BAD trials (leave blank for no bad trials):' };

dlgname = 'Parameters for saccade-centered spike analysis';

answersok = 0;
while (answersok<1)
    answers = inputdlg( prompt, dlgname );
%     answers
    if (isempty( answers ) )
        answersok = 2;
    else
        for d=1:9
            if isempty( str2num(answers{d} ) )
                answerint(d) = 0;
            else
                answerint(d) = str2num( answers{d} );
            end;
        end;
        minamp = answerint(1);
        maxamp = answerint(2);
        minangle = answerint(3);
        maxangle = answerint(4);
        mindur = answerint(5);
        maxdur = answerint(6);
        msbefore = answerint(7);
        msafter = answerint(8);
        includebad = answerint(9);
        
        if (maxamp >= minamp)
            answersok = 1;
        end;
    end;
end;

if answersok == 2
    return;
end;

if (maxamp == 0)
    maxamp = max( rds_allsacamps );
end;
if (maxangle == 0)
    maxangle = 360;
end;

if msbefore == 0 && msafter == 0
    msbefore = 100;
    msafter = 100;
end;

if maxdur == 0
    maxdur = 10000;  % a very long saccade
end;

binsize = 5;

wb = waitbar( 0, 'Doing saccade analysis...' );

%  Spike raster and histogram for all requested eye traces.

[rast, hist, trialnums, sacnums] = rex_saccade_spike_histo( ...
    rds_filename, minamp, maxamp, minangle, maxangle, mindur, maxdur, ...
    msbefore, msafter, binsize, rds_includeaborted );
rds_spikeraster = rast;
rds_spikehisto = hist;
[totalsacs, tracewidth] = size( rast );

waitbar( 0.1, wb );

%  And all of the saccades themselves and their velocities.

hall = [];
vall = [];
velall = [];

for sn = 1:length( trialnums )
    trial = trialnums( sn );
    sac = sacnums( sn );
    [h,v,vel] = rex_get_saccade( rds_filename, trial, sac, msbefore, msafter );
    hall = cat( 1, hall, h );
    vall = cat( 1, vall, v );
    velall = cat( 1, velall, vel );
    waitbar( 0.1 + ((sn * 0.9) / length( trialnums )), wb );
end;
close( wb );
        
spkdf = spike_density( merge_raster( rast ), 5 ) / totalsacs;
meanvelall = mean( velall )';
stdvelall = std( velall )';

%  Now plot it.

ss1 = sprintf( 'Neural activity %d ms before to %d ms after saccade onset, %d to %d degrees', msbefore, msafter, minangle, maxangle );
ss2 = sprintf( 'Spike density function of neural activity' );
ss3 = sprintf( 'Saccade velocities for all %d saccades', totalsacs );

figure;
subplot( 3, 1, 1 );
title( ss1 );
colormap( 1-gray );
imagesc( rast );
title( ss1 );
subplot( 3, 1, 2 );
%bar( hist(1:(end-1)), 'b' );
plot( spkdf );
title( ss2 );
subplot( 3, 1, 3 );
%plot( velall' );
hold on;
plot( smoothtrace( meanvelall, 2 ), 'LineWidth', 2, 'Color', [0 0 0] );
% plot( smoothtrace( meanvelall+(stdvelall*2), 5 ), 'Color', [0.6 0.6 0.6] );
% plot( smoothtrace( meanvelall-(stdvelall*2), 5 ), 'Color', [0.6 0.6 0.6 ] );
% plot( meanvelall, 'g' );
% plot( meanvelall + (stdvelall * 2), 'r' );

hold off;
title( ss3 );


figure;
colormap( 1 - gray );
imagesc( rast );

% plot( hall' );
% hold on;
% plot( mean( hall )', 'LineWidth', 3, 'Color', [0 0 0] );

% size( velall )
% figure()
% plot( velall( :, msbefore+20 ) );




