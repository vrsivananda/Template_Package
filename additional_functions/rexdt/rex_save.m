function [rez] = rex_save( filename, prompt )

% [rez] = rex_save( filename, prompt )
%
% Saves any changes made to a converted set of Rex data back to the
% processed Matlab file.  See also rex_load_processed.

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen allrexnotes;

rez = 1;

if nargin < 2
    prompt = 1;
end;

if ~strcmp( filename, rexloadedname )
    rez = 0;
    if prompt
        s = sprintf( 'An attempt was made to save a file called "%s", when the only data loaded is from file "%s".', filename, rexloadedname );
        errordlg( s );
    end;
    return;
end;

saveit = '';
if prompt
    s = sprintf( 'Save data to a file called "%s.mat"?', filename );
    saveit = questdlg( s, 'Save Rex data' );
else
    saveit = 'Yes';
end;

if strcmp( saveit, 'Yes' )
    filename = cat( 2, filename, '.mat' );
    filename
    save( filename, 'rexloadedname', 'rexnumtrials', 'alloriginaltrialnums', 'allnewtrialnums', 'allcodes', 'alltimes', 'allspkchan', 'allspk', 'allrates', ...
    'allh', 'allv', 'allstart', 'allbad', 'alldeleted', 'allsacstart', 'allsacend',...
    'allcodelen', 'allspklen', 'alleyelen', 'allsaclen', 'allrexnotes' );
else
    rez = 0;
end;

