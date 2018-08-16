function [] = rex_erasesaccades( name, trial, sacnumber )

% rex_erasesaccades( name, trial )
%
% Removes all saccade times for a given trial, unless a saccade number for 
% the trial is given.  New saccades can be added with rex_addsaccade.


global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen;

if nargin < 3
    sacnumber = 0;
end;

if trial > 0 && trial <= rexnumtrials
    if sacnumber==0
        allsaclen( trial ) = 0;
        allsacstart( trial, : ) = 0;
        allsacend( trial, : ) = 0;
    else
        totalsacs = allsaclen( trial );
        if sacnumber == totalsacs
            allsaclen( trial ) = totalsacs - 1;
            allsacstart( trial, totalsacs ) = 0;
            allsacend( trial, totalsacs ) = 0;
        elseif sacnumber < totalsacs
            sacnumber
            totalsacs
            allsacstart( trial, sacnumber:totalsacs-1) = allsacstart( trial, sacnumber+1:totalsacs );
            allsacend( trial, sacnumber:totalsacs-1 ) = allsacend( trial, sacnumber+1:totalsacs );
            allsacstart( totalsacs ) = 0;
            allsacend( totalsacs ) = 0;
            allsaclen( trial ) = totalsacs - 1;
        end;
    end;
end;