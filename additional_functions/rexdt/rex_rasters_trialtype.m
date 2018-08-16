function [alignedrasters, alignindex, eyehoriz, eyevert, eyevelocity, trialnumbers] = ...
    rex_rasters_trialtype( name, spikechannel, anyofcodes, allofcodes, noneofcodes, alignmentcode, allowbadtrials, alignsacnum )

%  [alignedrasters, alignindex, eyeh, eyev, eyevel] = rex_rasters_trialtype
%      ( name, binwidth, anyofcodes, allofcodes, noneofcodes, alignmentcode, allowbadtrials )
%
%  Called by other functions to compile data about trial classes from
%  Rex data.
%
%  Generates spike rasters Allows
%  selection of trials that only contain certain codes, and allows
%  alignment on those or other codes.  'alignindex' returns the index in the
%  rasters (the column, assuming each row is a raster) at which all rasters
%  are aligned, given the alignmentcode.  This should be 1 if no alignment
%  codes are used.  It will > 1 if the alignment code did not occur at the
%  same place in each trial and rasters had to be shifted in order to
%  align them all.  Also returns some eye information that will be described 
%  later ( horizontal,  vertical, and  velocity of eye traces). 
%
%  name - of the converted Rex data file (without the '.mat')
%  spikechannel - which spike channel to get data from.  Usually this is 1,
%       and in fact right now the code ignores this and uses 1.
%  anyofcodes, allofcodes, noneofcodes - the codes that indicate what trials 
%       to look for.  Can be empty, can 
%       be a single value, or a list of values [6022 6027 6087] and so on.
%  alignmentcode - optional.  What code in each trial is the data to be
%       aligned to (can also be a list).  Aligns to the first match it 
%       finds.  If left off, the trialcodevalues are used for alignment.
%  allowbadtrials - 1 if bad trials should be included in the analysis.
%  alignsacnum - optional.  This is used to align the results to the
%       n-th saccade following the alignment code, where n is alignsacnum.
%
%  Currently this code assumes only one set of spikes is coming out of 
%  rex_trial (in spk).  This will not always be right if there are
%  multiple channels (units, whatever) in the Rex file.
%
%  EXAMPLE:
%     [r,aidx] = rex_rasters_trialtype( filename, 1, anyofthese, [],[],aligncodes);
%     %  Summate all the rasters for PETH-type things
%     sumall = merge_raster( r );
%     %  Calculating spike density
%     sdf = spike_density( sumall, 5 );
%     %  Calculating probability density
%     pdf = probability_density( sumall, 5 );
%     start = aidx - 500;
%     stop = aidx + 500;
%     plot( sdf( start:stop) ); % plot spike density for 500 ms before
%                               % to 500 ms after the time of the alignment



alignedrasters=[];
sphisto=[];
alignindex=[];
eyehoriz=[];
eyevert=[];
eyevelocity=[];
trialnumbers=[];

if nargin < 6
    if isempty( anyofcodes )
        alignmentcode = allofcodes;
    else
        alignmentcode = anyofcodes;
    end;
end;

if isempty( allofcodes ) && isempty( anyofcodes )
    disp( 'rex_rasters_trialtype:  "All of" code list and "Any of" code list cannot both be empty.' );
    return;
end;

alignto = alignmentcode;

if nargin <7
    allowbadtrials = 0;
end;

if nargin < 8
    alignsacnum = 0;
end;

if spikechannel > 10
    s = sprintf( 'rex_rasters_trialtype:  the neural data channel requested (%d) was crazy.\n', spikechannel );
    return;
end;

sbad = '';
if ~allowbadtrials
    sbad = 'Bad trials skipped: ';
end;

% Variables that will be incremented or appended as matching trials are
% collected.

alignmentfound = 0;    
nummatch = 0;
alignindexlist = [];
rasters = [];
eyeh = [];
eyev = [];
eyevel = [];
eyehoriz = [];
eyevert = [];
eyevelocity = [];

%  Loop through all of the trials using rex_first_trial and rex_next_trial.
%  See if each trial has the right codes, and try to align the spike data
%  to one of the alignment codes.

