function [prevtrial, isfirst] = rex_prev_trial( name, trial, includebad )

% [prevtrial, isfirst] = rex_prev_trial( name, trial, includebad )
%
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), and a trial number, return the number (just the
%  number) of the previous sequential trial.  If the optional 3rd parameter
%  'includebad' is set to 1, then this is simply trial - 1.  If the 3rd
%  parameter is 0 (the DEFAULT), then a search backward is done for the next
%  good trial in the reverse direction (the next trial not marked as BAD), 
%  and rex_prev_trial() returns that number.
%  In either instance, if the number of the first (or the first good) trial
%  is returned, the 2nd return value 'isfirst' is set to 1.
%
%  See also rex_first_trial() and rex_next_trial().

if nargin < 3
    includebad = 0;
end;

prevtrial = trial;
badtrial = 1;
isfirst = 0;

if trial == 1
    isfirst = 1;
    return;
end;

if includebad
    prevtrial = prevtrial - 1;
    if prevtrial == 1
        isfirst = 1;
    end;
    return;
end;

while badtrial && prevtrial > 1
    prevtrial = prevtrial - 1;
    badtrial = rex_is_bad_trial( name, prevtrial );
end;

if badtrial
    prevtrial = trial;
end;

% Is this the earliest (first) good trial?

islast = 1;
for d = 1:prevtrial-1
    badtrial = rex_is_bad_trial( name, d );
    if ~badtrial
        isfirst = 0;
    end;
end;
