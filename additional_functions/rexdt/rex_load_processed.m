function [success] = rex_load_processed( name )

%  [success] = rex_load_processed( name )
% 
%  Rex data for the rex_ matlab functions are stored in memory.  (They are
%  read in from a matlab file created by rex_process().)  This function
%  searches for the matlab file (do not include '.mat' when calling it),
%  and if it cannot find it, calls rex_process() which will see if there
%  are original Rex data files that it can convert.
%  Either way, it then loads the variables into memory.
%
%  See also num_rex_trials, rex_trial, rex_first_trial.

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums ...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen allrexnotes;

allrexnotes = '';

disp( 'Loading...');
l = length( name );
rexmatname = name;
if ~strcmp( lower( name( l-3:l ) ), '.mat' )
    rexmatname = cat( 2, name, '.mat' );
end;
if ~exist( rexmatname, 'file' )
    success = rex_process( name );
    if ~success
        return;
    end;
end;

success = 1;
load( rexmatname );

