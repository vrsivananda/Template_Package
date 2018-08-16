function [] = rds_actbutton

global rds_allsacangles;
global rds_allsacamps;
global rds_fh;
global rds_filename;
global rds_includeaborted;
global rds_spikeraster;
global rds_spikehisto;

msbefore = 0;
msafter = 0;
includebad = 0;
normal = 1;

%  Get some parameters for the analysis.

prompt = {'Miliseconds before saccade start to gather spike data (blank for saccade start):',...
    'Miliseconds after saccade start to gather spike data (leave blank for saccade end):',...
    'Enter 1 to normalize to peak value (0 or blank for mean + 2 standard deviations):'...
    'Type a 1 to include BAD trials (leave blank for no bad trials):' };

dlgname = 'Parameters for neural activity plot';

answersok = 0;
while (answersok<1)
    answers = inputdlg( prompt, dlgname );
    if (isempty( answers ) )
        answersok = 2;
    else
        msbefore = str2num( answers{1} );
        if isempty( msbefore )
            msbefore = 0;
        end;
        msafter = str2num( answers{2} );
        normal = str2num( answers{3} );
        if isempty( normal )
            normal = 0;
        end;
        includebad = str2num( answers{4} );
        if isempty( includebad )
            includebad = 0;
        end;
        
        answersok = 1;
    end;
end;

if answersok == 2
    return;
end;


islast = 0;
trial = rex_first_trial( rds_filename, includebad );
if trial == 0
    return;
end;

allsacamps = [];
allsacangles = [];
allsacpower = [];

%  Calculate the angles, amps, and velocities.

while ~islast
    [ecodeout, etimeout, spkchan, spk, arate, h, v] = rex_trial(rds_filename, trial);
    [sstarts, sends] = rex_trial_saccade_times( rds_filename, trial );

    vcomp = v( sends) - v( sstarts );
    hcomp = h( sends ) - h( sstarts );
    sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
    sacangles = atan2( vcomp, hcomp );
    power = sacamp .* 0;
    
    %  power is calculated here.  i.e. the amount of neural activity.
    
    train = [];
    if ~isempty( spk )
        train = rex_spk2raster( spk,  1, length( h ) );
        sac = 1;
        for d = 1:length( sstarts )

            first = sstarts(d) - (msbefore -1);
            last = sends(d);
            if ~isempty( msafter )
                last = sstarts(d) + msafter;
            end;

            if first < 1 || last >length( train ) || first >= last
                s = sprintf( 'rds_actbutton:  discarding a saccade (#%d) that is too close to the edge in trial %d.', d, trial);
                disp( s );
                power( d ) = -1;
            else
                power( d ) = sum( train( first:last ) ) / (last - first);
            end;
        end;            
    end;
    
    fok = find( power >= 0 );
    allsacamps = cat( 1, allsacamps, sacamp(fok)' );
    allsacangles = cat( 1, allsacangles, sacangles(fok)' );
    allsacpower = cat( 1, allsacpower, power(fok)' );
    
    [trial, islast] = rex_next_trial( rds_filename, trial, includebad );
end;

%  Normalize all power values and put in 0 to 1 range for plotting.

maxpower = max( allsacpower );
meanpower = mean( allsacpower );
stdpower = std( allsacpower );

if normal == 1
    normalizer = maxpower;
else
    normalizer = (meanpower + (stdpower * 2 ));
end;

allnormpower = allsacpower ./ normalizer;
f = find( allnormpower > 1);
allnormpower(f) = 1;
f = find( allnormpower < 0);
allnormpower(f) = 0;

pwred = allnormpower;
pwblue = allnormpower .* 0;

%  polar() does not seem to allow holding and dropping on multiple dots of
%  different colors.  Do a transform to cartesian and plot on X-Y.

[x,y] = pol2cart( allsacangles, allsacamps );

figure;
hold on;
for d=1:length( allsacamps )
    plot( x(d), y(d), '.', 'Color', [pwred(d) 0.0 pwblue(d)], 'MarkerSize', 20 );
end;
hold off;