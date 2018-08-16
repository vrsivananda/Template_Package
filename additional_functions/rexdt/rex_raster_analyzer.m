function [alignedrasters, sphisto, sdf, alignindex] = rex_raster_analyzer( name, analysistype, binwidth, trialcodevalues, alignmentcode, allowbadtrials )

%  rex_rasters_analyzer

%  Called by other functions to compile data about trial classes from
%  Rex data.

%  Reads data directly from Rex analog and event files (A & E files) and
%  generates spike rasters and a histogram or spike density function from 
%  those rasters.  Allows
%  selection of trials that only contain certain codes, and allows
%  alignment on those or other codes.

%  name - of the Rex A and E files, without the A or E.
%  analysistype - 0 for spike density, 1 (or other) for PETH.
%  binwidth - for the histogram, how may samples (usually == ms for 1000Hz
%       sampling rate) per histogram bin.  Usually like 5 or 10.
%       For SDF, the width of the guassian to convolve the spikes with.
%  trialcodevalues - the codes that indicate what trials to look for.  Can
%       be a single value or a list of values [6022 6027 6087] and so on.
%  alignmentcode - optional.  What code in each trial is the data to be
%       aligned to (can also be a list).  Aligns to the first match it 
%       finds.  If left off, the trialcodevalues are used for alignment.
%  allowbadtrials - 1 if bad trials should be included in the analysis.

%  Currently this code assumes only one set of spikes is coming out of 
%  rex_trial_rca (in spk).  This will not always be right if there are
%  multiple channels (units, whatever) in the Rex file.

if nargin < 5
    alignmentcode = 0;
else
    alignto = alignmentcode;
end;

if nargin == 5
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
                nrl = 1+spk{1} - etimeout(1);
                train = zeros( 1, length( h ) );
                if ~isempty( nrl )
                    last = max( nrl( end ), length( h ) );
                    train = zeros( 1, last );                
                    train( nrl ) = 1; 
                end; 
                rasters = cat_variable_size_row( rasters, train );
            end;
        end;
    end;
    
end;

alignedrasters = align_rows_on_indices( rasters, alignindexlist );
alignindex = max( alignindexlist );
sphisto = spikehist( alignedrasters, binwidth );

% Spike density

sz = size( alignedrasters );
smrast = [];
for rw = 1:sz(1)
    smrast = cat( 1, smrast, rcasmoothtrace( alignedrasters( rw,: ), binwidth / arate, arate ) );
end;

sdf = sum( smrast );

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
% 
% invgray = 1.0 - gray;
% figure()
% subplot( 3,1, 1 );
% imagesc( fat_raster( alignedrasters, 3 ) );
% %imagesc( alignedrasters );
% colormap( invgray );
% title( s1 );
% subplot( 3, 1, 2 );
% bar( sphisto, 'k' );
% title( s2 );
% subplot( 3, 1, 3 );
% plot( sdf );
% title( 'spike density function ' );