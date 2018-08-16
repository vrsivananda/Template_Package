function [success] = rex_process( rexname )

% [success] = rex_process( rexname )
%
% Given the name of some Rex data files (the A and E files, 
% without the ‘A’ or ‘E’ on the end), attempts a conversion of this data 
% into a Matlab file that contains all spike, code, saccade, and other 
% data.  Allows the optional import of a Dex D file for saccade times.  
% Data is written to a ‘.mat’ file using the name of the Rex files 
% given.  (Thus ‘mineA’ and ‘mineE’ become ‘mine.mat’.)  This function 
% can be called explicitly, but it is also called by rex_load_processed 
% if that function cannot find an already converted Rex/Matlab file of 
% the given name.  Returns 1 if successful, 0 if not.
% See also rex_load_processed and rex_save.

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums ...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen allrexnotes;

includeaborted = 1;
slopethreshold = 0.1;
minwidth = 10;

allcodes = [];
alltimes = [];
allspkchan = [];
allspk = [];
allrates = [];
allh = [];
allv = [];
allstart = [];
allbad = [];
alldeleted = [];
allsacstart = [];
allsacend = [];
alloriginaltrialnums = [];
allnewtrialnums = [];
hmarks = [];
vmarks = [];
success = 0;
usedexfile = 0;

wb = waitbar( 0, 'Reading Rex data...' );

rez = questdlg( 'Is there a DEX "D" file containing markers that you would like to load for this REX data?',...
    'Converting REX data', 'No' );
if strcmp( rez, 'Cancel' )
    close( wb );
    return;
end;
if strcmp( rez, 'Yes' )
    [dfile, ddir] = uigetfile( '*.*', 'Select a DEX file' );
    if isequal( dfile, 0 ) || isequal( ddir, 0 )
        errordlg( 'No DEX file was selected.', 'Converting REX data', 'modal' );
        close( wb );
        return;
    elseif ~exist( fullfile( ddir, dfile ) )
       errordlg( 'The selected DEX file does not exist.', 'Converting REX data', 'modal' );
       close( wb );
       return;
    else
        waitbar( 0.05, wb );
       [hmarks,vmarks] = dex_load_marks( fullfile( ddir, dfile ), wb );
       usedexfile = 1;
    end;
end;            


next = 1;
channel = -1;
nt = rex_numtrials_raw( rexname, includeaborted );
%nt = rex_numtrials_fake( rexname, includeaborted );

 %hhh = [1:2883 2885:nt]
