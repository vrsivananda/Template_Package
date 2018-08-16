function [] = rex_make_bad_trial( name, trial )

% rex_make_bad_trial( name, trial ) - Marks a trial as BAD.  See also 
% rex_is_good_trial and rex_make_good_trial.

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen;

num = num_rex_trials( name );
if trial < num
    allbad( trial ) = 1;
end;
