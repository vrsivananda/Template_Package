function [dirrast, dirhist, dirsdf, dirpdf, diraidx] =...
    rex_8dir_spike_display( filename, msbefore, msafter, anyofbasecodes, allofbasecodes, noneofbasecodes, aligncodes, includeflags, fsigma )

% filename
% msbefore
% msafter
% anyofbasecodes
% aligncodes
% includeflags

INCLUDERASTER = 1;
INCLUDEHISTO = 2;
INCLUDESDF = 3;
INCLUDEPDF = 4;
INCLUDEEYEVEL = 5;
INCLUDESUMMARY = 6;
INCLUDEBAD = 7;
INCLUDEALLINONE = 8;

NUMINCLUDEFLAGS = 8;

includetext = {'spike raster', 'histogram', 'spike density function', ...
    'probability density function', 'eye velocity', 'summary', 'bad trials', 'ignore direction'};

if nargin < 9
    fsigma = 5;
end;
if nargin < 8
    includeflags = 0;
end;
if includeflags == 0
    includeflags = [0 0 0 0 0 0 0];
end;
if length( includeflags ) < NUMINCLUDEFLAGS
    includeflags = cat( 2, includeflags, zeros( 1, (NUMINCLUDEFLAGS - length( includeflags ) ) ) );
end;


include_raster = includeflags( INCLUDERASTER );
include_histo = includeflags( INCLUDEHISTO );
include_sdf = includeflags( INCLUDESDF );
include_pdf = includeflags( INCLUDEPDF );
include_eye = includeflags( INCLUDEEYEVEL );
include_summary = includeflags( INCLUDESUMMARY );
include_bad = includeflags( INCLUDEBAD );
include_num = sum( includeflags( INCLUDERASTER:INCLUDEEYEVEL ) );
include_ext = ( include_num > 0 );
include_allinone = includeflags( INCLUDEALLINONE );

%secondcode = rdt_ecodes( 2 );

mstart = msbefore;
mstop = msafter;
binwidth = 20;
   
dirrast = [];
dirhist = [];
dirsdf = [];
dirpdf = [];
diraidx = [];
dirnumtrials = [];
   
wb = waitbar( 0.1, 'Compiling trials...' );
    
if include_allinone
    numdirs = 1;
else
    numdirs = 8;
