function [nt] = num_rex_trials( name )

% [nt] = num_rex_trials( name )
%
% How many trials are in the Rex data given by 'name'.
%
% If the data for 'name' are not in memory, num_rex_trials will attempt to
% load them with rex_load_processed.
%
% If for some reason loading fails, num_rex_trials returns 0;

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen;


nt = 0;

if ~strcmp( name,rexloadedname );
     success = rex_load_processed( name );
     if ~success
         return;
     end;
end;

nt = rexnumtrials;