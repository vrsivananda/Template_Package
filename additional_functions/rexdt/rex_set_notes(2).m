function [] = rex_set_notes( name, notes )

% function [] = rex_set_notes( name, notes)
%
% Stores the variable 'notes' (usually comments about the data and such) 
% for the set of Rex data given by 'name' (which is the name of .mat, A, 
% or E files containing Rex data).  These will not be permanently stored
% without a call to rex_save().


global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen allrexnotes;


if ~strcmp( name,rexloadedname );
     success = rex_load_processed( name );
     if ~success
         return;
     end;
end;

allrexnotes = notes;