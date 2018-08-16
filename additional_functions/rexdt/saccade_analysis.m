function [allsacangles, allsacamp] = saccade_analysis( filename, minwidth, slopethreshold, includeaborted )

% Returns two lists representing all saccades in the data file, the
% first is all the angles and second is all the amplitudes.  These two
% match in indices, such that allsacangles(52) is the angle for the 52nd
% saccade, and allsacamp(52) is the amplitude of the 52nd saccade.
% allsacangles is in radians.  Multiply by 180/pi to get degrees.

if (nargin < 4 )
    includeaborted = 0;
end;
if (nargin < 3 )
    slopethreshold = 0.1;
end;
if (nargin < 2 )
    minwidth = 20;
end;
allsacamp = [];
allsacangles = [];

numtrials = num_rex_trials( filename, includeaborted );
for trial=1:numtrials
    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial_rca(filename, trial, includeaborted);
    [sstarts, sends, eddhv] = find_saccades( h, v, minwidth, slopethreshold );
    vcomp = v( sends) - v( sstarts );
    hcomp = h( sends ) - h( sstarts );
    sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
    %sacangles = atan( vcomp ./ hcomp );% * (180 / pi);
    sacangles = atan2( vcomp, hcomp );
    
    allsacamp = cat( 1, allsacamp, sacamp );
    allsacangles = cat( 1, allsacangles, sacangles );
end;


