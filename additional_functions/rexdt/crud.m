function [alignedrasters, sphisto, alignindex] = rex_rasters_trialtype( name, binwidth, trialcodevalues, alignmentcode, allowbadtrials )

%  rex_rasters_analyzer

%  Called by other functions to compile data about trial classes from
%  Rex data.

%  Reads data directly from Rex analog and event files (A & E files) and
%  generates spike rasters and a histogram or spike density function from 
%  those rasters.  Allows
%  selection of trials that only contain certain codes, and allows
%  alignment on those or other codes.

%  name - of the Rex A and E files, without the A or E.
%  binwidth - for the histogram, how may samples (usually == ms for 1000Hz
%       sampling rate) per histogram bin.  Usually like 5 or 10.
%  trialcodevalues - the codes that indicate what trials to look for.  Can
%       be a single value or a list of values [6022 6027 6087] and so on.
%  alignmentcode - optional.  What code in each trial is the data to be
%       aligned to (can also be a list).  Aligns to the first match it 
%       finds.  If left off, the trialcodevalues are used for alignment.
%  allowbadtrials - 1 if bad trials should be included in the analysis.

%  Currently this code assumes only one set of spikes is coming out of 
%  rex_trial_rca (in spk).  This will not always be right if there are
%  multiple channels (units, whatever) in the Rex file.

if nargin < 4
    alignmentcode = 0;
else
    alignto = alignmentcode;
end;

if nargin == 4
    allowbadtrials = 0;
end;

alignmentfound = 0;
    
nummatch = 0;
alignindexlist = [];
rasters = [];
nt = num_rex_trials( name, 1 );
for d = 1:nt
    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial ] = rex_trial_rca(name, d, 1);
    if isempty(h) || isempty(ecodeout)
        disp( 'Something wrong with trial, no data.' );
    elseif badtrial && ~allowbadtrials
        disp( 'Skipping bad trial.' );
    else
        f = [];
        for i=1:length( trialcodevalues )
            f = [f;find( ecodeout == trialcodevalues(i) )];
        end;
        if ~isempty( f )
            if alignmentcode == 0
                alignto = ecodeout(f(1));
            end;
            falign = [];
            for i = 1:length( alignto )
                falign = [falign;find( ecodeout == alignto(i) )];
            end;
            %falign = find( ecodeout == alignto );
            if isempty( falign )
                s = sprintf( 'Trial %d has code %d, but does not contain any alignment code requested.', d, ecodeout(f(1)) );
                disp( s );
            else
                alignmentfound = ecodeout( falign(1) );
                nummatch = nummatch + 1;
                %next line isn't right.
                %and it's replacement below assumes a sampling rate of
                %1000.
                %alignindexlist(nummatch) = falign(1 );
                %Try this:
                alignindexlist( nummatch ) = etimeout( falign( 1 ) ) * (arate / 1000);
                train = [];
                if ~isempty( spk )
                    [train, last] = rex_spk2raster( spk, etimeout(1), 1, length( h ) );
                end; 
                rasters = cat_variable_size_row( rasters, train );
            end;
        end;
    end;
    
end;

alignedrasters = align_rows_on_indices( rasters, alignindexlist );
alignindex = max( alignindexlist );
sphisto = spikehist( alignedrasters, binwidth );


s1 = name;
if length( trialcodevalues ) == 1
    s1 = cat( 2, s1, sprintf( ',  Code = %d, n = %d trials, ', trialcodevalues, nummatch ));
else
    s1 = cat( 2, name, sprintf( ',  Multiple codes (%d etc), n = %d trials, ', trialcodevalues(1), nummatch ));
end;
if alignmentcode == 0
    s1 = cat( 2, s1, sprintf( 'aligned to trial codes.' ) );
else
    s1 = cat( 2, s1, sprintf( 'aligned to %d.', alignmentfound ));
end;
s2 = sprintf( 'histogram of all neural spike events.' );
