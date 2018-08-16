function [meanselmetric, maxselmetric] = rex_8direction_saccade_analysis( filename, msbefore, msafter, binsize, includeaborted )

%  [meanselmetric, maxselmetric] = rex_8direction_saccade_analysis
%         ( filename, msbefore, msafter, binsize, includeaborted )
% 
%  Take a file, find all saccades, split them into 8 directions, compile
%  histograms, display them.  For fast analysis, just type
%
%  rex_8direction_saccade_analysis( [name of REX data without '.mat'] );
%
%  Other arguments are optional, such as msbefore (miliseconds before each
%  saccade onset to collect spike data) msafter (miliseconds after saccade
%  onset (not offset)), and binsize (number of data points per bin in the
%  histogram - for Rex the number of data points is equivalent to the
%  number of miliseconds).
%
%  The return values are goofy selectivity metrics that give an idea of how
%  much the activity *might* be related to saccade onset.  High
%  meanselmetric means that the neural data is high... wait, this doesn't
%  work right.  Forget them for now.

if nargin < 2
    msbefore = 200;
end;
if nargin < 3
    msafter = 200;
end;
if nargin < 4
    binsize = 5;
end;
if nargin < 5
    includeaborted = 1;
end;

msbefore
msafter
binsize 

ang = 1:45:360;
ang = ang - 23;
ang(1) = ang(1) + 360;
midpoint = (msbefore + msafter) / (binsize * 2 );

% width = 10;
% slope = 0.2;
ang


[rightraster, righthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(1), ang(2), 0, 0, msbefore, msafter, binsize, includeaborted );
[uprightraster, uprighthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(2), ang(3), 0, 0, msbefore, msafter, binsize,includeaborted );
[upraster, uphisto] = rex_saccade_spike_histo( filename, 0, 0, ang(3), ang(4), 0, 0, msbefore, msafter, binsize,includeaborted );
[upleftraster, uplefthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(4), ang(5), 0, 0, msbefore, msafter, binsize,includeaborted );
[leftraster, lefthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(5), ang(6), 0, 0, msbefore, msafter, binsize,includeaborted );
[downleftraster, downlefthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(6), ang(7), 0, 0, msbefore, msafter, binsize,includeaborted );
[downraster, downhisto] = rex_saccade_spike_histo( filename, 0, 0, ang(7), ang(8), 0, 0, msbefore, msafter, binsize,includeaborted );
[downrightraster, downrighthisto] = rex_saccade_spike_histo( filename, 0, 0, ang(8), ang(1), 0, 0, msbefore, msafter, binsize,includeaborted );

selmetric = zeros( 1, 8 );
pbr = zeros( 1, 8 );

% [selmetric(1), pbr(1)] = rca_histo_selectivity_metric( righthisto, midpoint );
% [selmetric(2), pbr(2)] = rca_histo_selectivity_metric( uprighthisto, midpoint );
% [selmetric(3), pbr(3)] = rca_histo_selectivity_metric( uphisto, midpoint );
% [selmetric(4), pbr(4)] = rca_histo_selectivity_metric( uplefthisto, midpoint );
% [selmetric(5), pbr(5)] = rca_histo_selectivity_metric( lefthisto, midpoint );
% [selmetric(6), pbr(6)] = rca_histo_selectivity_metric( downlefthisto, midpoint );
% [selmetric(7), pbr(7)] = rca_histo_selectivity_metric( downhisto, midpoint );
% [selmetric(8), pbr(8)] = rca_histo_selectivity_metric( downrighthisto, midpoint );

meanselmetric = mean( selmetric );
maxselmetric = max( selmetric );

%  Normalize by number of trials.

sz = size( rightraster );
righthisto = righthisto / sz(1);
rightsdf = spike_density( merge_raster( rightraster ), 5 ) / sz(1);
sz = size( uprightraster );
uprighthisto = uprighthisto / sz(1);
uprightsdf = spike_density( merge_raster( uprightraster ), 5 ) / sz( 1 );
sz = size( upraster );
uphisto = uphisto / sz(1);
upsdf = spike_density( merge_raster( upraster ), 5 ) / sz( 1 );
sz = size( upleftraster );
uplefthisto = uplefthisto / sz(1);
upleftsdf = spike_density( merge_raster( upleftraster ), 5 ) / sz( 1 );
sz = size( leftraster );
lefthisto = lefthisto / sz(1);
leftsdf = spike_density( merge_raster( leftraster ), 5 ) / sz( 1 );
sz = size( downleftraster );
downlefthisto = downlefthisto / sz(1);
downleftsdf = spike_density( merge_raster( downleftraster ), 5 ) / sz( 1 );
sz = size( downraster );
downhisto = downhisto / sz(1);
downsdf = spike_density( merge_raster( downraster ), 5 ) / sz( 1 );
sz = size( downrightraster );
downrighthisto = downrighthisto / sz(1);
downrightsdf = spike_density( merge_raster( downrightraster ), 5 ) / sz( 1 );




maxval = max( [max(righthisto), max( uprighthisto), max( uphisto ), max( uplefthisto ), ...
    max( lefthisto ), max( downlefthisto ), max( downhisto ), max( downrighthisto )] );

maxsdf = max( [max(rightsdf), max( uprightsdf), max( upsdf ), max( upleftsdf ), ...
    max( leftsdf ), max( downleftsdf ), max( downsdf ), max( downrightsdf )] );

sdfalign = zeros( 1, length( upsdf ) );
sdfalign( msbefore ) = maxsdf;

fh = figure;
set( fh, 'name', filename );

subplot( 4, 2, 1 );
plot( upsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'up' );

subplot( 4, 2, 3 );
plot( upleftsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'up left' );

subplot( 4, 2, 5 );
plot( leftsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'left' );

subplot( 4, 2, 7 );
plot( downleftsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'down left' );

subplot( 4, 2, 2 );
plot( uprightsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'up right' );

subplot( 4, 2, 4 );
plot( rightsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'right' );

subplot( 4, 2, 6 );
plot( downrightsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'down right' );

subplot( 4, 2, 8 );
plot( downsdf );
hold on;
plot( sdfalign, 'r' );
hold off;
title( 'down' );

for d=1:8
    subplot( 4, 2, d );
    axis tight;
    ax = axis;
    ax(4) = maxsdf;
    axis( ax );
end;
% axlabels = 1:length(uphisto(1:(end-1)));
% axlabels = axlabels - midpoint;
% 
% subplot( 4, 2, 1 );
% bar( axlabels, uphisto(1:(end-1)), 'b' );
% axis tight;
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'up' );
% 
% subplot( 4, 2,3 );
% bar( axlabels,uplefthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'up left' );
% 
% subplot( 4, 2, 5 );
% bar( axlabels,lefthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'left' );
% 
% subplot( 4, 2, 7 );
% bar( axlabels,downlefthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'down left' );
% 
% subplot( 4, 2, 2 );
% bar( axlabels,uprighthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'up right' );
% 
% subplot( 4, 2, 4 );
% bar( axlabels,righthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'right' );
% 
% subplot( 4, 2, 6 );
% bar( axlabels,downrighthisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'down right' );
% 
% subplot( 4, 2, 8 );
% bar( axlabels,downhisto(1:(end-1)), 'b' );
% ax = axis;
% ax(4) = maxval;
% axis( ax );
% title( 'down' );