d = rex_first_trial( name, allowbadtrials );
islast = (d == 0);
while ~islast
    
    % For the current trial given by 'd', a call to rex_trial
    % gives us the codes, their times, the spike data, the
    % sampling rate, and the horizontal and vertical eye traces.  It also
    % gives start_time relative to the start of the whole file, and a
    % badtrial flag, which is irrelevant since we already know if this will
    % be a valid trial or not (because of the 2nd parameter in
    % rex_first_trial and rex_next_trial).
    
    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial(name, d );
    if isempty(h) || isempty(ecodeout)
        disp( 'Something wrong with trial, no data.' );
    else
        anyof = has_any_of( ecodeout, anyofcodes );
        allof = has_all_of( ecodeout, allofcodes );
        noneof = has_none_of( ecodeout, noneofcodes );
        
        %  If these are all true, we have found a trial matching the
        %  requested codes.  Now check for alignment, which might be a 
        %  whole list of possible candidates.  This actually makes a list
        %  (falign) of the ecode indices where there's a match, which is 
        %  probably unneccessary, since only the first is used.
        
        if anyof & allof & noneof
            falign = [];
            for i = 1:length( alignto )
                fnext = find( ecodeout == alignto(i) );
                if ~isempty( fnext )
                    if isempty( falign )
                        falign = fnext(1);
                    else
                        falign = [falign;fnext(1)];
                    end;
                end;
            end;

            if isempty( falign )
                s = sprintf( 'In rex_rasters_trialtype, trial %d has a matching base code (%d?), but does not contain any alignment code requested.', d, ecodeout(2) );
                disp( s );
            else
                % We found one or more alignments, so get the actual time of the
                % first one. 
                
                alignmentfound = ecodeout( falign(1) );
                aligntime = etimeout( falign( 1 ) ) * (arate / 1000);
            
                % If we are looking for the n-th saccade after our found
                % alignment, do that here.  Access rex_trial_saccade_times 
                % by file name and trial number (d).
            
                if alignsacnum == 0
                    nummatch = nummatch + 1;
                    alignindexlist( nummatch ) = aligntime;
                elseif alignsacnum < 0
                    disp( 'In rex_rasters_trialtype, aligning to saccades BEFORE alignment codes has not been implemented yet. ');
                    alignmentfound = 0;
                elseif alignsacnum > 0
                    [sstarts, sends] = rex_trial_saccade_times( name, d );
                    sacnumstart = find( sstarts > aligntime );
                    if length( sacnumstart ) < alignsacnum
                        alignmentfound = 0;
                    else
                        aligntime = sstarts( sacnumstart(alignsacnum) );
                        nummatch = nummatch + 1;
                        alignindexlist( nummatch ) = aligntime;
                    end;
                end;
                
                % If we found a place to align, either a code, or a code
                % followed by the alignsacnum-th saccade, then collect the
                % spikes for this trial in 'train', and then add to the
                % raster list of all spike trains so far, i.e. 'rasters'.
                % Though added to the rasters list, these trains are not
                % yet aligned.  That happens later.
                
                if alignmentfound  
                    trialnumbers( nummatch ) = d;
                    train = [0];
                    if ~isempty( spk )
                        [train, last] = rex_spk2raster( spk, 1, length( h ) );
                    end;
                    rasters = cat_variable_size_row( rasters, train );

                    if length(h)<length(train)
                        s = sprintf( 'In rex_rasters_trialtype, the eye trace was shorter than the spike raster (%d < %d) for trial %d.  Padding with zeros.',...
                            length(h), length(train), d );
                        %disp(s);
                        h = [h zeros(1, length(train)-length(h))];
                        v = [v zeros(1, length(train)-length(v))];
                    end;
                    
                    % Also collect eye movement traces for this trial, and
                    % add to the lists (eyeh and eyev).  Also do velocity.
                    
                    eyeh = cat_variable_size_row( eyeh, h );
                    eyev = cat_variable_size_row( eyev, v );
                    dh = diff( h );
                    dv = diff( v );
                    velocity = sqrt( ( dh .* dh ) + ( dv .* dv ) );
                    eyevel = cat_variable_size_row( eyevel, velocity );
                end;
            end;
        end;
    end;
    
    [d, islast] = rex_next_trial( name, d, allowbadtrials );
    
end;

if isempty( rasters )
    disp( 'Cannot generate rasters with the given codes, since no matching trials were found.' );
    alignedrasters = [];
    alignindex = 0;
    sphisto = [];
    return;
end;

% We have rows of spike trains (rasters), and indices on which to align
% them (alignindexlist).  Now shift, or align, each of the rows so that the
% alignment time occurs at the same index in all rows.  See
% align_rows_on_indices() to see how this works.

alignedrasters = align_rows_on_indices( rasters, alignindexlist );
alignindex = max( alignindexlist );

% figure( 21 )
% subplot( 2, 1, 1 );
% imagesc( rasters );
% subplot( 2, 1, 2 );
% imagesc( alignedrasters );
% colormap( 1 - GRAY );
% alignindex
% alignindexlist


% alignindex is now the index (the column) in alignedrasters that is the
% column to which all rows are aligned.  Do the same for the eye stuff.

eyehoriz = align_rows_on_indices( eyeh, alignindexlist );
eyevert = align_rows_on_indices( eyev, alignindexlist );
eyevelocity = align_rows_on_indices( eyevel, alignindexlist );

% Done.  Everything is collected and aligned for all matching trials.
