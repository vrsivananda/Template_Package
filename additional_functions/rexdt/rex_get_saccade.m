function [h,v,sacvelocity] = rex_get_saccade( filename, trial, sacnumber, msbefore, msafter )

% [h,v,sacvelocity] = rex_get_saccade( filename, trial, sacnumber )
%
% For a given set of rex data (filename) and a trial number, return the
% sacnumber-th saccade in that trial.  It is returned as 3 vectors that
% start msbefore-1 milliseconds before saccade start and end msafter
% milliseconds after saccade start (assuming a 1kHz sampling rate,
% otherwise the input parameters msbefore and msafter indicate the number
% of data points).  The three vectors are the horizontal eye component (h),
% the vertical eye component (v), and the velocity (sacvelocity).
%
% If sacnumber indicates a saccade that does not exist, [] is returned for
% all three vectors (the same is true if the trial is not valid).  If
% msbefore or msafter run off the end of the eye trace (they extend beyond
% the begining or end of the trial), the extra space will be padded with
% 0s.
%
% msbefore and msafter are optional, and if not given they will default to
% 200.
%

if nargin < 4
msbefore = 200;
end;
if nargin < 5
msafter = 200;
end;

h = [];
v = [];
sacvelocity = [];

num = num_rex_trials( filename );
if trial < 1 || trial > num || num == 0
return;
end;

[ec, et, spkchan, spk, arate, wh, wv ] = rex_trial(filename, trial);
[sstarts, sends] = rex_trial_saccade_times( filename, trial );

if isempty( wh ) || isempty( wv ) || isempty( sstarts ) || isempty( sends )
    disp( 'rex_get_saccade:  Could not get eye info for trial.' );
    return;
end;

numsacs = length( sstarts );
if sacnumber < 1 || sacnumber > numsacs
    disp( 'rex_get_saccade:  Requested saccade number out of range for trial.' );
    return;
end;

% vcomp = wv( sends) - wv( sstarts );
% hcomp = wh( sends ) - wh( sstarts );
% sacamp = sqrt( (vcomp .* vcomp) + (hcomp .* hcomp) );
% sacangles = atan2( vcomp, hcomp );
dh = diff( wh );
dv = diff( wv );
ederiv = sqrt( ( dh .* dh ) + ( dv .* dv ) );

newlen = msbefore+msafter;
h = zeros( 1, newlen );
v = zeros( 1, newlen );
sacvelocity = zeros( 1, newlen );
first = 1 + sstarts( sacnumber ) - msbefore;
last = sstarts( sacnumber ) + msafter;
triallen = length( wh );

% easy case, then hard case where we run off the ends of the source (wh
% and wv).  For that, just do it the slow sure way.  It will be rare.

if first > 0 && last <=triallen
    h = wh( first:last );
    v = wv( first:last );
    sacvelocity( 1:newlen-1) = ederiv( first:last-1 );
else
    for d = 1:newlen
        si = first+d-1;
        if si > 0 && si <= triallen
            h( d ) = wh( si );
            v( d ) = wv( si );
            if si > length( ederiv )
                sacvelocity( d ) = 0;
            else
                sacvelocity( d ) = ederiv( si );
            end;
        end;
    end;
end;




