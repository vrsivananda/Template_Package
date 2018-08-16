function [allrasters, histo, trialnums, sacnums] = rex_saccade_spike_histo( filename, minamp, maxamp, minangle, maxangle, mindur, maxdur, msbefore, msafter, binsize, includeaborted )

% [allrasters, histo, trialnums, sacnums] = rex_saccade_spike_histo( 
%       filename, minamp, maxamp, minangle, maxangle, mindur, maxdur, 
%       msbefore, msafter, binsize, includeaborted )
% 
%  Construct a raster (actually a list of rasters) for all rex trials in
%  'filename', centered on the onset of saccades.  Only those saccades that
%  fit the selection parameters are added in.  These inclue:
%
%    minamp, maxamp:  the minimum and maximum amplitude of saccades to
%                     choose.  Amplitude is in whatever units Rex uses.
%    minangle, maxangle:  the minimum and maximum angle, going in a counter
%                     clockwise direction, and for some reason measured in
%                     degrees (not radians).
%    mindur, maxdur:  range for the duration (ms) of the saccades to collect.
%    msbefore:  number of miliseconds before each saccade onset to collect
%                     neural data (spikes) for the raster.
%    msafter:  number of miliseconds after each saccade onset to continue
%                     collecting neural data.
%
%  There is also binsize, which is the number of data points in each bin
%  when making the histogram.  The default is 5.
%
%  The rasters are also compiled into a histogram.  The output argument
%  'trialnums' lists the rex trial numbers for each raster.  So
%  trialnum(15) will be the trial number corresponding to raster(15) or 
%  raster( 15,: ).  'sacnums' likewise indicates which detected saccade
%  corresponds to the raster of the same index, within the given trial.
%  Together these indicate that raster(X) came from trialnums(X) trial, and
%  was number sacnums(X) in that trial.

if (nargin < 10 )
    binsize = 5;
end;
% if (nargin < 9 )
%     minwidth = 10;
% end;
% if (nargin < 10 )
%     minslope = 0.2;
% end;
if (nargin < 11 )
    includeaborted = 0;
end;

allsacamp = [];
allsacangles = [];
allrasters = [];
trialnums = [];
sacnums = [];
histo = [];
numdiscarded = 0;

% numtrials = num_rex_trials( filename, includeaborted );
% for trial=1:numtrials
    
islast = 0;
trial = rex_first_trial( filename, includeaborted );
if trial == 0
    return;
end;

while ~islast
    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial(filename, trial);
    [sstarts, sends] = rex_trial_saccade_times( filename, trial );
    
    vcomp = v( sends) - v( sstarts );
    hcomp = h( sends ) - h( sstarts );
    sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
    sacangle = atan2( vcomp, hcomp );
    sacangle = sacangle * (180/pi);
    f = find( sacangle < 0);
    sacangle( f ) = sacangle( f ) + 360;
    numsac = length( sstarts );

    allsacamp = cat( 1, allsacamp, sacamp' );
    allsacangles = cat( 1, allsacangles, sacangle' );
        
    train = [];
    if ~isempty( spk )
        train = rex_spk2raster( spk, 1, length( h ) );
    end;
    
    
    for sac=1:numsac
        % Going counterclockwise means that minangle might be larger than maxangle.
        % This will happen if we're crossing the 0 degree direction.
    
        angleok = 0;
        ampok = 0;
        durok = 0;
        if (maxangle < minangle)
            if (sacangle(sac) <= maxangle) || ( sacangle(sac) >= minangle )
                angleok = 1;
            end;
        else
            if (sacangle(sac) >= minangle ) && (sacangle(sac) <= maxangle )
                angleok = 1;
            end;
        end;
        if (sacamp(sac) >= minamp) && (sacamp(sac) <= maxamp)
            ampok = 1;
        end;
        if (sacamp(sac) >= minamp) && (maxamp == 0)
            ampok = 1;
        end;
        durat = sends( sac ) - sstarts( sac );
        if maxdur==0 || maxdur < mindur
            durok = 1;
        elseif durat >= mindur && durat <= maxdur 
            durok = 1;
        end;
        

        % If this vector fits our range, pick
        % out the proper spikes for the raster.
        
        if (ampok && angleok && durok)
            
            idx = sstarts(sac);
            idxs = idx - (msbefore-1);
            idxe = idx + msafter;
            
            if ( idxs < 1) || (idxe > length( train ) )
%                 s = sprintf( 'rex_saccade_spike_histo:  discarding a saccade (#%d) that is too close to the edge of a trial (trial %d).', sac, trial);
%                 disp( s );
                numdiscarded = numdiscarded + 1;
            else
                sactrain = train( idxs:idxe );
                allrasters = cat( 1, allrasters, sactrain );
                sacnums = cat( 1, sacnums, sac );
                trialnums = cat( 1, trialnums, trial );
            end;
        end;
    
    end;
    [trial, islast] = rex_next_trial( filename, trial, includeaborted );
end;

if numdiscarded
    s = sprintf( 'rex_saccade_spike_histo:  discarding %d saccades that were too close to the edge of a trial given the requested before/after sizes.  This is normal.', numdiscarded );
    disp( s );
end;

histo = spikehist( allrasters, binsize );
    
    

