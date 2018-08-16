function [allsacangles, allsacamp] = rex_all_saccades( filename, includeaborted )

% [allsacangles, allsacamp] = rex_all_saccades( filename, includeaborted )
%
% Returns two lists representing all saccades in the data file, the
% first is all the angles and second is all the amplitudes.  These two
% match in indices, such that allsacangles(52) is the angle for the 52nd
% saccade, and allsacamp(52) is the amplitude of the 52nd saccade.
% allsacangles is in radians.  Multiply by 180/pi to get degrees.
%
% If the 2nd optional parameter 'includeaborted' is 1, saccades are
% collected from all trials.  If it is 0 (the DEFAULT), only good trials
% (those not marked BAD) are included.

if (nargin < 2 )
    includeaborted = 0;
end;

allsacamp = [];
allsacangles = [];

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
    sacangles = atan2( vcomp, hcomp );
    
    allsacamp = cat( 1, allsacamp, sacamp' );
    allsacangles = cat( 1, allsacangles, sacangles' );
    [trial, islast] = rex_next_trial( filename, trial );
end;

% numtrials = num_rex_trials( filename, includeaborted );
% for trial=1:numtrials
%     [sstarts, sends, eddhv] = find_saccades( h, v, minwidth, slopethreshold );
%     
%     vcomp = v( sends) - v( sstarts );
%     hcomp = h( sends ) - h( sstarts );
%     sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
%     %sacangles = atan( vcomp ./ hcomp );% * (180 / pi);
%     sacangles = atan2( vcomp, hcomp );
%     
%     allsacamp = cat( 1, allsacamp, sacamp );
%     allsacangles = cat( 1, allsacangles, sacangles );
% end;