end;

   for d = 0:(numdirs-1)
       acode = aligncodes;
       f6000 = find( acode >= 6000 );
       
       if include_allinone
           tcode = anyofbasecodes;
           for dircode = 1:7
               tcode = cat( 2, tcode, anyofbasecodes + dircode );
               acode = cat( 2, acode, acode( f6000) + dircode );
           end;
       else
           acode( f6000 ) = acode( f6000 ) + d;
           tcode = anyofbasecodes + d;
       end;

       s = sprintf( 'Calculating trials with codes %d..., aligned to %d...', tcode(1), acode(1) );
       waitbar( 0.1 + (d * 0.12), wb, s );
       [r, aidx, eyeh, eyev, eyevel] = rex_rasters_trialtype( filename, 1, tcode, [],[], acode, include_bad);

       sz = size( r );
       if isempty( r )  || sum( sum( r ) ) == 0
           s = 'No raster could be generated for alignment codes: ';
           for nyah = 1:length( acode )
               s = [s, ' ', num2str( acode(nyah) ) ];
           end;
           disp( s );
           sumall = zeros( 1, mstart+mstop );
           h = zeros( 1, floor((mstart+mstop)/binwidth) );
           sdf = sumall;
           pdf = sumall;
           aidx = mstart;
           alignindex = aidx;
           if alignindex < 1
               alignindex = 1;
           end;
           start = 0;
       else
            start = aidx - mstart;
            stop = aidx + mstop;
            if start < 1
                start = 1;
            end;
            if stop > length( r )
                stop = length( r );
            end;
            starth = ceil( start / binwidth );
            stoph = floor( stop / binwidth );
    
            h = spikehist( r, binwidth );
            sumall = merge_raster( r( :, start:stop ) );
            sdf = spike_density( sumall, fsigma ) / sz( 1 );
            pdf = probability_density( sumall, fsigma ) / sz( 1 );
            
            alignindex = aidx - start;
            if alignindex < 1
                alignindex = 1;
            end;
            
            if include_ext
                fx = figure;
                set( fx, 'name', [filename ' code:' num2str( acode(1) )] );
                nextsubplot = 1;
                
                if (include_raster)
                    subplot( include_num, 1, nextsubplot );
                    imagesc( r(:, start:stop ) );
                    colormap( 1- gray);
                    title( 'spike raster' );
                    nextsubplot = nextsubplot + 1;
                end;
                
                if (include_histo)
                    subplot( include_num, 1, nextsubplot );
                    bar( h( starth:stoph ) );
                    title( 'spike histogram' );
                    nextsubplot = nextsubplot + 1;
                end;
                
                if (include_sdf)
                    subplot( include_num, 1, nextsubplot );
                    plot( sdf );
                    aline = zeros( 1, length( sdf ) );
                    aline( alignindex ) = max( sdf );
                    hold on;
                    plot( aline, 'r' );
                    hold off;
                    axis( 'tight' );
                    title( 'spike density function ' );
                    nextsubplot = nextsubplot + 1;
                end;
                
                
                if (include_pdf)
                    subplot( include_num, 1, nextsubplot );
                    plot( pdf );
                    aline = zeros( 1, length( pdf ) );
                    aline( alignindex ) = max( pdf );
                    hold on;
                    plot( aline, 'r' );
                    hold off;
                    axis( 'tight' );
                    title( 'probability density function ' );
                    nextsubplot = nextsubplot + 1;
                end;

                if (include_eye)
                    subplot( include_num, 1, nextsubplot );
                    sz = size( eyevel );
                    if sz(2) >= stop
                        plot( eyevel( :, start:stop)' );
                        hold on;
                        meanvel = mean( eyevel( :, start:stop ) );
                        plot( meanvel, 'k-', 'LineWidth', 2 );
                        hold off;
                    else
                        s = sprintf( 'size(1) is %d and size(2) is %d for the eye velocity trace for the %d trials.', sz(1), sz(2), tcode );
                        disp(s);
                        s = sprintf( 'start is %d and stop is %d.\n', start, stop );
                        disp( s );
                        pause;
                    end;
                    axis( 'tight' );
                    title( 'eye velocity' );
                    nextsubplot = nextsubplot + 1;
                end;
            end;
       end;

       dirrast = cat_variable_size_row( dirrast, sumall );
       dirhist = cat_variable_size_row( dirhist, h );
       dirsdf = cat_variable_size_row( dirsdf, sdf );
       dirpdf = cat_variable_size_row( dirpdf, pdf );
       diraidx(d+1) = alignindex;
       dirnumtrials(d+1) = sz( 1 );
       
       % do we need to adjust based on alignment index here?
       % see align_rows_on_indices.
   end;
   
%  This is all just for setting the vertical axes on the summary page.
%  For directions with few trials, don't normalize the axes to these.

copydirsdf = dirsdf;
ftoofew = find( dirnumtrials < 4 );
copydirsdf( ftoofew, : ) = copydirsdf( ftoofew, : ) .* 0;
maxsdf = max( max( copydirsdf ) );

spn = [1 2 4 6 8 7 5 3];
ttl = {'up xxx0' 'up right xxx1' 'right xxx2' 'down right xxx3' 'down xxx4' 'down left xxx5' 'left xxx6' 'up left xxx7'};
fh = figure;
set( fh, 'name', filename );

if include_summary
    for d = 1:numdirs % may be 8 or 1, depending on include_allinone
        aline = zeros( 1, length( dirsdf( d, : ) ) );
        aline( diraidx(d) ) = maxsdf;
        if ~include_allinone
            subplot( 4, 2, spn(d) );
        end;
        plot( dirsdf( d, : ) );
        axis tight;
        if dirnumtrials( d ) > 3
            ax = axis;
            ax(4) = maxsdf;
            axis( ax );
        end;
        hold on;
        plot( aline, 'r' );
        if include_allinone
            title( 'All directions compiled' );
        else
            s = sprintf( '%s, %d trials', ttl{d}, dirnumtrials( d ) );
            title( s );
        end;
    end;
end;



    
    close( wb );
    
    