%for zx=1:length(hhh)
for d = 1:nt    %From XQ: Change to nt-1 for this specific E file, change it back to nt for other files

    
   
    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial_raw(rexname, d, includeaborted);
    
     if length(h)>10000 || length(v) >10000
        continue;
     end
    
     
    %[ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial_fake(rexname, d, includeaborted);
    if isempty(h) || isempty(ecodeout)
        disp( 'rex_process.m:  Something wrong with trial, no data.  The trial will be skipped, and trial numbers will shift in the converted file to reflect this.' );
%     elseif badtrial && ~includeaborted
%         disp( 'rex_process.m:  Skipping bad trial.' );
    else
        allcodes = cat_variable_size_row( allcodes, ecodeout );
        alltimes = cat_variable_size_row( alltimes, etimeout );
        allcodelen( next ) = length( ecodeout );
        if isempty( spkchan )
            s = sprintf( 'rex_process.m:  No neural spike data found for trial %d (converted trial # %d), but including anyway.', d, next );
            disp( s );
            spk{1} = 0;
            spkchan = 1;
        end;
        
        %  Kloodge, because all this stuff only deals with one channel at a
        %  time.  If there are more than one channel, the user is asked
        %  which one to convert.  Multiple conversions can be done, but the
        %  original A and E files should be renamed first (to avoid
        %  overwriting the result.
 
        %  Once a channel is picked, we don't want to do it again for each
        %  trial.
 
        szspk = length( spkchan );
        if ( szspk > 1 && channel == -1)
            while ( channel < 1 || channel > szspk )
                sp = sprintf( 'There are %d spike channels in this file.  \nPick one for this translation (1 - %d).', szspk, szspk );
                prompt = {sp};
                name='Kloodgy spike channel picking...';
                numlines=1;
                defaultanswer={'1'};
            
                answer = inputdlg( prompt, name, numlines, defaultanswer );
                channel = str2num( answer{1} );
                rex_process_channelpicked = channel;
            end;
        elseif szspk ==1
            channel = 1;
        end;
        
        %  The following should only happen if a channel > 1 is picked, but
        %  we hit a trial that has fewer spike channels.  Hopefully Rex is
        %  not stupid enough to do this.
        
        if (channel > szspk)
            allspkchan( next ) = 1;
            allspk = cat_variable_size_row( allspk, 0 );
            allspklen( next ) = 0;
            allrates( next ) = 0;
        else
            allspkchan( next ) = spkchan( channel );
            allspk = cat_variable_size_row( allspk, spk{channel} );
            allspklen( next ) = length( spk{channel} );
            allrates( next ) = arate;
        end;
        allh = cat_variable_size_row( allh, h );
        allv = cat_variable_size_row( allv, v );
        alleyelen( next ) = length( h );
        allstart( next ) = start_time;
        allbad( next ) = badtrial;
        alldeleted( next ) = 0;
        
        %  Find saccades, either from a DEX file, or by using the
        %  find_saccades function.  If there is a DEX file, but no marks
        %  for this trial, also call the find_saccades function.
        
        sstarts = 2000;
        sends = 3500;
        markedsaccades = 0;
        if usedexfile
            [sstarts, sends] = dex_find_saccades_from_marks( d, hmarks, vmarks );

            if ~isempty( sstarts )
                markedsaccades = 1;
                s = sprintf( 'rex_process.m:  Saccades for trial %d (converted trial # %d) were found using DEX marks in %s file,', d, next, dfile );
                disp( s );
            end;
        end;
        if ~markedsaccades
             [sstarts, sends, eddhv] = find_saccades( h, v, minwidth, slopethreshold );
%              plot( h, 'k' );
%              hold on;
%              plot( v, 'k' );
%              hold off;
%              sstarts
%              sends
%              length( v )
%              length( h )
%              pause;
             f = find( sstarts == 0);
             if ~isempty( f )
                 s = sprintf( 'rex_process:  A saccade start time came back 0 in trial %d (converted trial # %d).', d, next );
                 disp( s );
             end;
        end;
        
        saclen = length( sstarts );
        if isempty( sstarts )
            sstarts = [0];
            sends = [0];
        end;
        
        allsacstart = cat_variable_size_row( allsacstart, sstarts );
        allsacend = cat_variable_size_row( allsacend, sends );
        allsaclen( next ) = saclen;
        alloriginaltrialnums( next ) = d;
        allnewtrialnums( next ) = next;
        
        next = next + 1;
    end;
    waitbar( (d/nt)*0.9, wb, 'Converting Rex data...' );
end;
%end
newname = cat( 2, rexname, '.mat' );
s = sprintf( 'Writing converted Rex data to %s.', newname );
waitbar( 0.9, wb, s );
rexloadedname = rexname;
rexnumtrials = next -1; %nt;

allrexnotes = sprintf( '%s, converted on %s\n%d trials\n', rexloadedname, datestr( now ), rexnumtrials );
save( newname, 'rexloadedname', 'rexnumtrials', 'alloriginaltrialnums', 'allnewtrialnums', 'allcodes', 'alltimes', 'allspkchan', 'allspk', 'allrates', ...
    'allh', 'allv', 'allstart', 'allbad', 'alldeleted', 'allsacstart', 'allsacend',...
    'allcodelen', 'allspklen', 'alleyelen', 'allsaclen', 'allrexnotes');% , '-v7.3');
success = 1;
close( wb );
