function [notes] = rex_get_notes( name )

% function [notes] = rex_get_notes( name )
%
% Returns the notes (comments added previously) for the set of Rex
% data given by 'name' (which is the name of .mat, A, or E files containing
% Rex data).


global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen allrexnotes;


notes = '';

if ~strcmp( name,rexloadedname );
     success = rex_load_processed( name );
     if ~success
         return;
     end;
end;

notes = allrexnotes;